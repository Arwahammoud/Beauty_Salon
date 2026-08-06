const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");
const chatController = require("../controllers/chat.controller");

router.post("/message", [auth], asyncHandler(chatController.sendMessage));

module.exports = router;
