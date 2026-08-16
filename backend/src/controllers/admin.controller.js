const Appointment = require("../models/Appointments");
const Specialist = require("../models/Specialist");
const Service = require("../models/Service");
const BlockedSlot = require("../models/BlockedSlot");
const Setting = require("../models/Setting");

const startOfDay = (date) => {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    return d;
};

const endOfDay = (date) => {
    const d = new Date(date);
    d.setHours(23, 59, 59, 999);
    return d;
};

class AdminController {
    // ==================== GET /admin/dashboard/stats ====================
    // weeklyRevenueByDay is a rolling last-7-days window (today included),
    // not a fixed Mon-Sun week — simpler to compute and always has 7 real days.
    dashboardStats = async (req, res) => {
        const now = new Date();
        const todayStart = startOfDay(now);
        const todayEnd = endOfDay(now);

        const todayBookings = await Appointment.find({
            date: { $gte: todayStart, $lte: todayEnd },
            status: { $ne: "cancelled" },
        });
        const todayRevenue = todayBookings.reduce((sum, b) => sum + b.totalPrice, 0);

        const activeStaff = await Specialist.countDocuments();

        const services = await Service.find().select("averageRating");
        const avgRating = services.length
            ? services.reduce((sum, s) => sum + s.averageRating, 0) / services.length
            : 0;

        const weekStart = startOfDay(new Date(now.getTime() - 6 * 24 * 60 * 60 * 1000));
        const weekBookings = await Appointment.find({
            date: { $gte: weekStart, $lte: todayEnd },
            status: { $ne: "cancelled" },
        });
        const weeklyRevenue = weekBookings.reduce((sum, b) => sum + b.totalPrice, 0);

        const weeklyRevenueByDay = [];
        for (let i = 6; i >= 0; i--) {
            const dayStart = startOfDay(new Date(now.getTime() - i * 24 * 60 * 60 * 1000));
            const dayEnd = endOfDay(dayStart);
            const dayTotal = weekBookings
                .filter((b) => b.date >= dayStart && b.date <= dayEnd)
                .reduce((sum, b) => sum + b.totalPrice, 0);
            weeklyRevenueByDay.push(dayTotal);
        }

        const recent = await Appointment.find()
            .populate("userId")
            .populate("serviceId")
            .populate("specialistId")
            .sort({ createdAt: -1 })
            .limit(3);

        const recentBookings = recent.map((b) => ({
            id: b._id,
            clientName: b.userId ? b.userId.name : "",
            serviceName: b.serviceId ? b.serviceId.name : "",
            specialistName: b.specialistId ? b.specialistId.name : "",
            dateTime: b.date.toISOString(),
            amount: b.totalPrice,
            status: b.status,
        }));

        return res.status(200).json({
            todayRevenue,
            bookingsToday: todayBookings.length,
            activeStaff,
            avgRating: Number(avgRating.toFixed(1)),
            weeklyRevenue,
            weeklyRevenueByDay,
            recentBookings,
        });
    };

    // ==================== GET /admin/availability?startDate&days ====================
    getAvailability = async (req, res) => {
        const { startDate, days } = req.query;
        if (!startDate) {
            return res.status(400).json({
                error: { code: "MISSING_START_DATE", message: "startDate query param is required" },
            });
        }
        const numDays = parseInt(days, 10) || 7;

        const rangeStart = startOfDay(new Date(`${startDate}T00:00:00`));
        const rangeEnd = endOfDay(new Date(rangeStart.getTime() + (numDays - 1) * 24 * 60 * 60 * 1000));

        const bookings = await Appointment.find({
            date: { $gte: rangeStart, $lte: rangeEnd },
            status: { $ne: "cancelled" },
        }).select("date startTime");

        const blocked = await BlockedSlot.find({ date: { $gte: rangeStart, $lte: rangeEnd } });

        // key = "date_hour" -> status. Booked always wins over blocked.
        const slotMap = new Map();
        for (const b of bookings) {
            const dateKey = b.date.toISOString().slice(0, 10);
            const hour = parseInt(b.startTime.split(":")[0], 10);
            slotMap.set(`${dateKey}_${hour}`, "booked");
        }
        for (const b of blocked) {
            const dateKey = b.date.toISOString().slice(0, 10);
            const key = `${dateKey}_${b.hour}`;
            if (!slotMap.has(key)) slotMap.set(key, "blocked");
        }

        const slots = Array.from(slotMap.entries()).map(([key, status]) => {
            const [date, hour] = key.split("_");
            return { date, hour: parseInt(hour, 10), status };
        });

        return res.status(200).json({ slots });
    };

