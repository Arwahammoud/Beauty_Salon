const express = require("express");
const router = express.Router();
const multer = require("multer");

const asyncHandler = require("../utils/asyncHandler")
const userController = require("../controllers/user.controller");
const bookingController = require("../controllers/booking.controller");
const notificationController = require("../controllers/notification.controller");
const auth = require("../middlewares/auth");
const role = require("../middlewares/role");
const { deleteUserValidation } = require("../validations/users.validate");

// Avatars are stored as base64 directly on the user document — Cloudinary is
// configured (see config/cloudinary.js) but CLOUDINARY_API_KEY is currently
// blank in .env, so uploads through it fail. Switch back once that's set.
// No format allowlist here — desktop file pickers often report a generic
// mimetype/extension, and this is a private, size-capped, self-only upload.
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 },
});

// ==================== "me" routes (must come before /:id) ====================

router.get("/me", [auth], asyncHandler(userController.getMe));
router.patch("/me", [auth], asyncHandler(userController.updateMe));
router.delete("/me", [auth], asyncHandler(userController.deleteMe));
router.post("/me/change-password", [auth], asyncHandler(userController.changeMyPassword));
router.post("/me/avatar", [auth], upload.single("image"), asyncHandler(userController.updateMyAvatar));

router.get("/me/bookings", [auth], asyncHandler(bookingController.myBookings));

router.get("/me/favorites/services", [auth], asyncHandler(userController.getFavoriteServices));
router.put("/me/favorites/services/:serviceId", [auth], asyncHandler(userController.addFavoriteService));
router.delete("/me/favorites/services/:serviceId", [auth], asyncHandler(userController.removeFavoriteService));

router.get("/me/favorites/categories", [auth], asyncHandler(userController.getFavoriteCategories));
router.put("/me/favorites/categories/:categoryId", [auth], asyncHandler(userController.addFavoriteCategory));
router.delete("/me/favorites/categories/:categoryId", [auth], asyncHandler(userController.removeFavoriteCategory));

router.get("/me/notifications", [auth], asyncHandler(notificationController.getMine));
router.post("/me/notifications/:id/read", [auth], asyncHandler(notificationController.markRead));

// ==================== Admin-only user management ====================

router.get("/", [ auth, role(["admin"])],asyncHandler(userController.getAll));

router.get("/:id", [ auth, role(["admin"])], asyncHandler(userController.getOne));

router.post("/", [auth, role(["admin"])], asyncHandler(userController.add));

router.put("/:id",  [ auth, role(["admin"])], asyncHandler(userController.update));

router.delete("/:id", [...deleteUserValidation], asyncHandler(userController.remove));

router.put("/:id/role" ,[ auth, role(["admin"]) ], asyncHandler(userController.changeRole));

module.exports = router;
