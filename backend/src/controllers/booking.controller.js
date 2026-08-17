const Appointment = require("../models/Appointments");
const Service = require("../models/Service");
const Specialist = require("../models/Specialist");
const User = require("../models/User");
const BlockedSlot = require("../models/BlockedSlot");
const DayOff = require("../models/DayOff");
const Notification = require("../models/Notifications");
const { applyLoyaltyRollover } = require("../utils/loyalty");

// Salon working hours: 09:00 to 19:30, in 30 minute slots.
const BUSINESS_START_HOUR = 9;
const BUSINESS_END_HOUR = 20;

const buildDaySlots = () => {
    const slots = [];
    for (let hour = BUSINESS_START_HOUR; hour < BUSINESS_END_HOUR; hour++) {
        for (const minute of [0, 30]) {
            const time = `${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`;
            const period = hour < 12 ? "Morning" : hour < 17 ? "Afternoon" : "Evening";
            slots.push({ time, period, hour });
        }
    }
    return slots;
};

const dayRange = (dateStr) => ({
    start: new Date(`${dateStr}T00:00:00`),
    end: new Date(`${dateStr}T23:59:59`),
});

// Whole-salon day offs (specialistId: null) block every specialist;
// a specialist-specific one only blocks that specialist.
const findDayOff = async (start, end, specialistId) => {
    const query = { date: { $gte: start, $lte: end } };
    query.$or = specialistId ? [{ specialistId: null }, { specialistId }] : [{ specialistId: null }];
    return DayOff.findOne(query);
};

// Lets a user-triggered booking change (cancel/reschedule) reach every admin.
const notifyAdmins = async (title, message) => {
    const admins = await User.find({ role: "admin" }).select("_id");
    if (!admins.length) return;
    await Notification.insertMany(
        admins.map((admin) => ({ userId: admin._id, title, message, type: "appointment" }))
    );
};

const STATUS_NOTIFICATIONS = {
    confirmed: { title: "Booking Confirmed", verb: "confirmed" },
    cancelled: { title: "Booking Cancelled", verb: "cancelled by the salon" },
    completed: { title: "Booking Completed", verb: "marked as completed" },
    pending: { title: "Booking Pending", verb: "set back to pending" },
};

class BookingController {
    // ==================== GET /services/:serviceId/availability ====================
    getAvailability = async (req, res) => {
        const { serviceId } = req.params;
        const { date } = req.query;
        if (!date) {
            return res.status(400).json({
                error: { code: "MISSING_DATE", message: "date query param is required" },
            });
        }

        const { start, end } = dayRange(date);

        const service = await Service.findById(serviceId).select("specialistId");
        const dayOff = await findDayOff(start, end, service ? service.specialistId : null);

        const bookings = await Appointment.find({
            date: { $gte: start, $lte: end },
            status: { $ne: "cancelled" },
        }).select("startTime");
        const bookedTimes = new Set(bookings.map((b) => b.startTime));

        const blocked = await BlockedSlot.find({ date: { $gte: start, $lte: end } });
        const blockedHours = new Set(blocked.map((b) => b.hour));

        const slots = buildDaySlots().map((slot) => ({
            time: slot.time,
            period: slot.period,
            available: !dayOff && !bookedTimes.has(slot.time) && !blockedHours.has(slot.hour),
        }));

        return res.status(200).json({ date, slots, dayOff: Boolean(dayOff), dayOffNote: dayOff ? dayOff.note : "" });
    };

    // ==================== POST /bookings ====================
    create = async (req, res) => {
        const { serviceId, date, time, useFreeSession } = req.body;

        if (!serviceId || !date || !time) {
            return res.status(400).json({
                error: { code: "MISSING_FIELDS", message: "serviceId, date and time are required" },
            });
        }

        const service = await Service.findById(serviceId);
        if (!service) {
            return res.status(404).json({
                error: { code: "SERVICE_NOT_FOUND", message: "Service not found" },
            });
        }

        const { start: dayStart, end: dayEnd } = dayRange(date);
        const dayOff = await findDayOff(dayStart, dayEnd, service.specialistId);
        if (dayOff) {
            return res.status(409).json({
                error: { code: "DAY_OFF", message: "This date is not available for booking." },
            });
        }

        const user = await User.findById(req.user._id);
        // Accounts that existed before freeSessions was added to the schema
        // read this path back as undefined rather than the default 0.
        user.freeSessions = user.freeSessions || 0;

        // Redeeming a free session is settled now (it's how the booking is
        // paid for). Earning points is not — that only happens once the
        // appointment is actually completed, see adminUpdateStatus.
        let totalPrice = service.price;
        let usedFreeSession = false;

        if (useFreeSession && user.freeSessions > 0) {
            usedFreeSession = true;
            totalPrice = 0;
            user.freeSessions -= 1;
            await user.save();
        }

        // Preview of what this booking will earn on completion — priced at
        // 100 or more, price/10 points, locked in now so a later price
        // change on the service doesn't affect an already-placed booking.
        const pointsEarned = totalPrice >= 100 ? Math.round(totalPrice / 10) : 0;

        const booking = await Appointment.create({
            userId: req.user._id,
            serviceId: service._id,
            specialistId: service.specialistId,
            date: new Date(date),
            startTime: time,
            totalPrice,
            pointsEarned,
            status: "pending",
        });

        const specialist = await Specialist.findById(service.specialistId);

        return res.status(201).json({
            id: booking._id,
            serviceId: service._id,
            serviceName: service.name,
            specialistName: specialist ? specialist.name : "",
            image: service.image,
            date,
            time,
            status: "UPCOMING",
            amount: totalPrice,
            pointsEarned,
            usedFreeSession,
            loyaltyPoints: user.loyaltyPoints,
            freeSessions: user.freeSessions,
        });
    };

