const Service = require("../models/Service");
const Category = require("../models/Category");
const formatService = require("../utils/formatService");
const localize = require("../utils/localize");

class ServiceController {
    // ==================== GET /services/:id ====================
    getById = async (req, res) => {
        const service = await Service.findById(req.params.id).populate("specialistId");
        if (!service) {
            return res.status(404).json({
                error: { code: "SERVICE_NOT_FOUND", message: "Service not found" },
            });
        }

        const category = await Category.findById(service.categoryId);

        return res.status(200).json(formatService(service, category, req));
    };

    // ==================== GET /services/popular ====================
    popular = async (req, res) => {
        const { category } = req.query;

        const filter = { isActive: true };
        if (category) {
            const categoryDoc = await Category.findOne({ name: category });
            if (categoryDoc) filter.categoryId = categoryDoc._id;
        }

        const services = await Service.find(filter)
            .populate("specialistId")
            .populate("categoryId")
            .sort({ averageRating: -1 })
            .limit(100);

        const items = services.map((s) => formatService(s, s.categoryId, req));

        return res.status(200).json({ items });
    };

    // ==================== GET /services/search?q= ====================
    search = async (req, res) => {
        const q = (req.query.q || "").trim();
        if (!q) {
            return res.status(400).json({
                error: { code: "MISSING_QUERY", message: "q query param is required" },
            });
        }

        const regex = new RegExp(q, "i");

        const categories = await Category.find({
            isActive: true,
            $or: [{ name: regex }, { nameAr: regex }],
        }).populate("servicesCount");
        const services = await Service.find({
            isActive: true,
            $or: [{ name: regex }, { nameAr: regex }],
        }).populate("categoryId");

        return res.status(200).json({
            categories: categories.map((c) => ({
                id: c._id,
                title: localize(c, "name", req),
                image: c.image || "",
                servicesCount: c.servicesCount,
            })),
            services: services.map((s) => ({
                id: s._id,
                serviceName: localize(s, "name", req),
                categoryName: s.categoryId ? localize(s.categoryId, "name", req) : "",
                image: s.image,
                price: s.price,
            })),
        });
    };

    // ==================== Admin: GET /admin/services?categoryId= ====================
    adminGetAll = async (req, res) => {
        const { categoryId } = req.query;
        const filter = categoryId ? { categoryId } : {};

        const services = await Service.find(filter).sort({ createdAt: -1 });

        const items = services.map((s) => ({
            id: s._id,
            name: s.name,
            nameAr: s.nameAr || "",
            categoryId: s.categoryId,
            specialistId: s.specialistId,
            price: s.price,
            durationMins: s.duration,
            description: s.description,
            descriptionAr: s.descriptionAr || "",
            benefits: s.benefits,
            benefitsAr: s.benefitsAr || [],
            image: s.image,
            isActive: s.isActive,
            bookingsPerWeek: 0,
        }));

        return res.status(200).json({ items });
    };

    // ==================== Admin: POST /admin/services ====================
    // specialistId is optional here — the admin UI doesn't have a specialist
    // picker yet, so fall back to reusing one already assigned in the same
    // category rather than blocking service creation on it.
    adminCreate = async (req, res) => {
        const { name, nameAr, categoryId, price, durationMins, description, descriptionAr, image, benefits, benefitsAr } = req.body;
        let { specialistId } = req.body;

        if (!name || !categoryId || !price || !durationMins) {
            return res.status(400).json({
                error: {
                    code: "MISSING_FIELDS",
                    message: "name, categoryId, price and durationMins are required",
                },
            });
        }

        if (!specialistId) {
            const sibling = await Service.findOne({ categoryId }).select("specialistId");
            if (sibling) specialistId = sibling.specialistId;
        }

        if (!specialistId) {
            return res.status(400).json({
                error: {
                    code: "NO_SPECIALIST_AVAILABLE",
                    message: "This category has no specialist yet — provide specialistId explicitly.",
                },
            });
        }

        const service = await Service.create({
            name,
            nameAr: nameAr || "",
            categoryId,
            specialistId,
            price,
            duration: durationMins,
            description: description || "",
            descriptionAr: descriptionAr || "",
            image: image || "",
            benefits: benefits || [],
            benefitsAr: benefitsAr || [],
        });

        return res.status(201).json({
            id: service._id,
            name: service.name,
            nameAr: service.nameAr || "",
            categoryId: service.categoryId,
            price: service.price,
            durationMins: service.duration,
            description: service.description,
            descriptionAr: service.descriptionAr || "",
            benefits: service.benefits,
            benefitsAr: service.benefitsAr || [],
            isActive: service.isActive,
            bookingsPerWeek: 0,
        });
    };

    // ==================== Admin: PATCH /admin/services/:id ====================
    adminUpdate = async (req, res) => {
        const service = await Service.findById(req.params.id);
        if (!service) {
            return res.status(404).json({
                error: { code: "SERVICE_NOT_FOUND", message: "Service not found" },
            });
        }

        const { name, nameAr, categoryId, specialistId, price, durationMins, description, descriptionAr, image, benefits, benefitsAr, isActive } = req.body;

        if (name !== undefined) service.name = name;
        if (nameAr !== undefined) service.nameAr = nameAr;
        if (categoryId !== undefined) service.categoryId = categoryId;
        if (specialistId !== undefined) service.specialistId = specialistId;
        if (price !== undefined) service.price = price;
        if (durationMins !== undefined) service.duration = durationMins;
        if (description !== undefined) service.description = description;
        if (descriptionAr !== undefined) service.descriptionAr = descriptionAr;
        if (image !== undefined) service.image = image;
        if (benefits !== undefined) service.benefits = benefits;
        if (benefitsAr !== undefined) service.benefitsAr = benefitsAr;
        if (isActive !== undefined) service.isActive = isActive;

        await service.save();

        return res.status(200).json({
            id: service._id,
            name: service.name,
            nameAr: service.nameAr || "",
            categoryId: service.categoryId,
            price: service.price,
            durationMins: service.duration,
            description: service.description,
            descriptionAr: service.descriptionAr || "",
            benefits: service.benefits,
            benefitsAr: service.benefitsAr || [],
            isActive: service.isActive,
        });
    };

    // ==================== Admin: DELETE /admin/services/:id ====================
    adminRemove = async (req, res) => {
        await Service.findByIdAndDelete(req.params.id);
        return res.status(204).send();
    };
}

module.exports = new ServiceController();
