const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");
const bookingController = require("../controllers/booking.controller");

router.post("/", [auth], asyncHandler(bookingController.create));
router.post("/:id/cancel", [auth], asyncHandler(bookingController.cancel));
router.post("/:id/reschedule", [auth], asyncHandler(bookingController.reschedule));

module.exports = router;