    // ==================== GET /users/me/bookings ====================
    myBookings = async (req, res) => {
        const { status } = req.query; // UPCOMING | PAST | CANCELLED

        const bookings = await Appointment.find({ userId: req.user._id })
            .populate("serviceId")
            .populate("specialistId")
            .sort({ date: -1 });

        const now = new Date();
        let items = bookings.map((b) => {
            let derivedStatus;
            if (b.status === "cancelled") derivedStatus = "CANCELLED";
            else if (b.date >= now) derivedStatus = "UPCOMING";
            else derivedStatus = "PAST";

            return {
                id: b._id,
                serviceId: b.serviceId ? b.serviceId._id : null,
                serviceName: b.serviceId ? b.serviceId.name : "",
                specialistName: b.specialistId ? b.specialistId.name : "",
                image: b.serviceId ? b.serviceId.image : "",
                date: b.date.toISOString().slice(0, 10),
                time: b.startTime,
                status: derivedStatus,
                amount: b.totalPrice,
                pointsEarned: b.pointsEarned,
            };
        });

        if (status) {
            items = items.filter((b) => b.status === status);
        }

        return res.status(200).json({ items });
    };

    // ==================== POST /bookings/:id/cancel ====================
    cancel = async (req, res) => {
        const booking = await Appointment.findOne({ _id: req.params.id, userId: req.user._id }).populate("serviceId");
        if (!booking) {
            return res.status(404).json({
                error: { code: "NOT_FOUND", message: "Booking not found" },
            });
        }

        booking.status = "cancelled";
        await booking.save();

        const serviceName = booking.serviceId ? booking.serviceId.name : "an";
        const dateStr = booking.date.toISOString().slice(0, 10);
        await notifyAdmins(
            "Booking Cancelled",
            `${req.user.name} cancelled their ${serviceName} appointment on ${dateStr} at ${booking.startTime}.`
        );

        return res.status(200).json({ id: booking._id, status: "CANCELLED" });
    };

    // ==================== POST /bookings/:id/reschedule ====================
    reschedule = async (req, res) => {
        const { date, time } = req.body;
        if (!date || !time) {
            return res.status(400).json({
                error: { code: "MISSING_FIELDS", message: "date and time are required" },
            });
        }

        const booking = await Appointment.findOne({ _id: req.params.id, userId: req.user._id }).populate("serviceId");
        if (!booking) {
            return res.status(404).json({
                error: { code: "NOT_FOUND", message: "Booking not found" },
            });
        }
        if (booking.status === "cancelled") {
            return res.status(400).json({
                error: { code: "INVALID_STATUS", message: "Cancelled bookings cannot be rescheduled" },
            });
        }

        const { start, end } = dayRange(date);
        const clash = await Appointment.findOne({
            _id: { $ne: booking._id },
            date: { $gte: start, $lte: end },
            startTime: time,
            status: { $ne: "cancelled" },
        });
        if (clash) {
            return res.status(409).json({
                error: { code: "SLOT_TAKEN", message: "That time slot is no longer available" },
            });
        }

        booking.date = new Date(date);
        booking.startTime = time;
        await booking.save();

        const serviceName = booking.serviceId ? booking.serviceId.name : "an";
        await notifyAdmins(
            "Booking Rescheduled",
            `${req.user.name} rescheduled their ${serviceName} appointment to ${date} at ${time}.`
        );

        return res.status(200).json({ id: booking._id, date, time, status: "UPCOMING" });
    };

