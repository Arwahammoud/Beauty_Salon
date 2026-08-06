const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler");
const supportController = require("../controllers/support.controller");

router.get("/faqs", asyncHandler(supportController.getFaqs));
router.get("/business-hours", asyncHandler(supportController.getBusinessHours));

module.exports = router;