    // ==================== PATCH /admin/availability ====================
    // Body is either { date, hour, status } for a single slot, or
    // { date, hourFrom, hourTo, status } to block/unblock a range at once.
    setAvailability = async (req, res) => {
        const { date, hour, hourFrom, hourTo, status } = req.body;

        if (!date || !status) {
            return res.status(400).json({
                error: { code: "MISSING_FIELDS", message: "date and status are required" },
            });
        }

        let hours;
        if (hourFrom !== undefined && hourTo !== undefined) {
            hours = [];
            for (let h = hourFrom; h <= hourTo; h++) hours.push(h);
        } else if (hour !== undefined) {
            hours = [hour];
        } else {
            return res.status(400).json({
                error: { code: "MISSING_HOUR", message: "hour, or hourFrom/hourTo, is required" },
            });
        }

        const dateObj = startOfDay(new Date(`${date}T00:00:00`));
        const dayEnd = endOfDay(dateObj);

        const bookings = await Appointment.find({
            date: { $gte: dateObj, $lte: dayEnd },
            status: { $ne: "cancelled" },
        }).select("startTime");
        const bookedHours = new Set(bookings.map((b) => parseInt(b.startTime.split(":")[0], 10)));

        for (const h of hours) {
            if (bookedHours.has(h)) continue; // a real booking can't be overridden here

            if (status === "blocked") {
                await BlockedSlot.findOneAndUpdate(
                    { date: dateObj, hour: h },
                    { date: dateObj, hour: h },
                    { upsert: true },
                );
            } else {
                await BlockedSlot.deleteOne({ date: dateObj, hour: h });
            }
        }

        return res.status(200).json({ success: true });
    };

    // ==================== GET /admin/settings/gemini-key ====================
    // Never returns the actual key back, even to an admin — just whether
    // one is configured (DB or .env) so the app can show the right state.
    getGeminiKeyStatus = async (req, res) => {
        const setting = await Setting.findOne({ key: "GEMINI_API_KEY" });
        const configured = Boolean(setting?.value || process.env.GEMINI_API_KEY);
        return res.status(200).json({ configured });
    };

    // ==================== PUT /admin/settings/gemini-key ====================
    setGeminiKey = async (req, res) => {
        const { value } = req.body;
        if (!value || !value.trim()) {
            return res.status(400).json({
                error: { code: "MISSING_VALUE", message: "value is required" },
            });
        }

        await Setting.findOneAndUpdate(
            { key: "GEMINI_API_KEY" },
            { key: "GEMINI_API_KEY", value: value.trim() },
            { upsert: true },
        );

        return res.status(200).json({ configured: true });
    };

    // ==================== POST /admin/upload-image ====================
    // multipart/form-data, field name "image". The CloudinaryStorage multer
    // engine already uploaded the file by the time this runs — req.file.path
    // is the resulting secure Cloudinary URL, not a local path.
    uploadImage = async (req, res) => {
        console.log('uploadImage called - headers:', req.headers);
        console.log('uploadImage - req.file:', req.file);

        if (!req.file) {
            console.warn('uploadImage: no file present on request');
            return res.status(400).json({
                error: { code: "NO_FILE", message: "image file is required" },
            });
        }

        return res.status(201).json({ url: req.file.path });
    };

    // ==================== GET /admin/specialists ====================
    listSpecialists = async (req, res) => {
        const specialists = await Specialist.find().sort({ name: 1 });
        return res.status(200).json({
            items: specialists.map((s) => ({
                id: s._id,
                name: s.name,
                role: s.role,
                image: s.image,
            })),
        });
    };
}

module.exports = new AdminController();
