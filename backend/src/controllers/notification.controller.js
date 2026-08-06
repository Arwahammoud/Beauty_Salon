const Notification = require("../models/Notification");

class NotificationController {
    // ==================== GET /users/me/notifications ====================
    getMine = async (req, res) => {
        const notifications = await Notification.find({ userId: req.user._id }).sort({ createdAt: -1 });

        const items = notifications.map((n) => ({
            id: n._id,
            title: n.title,
            body: n.body,
            icon: n.icon,
            read: n.read,
            createdAt: n.createdAt,
        }));

        return res.status(200).json({ items });
    };

    // ==================== POST /users/me/notifications/:id/read ====================
    markRead = async (req, res) => {
        await Notification.updateOne(
            { _id: req.params.id, userId: req.user._id },
            { $set: { read: true } },
        );
        return res.status(204).send();
    };
}

module.exports = new NotificationController();
