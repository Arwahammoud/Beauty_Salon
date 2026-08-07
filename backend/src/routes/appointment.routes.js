const express = require("express");
const router = express.Router();
const appointmentController = require("../controllers/appointment.controller");
const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");

// جلب حجوزات المستخدم الحالي
router.get("/me", auth, asyncHandler(appointmentController.getUserAppointments));

// إنشاء حجز جديد
router.post("/", auth, asyncHandler(appointmentController.createAppointment));

// إلغاء حجز
router.patch("/:id/cancel", auth, asyncHandler(appointmentController.cancelAppointment));

module.exports = router;