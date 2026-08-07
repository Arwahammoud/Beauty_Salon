const Category = require("../models/Category");
const Service = require("../models/Service");
const formatService = require("../utils/formatService");
const localize = require("../utils/localize");

class CategoryController {
    // ==================== GET /categories ====================
    getAll = async (req, res) => {
        const categories = await Category.find({ isActive: true }).populate("servicesCount");

        const items = categories.map((c) => ({
            id: c._id,
            title: localize(c, "name", req),
            image: c.image || "",
            servicesCount: c.servicesCount,
        }));

        return res.status(200).json({ items });
    };

    // ==================== GET /categories/:categoryId/services ====================
    getServices = async (req, res) => {
        const { categoryId } = req.params;
        const { sort } = req.query; // popular | price_asc | price_desc | quick

        const category = await Category.findById(categoryId);
        if (!category) {
            return res.status(404).json({
                error: { code: "CATEGORY_NOT_FOUND", message: "Category not found" },
            });
        }

        let query = Service.find({ categoryId, isActive: true }).populate("specialistId");

        if (sort === "price_asc") query = query.sort({ price: 1 });
        else if (sort === "price_desc") query = query.sort({ price: -1 });
        else query = query.sort({ averageRating: -1 }); // popular (default)

        let services = await query;

        if (sort === "quick") {
            services = services.filter((s) => s.duration <= 45);
        }

        const items = services.map((s) => formatService(s, category, req));

        return res.status(200).json({ items });
    };

    // ==================== Admin: GET /admin/categories ====================
    adminGetAll = async (req, res) => {
        const categories = await Category.find().populate("servicesCount");

        const items = categories.map((c) => ({
            id: c._id,
            name: c.name,
            nameAr: c.nameAr || "",
            emoji: c.emoji,
            serviceCount: c.servicesCount,
            isActive: c.isActive,
        }));

        return res.status(200).json({ items });
    };

    // ==================== Admin: POST /admin/categories ====================
    adminCreate = async (req, res) => {
        const { name, nameAr, emoji } = req.body;
        if (!name || !emoji) {
            return res.status(400).json({
                error: { code: "MISSING_FIELDS", message: "name and emoji are required" },
            });
        }

        const category = await Category.create({ name, nameAr: nameAr || "", emoji });

        return res.status(201).json({
            id: category._id,
            name: category.name,
            nameAr: category.nameAr || "",
            emoji: category.emoji,
            serviceCount: 0,
            isActive: category.isActive,
        });
    };

    // ==================== Admin: PATCH /admin/categories/:id ====================
    adminUpdate = async (req, res) => {
        const category = await Category.findById(req.params.id);
        if (!category) {
            return res.status(404).json({
                error: { code: "CATEGORY_NOT_FOUND", message: "Category not found" },
            });
        }

        const { name, nameAr, emoji, isActive } = req.body;
        if (name !== undefined) category.name = name;
        if (nameAr !== undefined) category.nameAr = nameAr;
        if (emoji !== undefined) category.emoji = emoji;
        if (isActive !== undefined) category.isActive = isActive;

        await category.save();

        return res.status(200).json({
            id: category._id,
            name: category.name,
            nameAr: category.nameAr || "",
            emoji: category.emoji,
            isActive: category.isActive,
        });
    };

    // ==================== Admin: DELETE /admin/categories/:id ====================
    // Simple policy: block the delete if services still reference this category.
    adminRemove = async (req, res) => {
        const servicesCount = await Service.countDocuments({ categoryId: req.params.id });
        if (servicesCount > 0) {
            return res.status(409).json({
                error: {
                    code: "CATEGORY_NOT_EMPTY",
                    message: "Remove or move this category's services before deleting it.",
                },
            });
        }

        await Category.findByIdAndDelete(req.params.id);
        return res.status(204).send();
    };
}

module.exports = new CategoryController();
