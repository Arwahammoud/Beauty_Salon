const express = require("express");
const router = express.Router();
const multer = require("multer");

const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");
const role = require("../middlewares/role");
const { storage } = require("../config/cloudinary");

const adminController = require("../controllers/admin.controller");
const categoryController = require("../controllers/category.controller");
const serviceController = require("../controllers/service.controller");
const bookingController = require("../controllers/booking.controller");

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    // Some devices send a generic mimetype (e.g. application/octet-stream)
    // for gallery picks, so fall back to the file extension — Cloudinary's
    // own allowed_formats still rejects anything that isn't really an image.
    fileFilter: (req, file, cb) => cb(
        null,
        file.mimetype.startsWith("image/") || /\.(jpe?g|png|webp|gif|heic|heif)$/i.test(file.originalname || "")
    ),
});

// Every route below requires a logged-in admin.
router.use(auth, role(["admin"]));

// Dashboard
router.get("/dashboard/stats", asyncHandler(adminController.dashboardStats));

// Categories
router.get("/categories", asyncHandler(categoryController.adminGetAll));
router.post("/categories", asyncHandler(categoryController.adminCreate));
router.patch("/categories/:id", asyncHandler(categoryController.adminUpdate));
router.delete("/categories/:id", asyncHandler(categoryController.adminRemove));

// Services
router.get("/services", asyncHandler(serviceController.adminGetAll));
router.post("/services", asyncHandler(serviceController.adminCreate));
router.patch("/services/:id", asyncHandler(serviceController.adminUpdate));
router.delete("/services/:id", asyncHandler(serviceController.adminRemove));

// Bookings
router.get("/bookings", asyncHandler(bookingController.adminList));
router.patch("/bookings/:id", asyncHandler(bookingController.adminUpdateBooking));
router.patch("/bookings/:id/status", asyncHandler(bookingController.adminUpdateStatus));

// Specialists (read-only picker for the service form / booking edit)
router.get("/specialists", asyncHandler(adminController.listSpecialists));

// Media
router.post("/upload-image", upload.single("image"), asyncHandler(adminController.uploadImage));

// Availability
router.get("/availability", asyncHandler(adminController.getAvailability));
router.patch("/availability", asyncHandler(adminController.setAvailability));

// Day off (whole-salon or per-specialist)
router.get("/day-off", asyncHandler(adminController.listDayOffs));
router.post("/day-off", asyncHandler(adminController.createDayOff));
router.delete("/day-off/:id", asyncHandler(adminController.deleteDayOff));

// Settings (Gemini chat API key)
router.get("/settings/gemini-key", asyncHandler(adminController.getGeminiKeyStatus));
router.put("/settings/gemini-key", asyncHandler(adminController.setGeminiKey));

module.exports = router;
