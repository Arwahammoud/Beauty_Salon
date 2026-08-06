const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler");
const offerController = require("../controllers/offer.controller");

router.get("/", asyncHandler(offerController.getAll));

module.exports = router;
