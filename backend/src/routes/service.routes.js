const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");
const serviceController = require("../controllers/service.controller");
const reviewController = require("../controllers/review.controller");
const bookingController = require("../controllers/booking.controller");

// Specific paths first, so they don't get swallowed by "/:id" below.
router.get("/popular", asyncHandler(serviceController.popular));
router.get("/search", asyncHandler(serviceController.search));

router.get("/:id", asyncHandler(serviceController.getById));

router.get("/:serviceId/reviews", asyncHandler(reviewController.getServiceReviews));
router.post("/:serviceId/reviews", [auth], asyncHandler(reviewController.createReview));

router.get("/:serviceId/availability", [auth], asyncHandler(bookingController.getAvailability));

module.exports = router;
