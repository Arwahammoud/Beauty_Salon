const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler")
const id = require("../middlewares/id");
const userController = require("../controllers/user.controller");
const auth = require("../middlewares/auth");
const role = require("../middlewares/role");
const { deleteUserValidation } = require("../validations/users.validate");

router.get("/", [ auth, role(["admin"])],asyncHandler(userController.getAll));

router.get("/:id", [id], asyncHandler(userController.getOne));

router.post("/", [auth, role(["Admin"])], asyncHandler(userController.add));

router.put("/:id", [id], asyncHandler(userController.update));

router.delete("/:id", [...deleteUserValidation], asyncHandler(userController.remove));

router.put("/:id/role" ,[ auth, role(["admin"]) ], asyncHandler(userController.changeRole)); 

module.exports = router;