const express = require("express");
const router = express.Router();
const offerController = require("../controllers/offer.controller");
const asyncHandler = require("../utils/asyncHandler");

// جلب العروض الفعالة للزبائن
router.get("/", asyncHandler(offerController.getActiveOffers));

// إضافة عرض جديد (أدمين)
router.post("/", asyncHandler(offerController.createOffer));

// حذف عرض (أدمين)
router.delete("/:id", asyncHandler(offerController.deleteOffer));

module.exports = router;