const Notification = require("../models/Notifications");

class NotificationController {
  // @desc    جلب إشعارات المستخدم الحالي
  // @route   GET /api/v1/notifications
  getUserNotifications = async (req, res) => {
    const notifications = await Notification.find({ userId: req.user._id }).sort({ createdAt: -1 });

    res.status(200).json({
      status: "success",
      results: notifications.length,
      items: notifications,
    });
  };

  // @desc    تحديد إشعار كمقروء
  // @route   PATCH /api/v1/notifications/:id/read
  markAsRead = async (req, res) => {
    const notification = await Notification.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!notification) {
      return res.status(404).json({ status: "fail", message: "Notification not found" });
    }

    notification.isRead = true;
    await notification.save();

    res.status(200).json({
      status: "success",
      message: "Notification marked as read",
    });
  };

  // @desc    إرسال إشعار لمستخدم (خاص بالأدمين أو النظام)
  // @route   POST /api/v1/notifications
  createNotification = async (req, res) => {
    const { userId, title, message, type } = req.body;

    const notification = await Notification.create({
      userId,
      title,
      message,
      type,
    });

    res.status(201).json({
      status: "success",
      data: notification,
    });
  };
}

module.exports = new NotificationController();