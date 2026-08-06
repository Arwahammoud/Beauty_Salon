const express = require("express");
const router = express.Router();
const chatController = require("../controllers/chat.controller");
const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");

router.use(auth);

router.get("/", asyncHandler(chatController.getChatHistory));
router.post("/", asyncHandler(chatController.sendMessage));

module.exports = router;