    // ==================== Admin: GET /admin/bookings ====================
    adminList = async (req, res) => {
        const { status } = req.query; // confirmed | pending | cancelled
        const filter = status ? { status } : {};

        const bookings = await Appointment.find(filter)
            .populate("userId")
            .populate("serviceId")
            .populate("specialistId")
            .sort({ date: -1 });

        const items = bookings.map((b) => ({
            id: b._id,
            clientName: b.userId ? b.userId.name : "",
            serviceId: b.serviceId ? b.serviceId._id : null,
            serviceName: b.serviceId ? b.serviceId.name : "",
            specialistId: b.specialistId ? b.specialistId._id : null,
            specialistName: b.specialistId ? b.specialistId.name : "",
            date: b.date.toISOString().slice(0, 10),
            time: b.startTime,
            dateTime: b.date.toISOString(),
            amount: b.totalPrice,
            status: b.status,
        }));

        return res.status(200).json({ items });
    };

    // ==================== Admin: PATCH /admin/bookings/:id ====================
    // Lets admin edit date/time/service/specialist on an existing booking.
    // Doesn't touch pointsEarned or the user's already-credited loyaltyPoints
    // — those were settled at booking creation and are out of scope here.
    adminUpdateBooking = async (req, res) => {
        const booking = await Appointment.findById(req.params.id);
        if (!booking) {
            return res.status(404).json({
                error: { code: "NOT_FOUND", message: "Booking not found" },
            });
        }

        const { serviceId, specialistId, date, time } = req.body;

        if (date !== undefined || time !== undefined) {
            const newDate = date !== undefined ? new Date(date) : booking.date;
            const newTime = time !== undefined ? time : booking.startTime;

            const { start, end } = dayRange(newDate.toISOString().slice(0, 10));
            const clash = await Appointment.findOne({
                _id: { $ne: booking._id },
                date: { $gte: start, $lte: end },
                startTime: newTime,
                status: { $ne: "cancelled" },
            });
            if (clash) {
                return res.status(409).json({
                    error: { code: "SLOT_TAKEN", message: "That time slot is no longer available" },
                });
            }

            booking.date = newDate;
            booking.startTime = newTime;
        }

        if (serviceId !== undefined && serviceId !== String(booking.serviceId)) {
            const service = await Service.findById(serviceId);
            if (!service) {
                return res.status(404).json({
                    error: { code: "SERVICE_NOT_FOUND", message: "Service not found" },
                });
            }
            booking.serviceId = service._id;
            booking.specialistId = specialistId || service.specialistId;
            booking.totalPrice = service.price;
        } else if (specialistId !== undefined) {
            booking.specialistId = specialistId;
        }

        await booking.save();

        return res.status(200).json({ id: booking._id });
    };

    // ==================== Admin: PATCH /admin/bookings/:id/status ====================
    adminUpdateStatus = async (req, res) => {
        const { status } = req.body;
        const allowed = ["pending", "confirmed", "cancelled", "completed"];
        if (!allowed.includes(status)) {
            return res.status(400).json({
                error: { code: "INVALID_STATUS", message: `status must be one of: ${allowed.join(", ")}` },
            });
        }

        const booking = await Appointment.findById(req.params.id).populate("serviceId");
        if (!booking) {
            return res.status(404).json({
                error: { code: "NOT_FOUND", message: "Booking not found" },
            });
        }

        if (booking.status !== status) {
            booking.status = status;

            // Loyalty points are only credited once a booking actually
            // finishes — not at the time it was made (see create()).
            if (status === "completed" && booking.totalPrice >= 100) {
                const pointsEarned = Math.round(booking.totalPrice / 10);
                booking.pointsEarned = pointsEarned;

                const user = await User.findById(booking.userId);
                if (user) {
                    user.loyaltyPoints += pointsEarned;
                    const freeSessionEarned = applyLoyaltyRollover(user);
                    await user.save();

                    await Notification.create({
                        userId: user._id,
                        title: "Loyalty Points Earned",
                        message: `You earned ${pointsEarned} points for completing your appointment!`,
                        type: "general",
                    });
                    if (freeSessionEarned) {
                        await Notification.create({
                            userId: user._id,
                            title: "Free Session Unlocked!",
                            message: "You've reached 1000 loyalty points and earned a free session. 🎉",
                            type: "general",
                        });
                    }
                }
            }

            await booking.save();

            const info = STATUS_NOTIFICATIONS[status];
            const serviceName = booking.serviceId ? booking.serviceId.name : "your";
            const dateStr = booking.date.toISOString().slice(0, 10);
            await Notification.create({
                userId: booking.userId,
                title: info.title,
                message: `Your ${serviceName} appointment on ${dateStr} at ${booking.startTime} was ${info.verb}.`,
                type: "appointment",
            });
        }

        return res.status(200).json({ id: booking._id, status: booking.status });
    };
}

module.exports = new BookingController();
