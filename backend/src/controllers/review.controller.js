const Review = require("../models/Review");
const Service = require("../models/Service");

class ReviewController {
    // ==================== GET /services/:serviceId/reviews ====================
    getForService = async (req, res) => {
        const reviews = await Review.find({ serviceId: req.params.serviceId })
            .populate("userId")
            .sort({ createdAt: -1 });

        const items = reviews.map((r) => ({
            id: r._id,
            userName: r.userId ? r.userId.name : "Anonymous",
            comment: r.comment,
            createdAt: r.createdAt,
        }));

        return res.status(200).json({ items });
    };

    // ==================== POST /services/:serviceId/reviews ====================
    create = async (req, res) => {
        const { comment } = req.body;
        if (!comment || !comment.trim()) {
            return res.status(400).json({
                error: { code: "MISSING_COMMENT", message: "comment is required" },
            });
        }

        const service = await Service.findById(req.params.serviceId);
        if (!service) {
            return res.status(404).json({
                error: { code: "SERVICE_NOT_FOUND", message: "Service not found" },
            });
        }

        const review = await Review.create({
            userId: req.user._id,
            serviceId: service._id,
            comment: comment.trim(),
        });

        await Service.findByIdAndUpdate(service._id, { $inc: { reviewsCount: 1 } });

        return res.status(201).json({
            id: review._id,
            userName: req.user.name,
            comment: review.comment,
            createdAt: review.createdAt,
        });
    };
}

module.exports = new ReviewController();
