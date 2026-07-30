const express = require("express");
// ملاحظة: نستخدم { mergeParams: true } لكي يتمكن الراوتر من رؤية الـ serviceId القادم من الـ parent route (مثل /services/:serviceId/reviews)
const router = express.Router({ mergeParams: true });

const asyncHandler = require("../utils/asyncHandler");
const reviewController = require("../controllers/review.controller");
const auth = require("../middlewares/auth");

// جلب كل التقييمات لخدمة معينة (متاح للجميع)
router.get("/", asyncHandler(reviewController.getServiceReviews));

// إضافة تقييم جديد (مفعل الحماية - يتطلب تسجيل دخول)
router.post("/", auth, asyncHandler(reviewController.createReview));

module.exports = router;