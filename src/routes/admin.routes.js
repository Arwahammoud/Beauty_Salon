const express = require("express");
const router = express.Router();
const adminController = require("../controllers/admin.controller");
const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");
const role = require("../middlewares/role");

// Get dashboard statistics
router.get("/dashboard/stats",[ auth, role(["admin"]) ], asyncHandler(adminController.getDashboardStats));

module.exports = router;