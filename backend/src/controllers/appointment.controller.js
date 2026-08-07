const Appointment = require("../models/Appointments");
const Service = require("../models/Service");
const User = require("../models/User");

class AppointmentController {
  
  // @desc    فحص الأوقات المتاحة للخدمة في تاريخ معين
  getAvailability = async (req, res) => {
    const { serviceId, date } = req.query;

    if (!serviceId || !date) {
      return res.status(400).json({ status: "fail", message: "Please provide serviceId and date" });
    }

    const service = await Service.findById(serviceId);
    if (!service) return res.status(404).json({ message: "Service not found" });

    const duration = service.durationMins || 30; // الاعتماد على حقل مدة الخدمة بالدقائق

    // 2. تحديد ساعات عمل الصالون (من 10:00 صباحاً حتى 20:00 مساءً)
    const openHour = 10;
    const closeHour = 20;
    const allSlots = [];

    let currentMinutes = openHour * 60;
    const endMinutes = closeHour * 60;

    while (currentMinutes + duration <= endMinutes) {
      const hours = Math.floor(currentMinutes / 60).toString().padStart(2, '0');
      const mins = (currentMinutes % 60).toString().padStart(2, '0');
      allSlots.push(`${hours}:${mins}`);
      currentMinutes += 30; // القفز نصف ساعة لتوليد خيارات مرنة
    }

    // 3. جلب كافة المواعيد غير الملغاة في هذا التاريخ
    const existingAppointments = await Appointment.find({
      date: new Date(date),
      status: { $ne: "cancelled" }
    });

    // 4. خوارزمية الفحص لكل فترة زمنية مقترحة
    const availableSlots = allSlots.map((startTime) => {
      const [sh, sm] = startTime.split(":").map(Number);
      const startMin = sh * 60 + sm;
      const endMin = startMin + duration;

      let overlappingCount = 0;

      existingAppointments.forEach(app => {
        const [ash, asm] = app.startTime.split(":").map(Number);
        const [aeh, aem] = app.endTime.split(":").map(Number);
        const appStartMin = ash * 60 + asm;
        const appEndMin = aeh * 60 + aem;

        // فحص التعارض الزمني
        if (startMin < appEndMin && endMin > appStartMin) {
          overlappingCount++;
        }
      });

      // الوقت متاح إذا كان عدد المحجوزين أقل من إجمالي عدد الأخصائيين (2)
      return {
        time: startTime,
        isAvailable: overlappingCount < 2
      };
    });

    res.status(200).json({
      status: "success",
      date,
      serviceDurationMinutes: duration,
      items: availableSlots,
    });
  };

  // =================================================

  // @desc    إنشاء حجز جديد
  // @route   POST /api/v1/appointments
  createAppointment = async (req, res) => {
    const { serviceId, date, startTime, endTime } = req.body;

    const service = await Service.findById(serviceId);
    if (!service) {
      return res.status(404).json({ status: "fail", message: "Service not found" });
    }

    const totalPrice = service.price;
    const pointsEarned = Math.round(totalPrice / 10);

    const appointment = await Appointment.create({
      userId: req.user._id,
      serviceId,
      date,
      startTime,
      endTime,
      totalPrice,
    });

    await User.findByIdAndUpdate(req.user._id, {
      $inc: { loyaltyPoints: pointsEarned },
    });

    res.status(201).json({
      status: "success",
      data: appointment,
    });
  };

  // @desc    جلب حجوزات المستخدم الحالي
  // @route   GET /api/v1/appointments/me
  getUserAppointments = async (req, res) => {
    let filter = { userId: req.user._id };
    if (req.query.status) {
      filter.status = req.query.status.toLowerCase();
    }

    const appointments = await Appointment.find(filter).populate("serviceId");

    res.status(200).json({
      status: "success",
      results: appointments.length,
      items: appointments,
    });
  };
  // @route   PATCH /api/v1/appointments/:id/cancel
  cancelAppointment = async (req, res) => {
    const appointment = await Appointment.findOne({ 
      _id: req.params.id, 
      userId: req.user._id 
    });
    
    if (!appointment) {
      return res.status(404).json({ status: "fail", message: "Appointment not found" });
    }

    appointment.status = "cancelled";
    await appointment.save();

    res.status(200).json({
      status: "success",
      message: "Appointment cancelled successfully",
    });
  };
}

module.exports = new AppointmentController();