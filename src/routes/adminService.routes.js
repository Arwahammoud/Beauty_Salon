const express = require("express");
const router = express.Router();
const adminServiceController = require("../controllers/adminService.controller");
const asyncHandler = require("../utils/asyncHandler");
const auth = require("../middlewares/auth");
const role = require("../middlewares/role");


// Categories CRUD[span_2](start_span)[span_2](end_span)
router.get("/categories",[ auth, role(["admin"]) ], asyncHandler(adminServiceController.getCategories));
router.post("/categories",[ auth, role(["admin"]) ], asyncHandler(adminServiceController.createCategory));
router.patch("/categories/:id",[ auth, role(["admin"]) ], asyncHandler(adminServiceController.updateCategory));
router.delete("/categories/:id",[ auth, role(["admin"]) ], asyncHandler(adminServiceController.deleteCategory));

// Services CRUD[span_3](start_span)[span_3](end_span)
router.get("/services",[ auth, role(["admin"]) ], asyncHandler(adminServiceController.getAdminServices));
router.post("/services",[ auth, role(["admin"]) ], asyncHandler(adminServiceController.createService));
router.patch("/services/:id", [ auth, role(["admin"]) ],asyncHandler(adminServiceController.updateService));
router.delete("/services/:id",[ auth, role(["admin"]) ], asyncHandler(adminServiceController.deleteService));

module.exports = router;