const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler");
const categoryController = require("../controllers/category.controller");

// Public
router.get("/", asyncHandler(categoryController.getAll));
router.get("/:categoryId/services", asyncHandler(categoryController.getServices));

module.exports = router;
