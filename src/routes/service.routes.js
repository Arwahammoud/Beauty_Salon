const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler");
const serviceController = require("../controllers/service.controller");
const auth = require("../middlewares/auth");
const role = require("../middlewares/role");

router.get("/", asyncHandler(serviceController.getAll));
router.get("/:id", asyncHandler(serviceController.getOne));

router.post("/", [auth, role("admin")], asyncHandler(serviceController.create));
router.patch("/:id",[ auth, role("admin")], asyncHandler(serviceController.update));
router.delete("/:id", [auth, role("admin")], asyncHandler(serviceController.delete));

module.exports = router;