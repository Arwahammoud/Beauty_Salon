const express = require("express");
const router = express.Router();

const asyncHandler = require("../utils/asyncHandler")
const userController = require("../controllers/user.controller");
const auth = require("../middlewares/auth");
const role = require("../middlewares/role");
const { deleteUserValidation } = require("../validations/users.validate");

// Get all users ( Admin)
router.get("/", [ auth, role(["admin"])],asyncHandler(userController.getAll));

// Get user by ID (Admin)
router.get("/:id", [ auth, role(["admin"])], asyncHandler(userController.getOne));

router.post("/", [auth, role(["admin"])], asyncHandler(userController.add));

router.put("/:id",  [ auth, role(["admin"])], asyncHandler(userController.update));

router.delete("/:id", [...deleteUserValidation], asyncHandler(userController.remove));

router.put("/:id/role" ,[ auth, role(["admin"]) ], asyncHandler(userController.changeRole)); 

module.exports = router;