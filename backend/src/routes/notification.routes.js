const express = require("express");
const router = express.Router();
const notificationController = require("../controllers/notification.controller");
const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");

// مسارات محمية تتطلب تسجيل دخول
router.use(auth);

// جلب إشعارات المستخدم
router.get("/", asyncHandler(notificationController.getUserNotifications));

// تحديد إشعار كمقروء
router.patch("/:id/read", asyncHandler(notificationController.markAsRead));

// إرسال إشعار جديد (للأدمين)
router.post("/", asyncHandler(notificationController.createNotification));

module.exports = router;