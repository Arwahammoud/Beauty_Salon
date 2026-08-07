const express = require("express");
const router = express.Router();
const favoriteController = require("../controllers/favorite.controller");
const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");

// مسارات المفضلة للخدمات (محمية تتطلب تسجيل دخول)
router.get("/services",auth ,asyncHandler(favoriteController.getFavoriteServices));

router.put("/services/:serviceId",auth ,asyncHandler(favoriteController.addFavoriteService));

router.delete("/services/:serviceId",auth ,asyncHandler(favoriteController.removeFavoriteService));

module.exports = router;