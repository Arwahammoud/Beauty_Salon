const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler");
const categoryController = require("../controllers/category.controller");  
const auth = require("../middlewares/auth");
const role = require("../middlewares/role");

router.get("/", asyncHandler(categoryController.getAll));

router.get("/:id", asyncHandler(categoryController.getOne));

router.post("/",[auth, role("admin")],asyncHandler(categoryController.create));

router.put("/:id", [auth,role("admin")],asyncHandler(categoryController.update));

router.delete("/:id",[auth,role("admin")],asyncHandler(categoryController.delete)
);

module.exports = router;