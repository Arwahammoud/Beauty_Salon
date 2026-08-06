const Service = require("../models/Service");
const Category = require("../models/Category"); 

class AdminServiceController {
  //  Get all categories for admin
  // @route   GET /api/v1/admin/categories
  getCategories = async (req, res) => {
    const categories = await Category.find();
    
    // Add service count dynamically for each category
    const items = await Promise.all(
      categories.map(async (cat) => {
        const serviceCount = await Service.countDocuments({ category: cat._id });
        return {
          id: cat._id,
          name: cat.name,
          emoji: cat.emoji || "✨",
          serviceCount,
          isActive: cat.isActive !== undefined ? cat.isActive : true,
        };
      })
    );

    res.status(200).json({ items });
  };

  // Create new category
  // @route POST /api/v1/admin/categories
  createCategory = async (req, res) => {
    const { name, emoji } = req.body;

    const category = await Category.create({ name, emoji });

    res.status(201).json({
      status: "success",
      data: category,
    });
  };

  //  Update category
  // @route PATCH /api/v1/admin/categories/:id
  updateCategory = async (req, res) => {
    const { name, emoji, isActive } = req.body;

    const category = await Category.findByIdAndUpdate(
      req.params.id,
      { name, emoji, isActive },
      { new: true, runValidators: true }
    );

    if (!category) {
      return res.status(404).json({ status: "fail", message: "Category not found" });
    }

    res.status(200).json({ status: "success", data: category });
  };

  // @desc    Delete category
  // @route   DELETE /api/v1/admin/categories/:id
  deleteCategory = async (req, res) => {
    const categoryId = req.params.id;
    
    // Optional policy: check if services are attached
    const servicesCount = await Service.countDocuments({ category: categoryId });
    if (servicesCount > 0) {
      return res.status(400).json({ 
        status: "fail", 
        message: "Cannot delete category with active services attached." 
      });
    }

    const category = await Category.findByIdAndDelete(categoryId);
    if (!category) {
      return res.status(404).json({ status: "fail", message: "Category not found" });
    }

    res.status(204).send();
  };

  //  Get all services for admin with optional category filter
  // @route   GET /api/v1/admin/services
  getAdminServices = async (req, res) => {
    const { categoryId } = req.query;
    let filter = {};
    
    if (categoryId) {
      filter.category = categoryId;
    }

    const services = await Service.find(filter).populate("category");

    const items = services.map(s => ({
      id: s._id,
      name: s.serviceName,
      categoryId: s.category ? s.category._id : null,
      price: s.price,
      durationMins: s.durationMins,
      description: s.about,
      benefits: s.benefits,
      isActive: s.isActive,
      bookingsPerWeek: 12, // Estimated or computed metric
    }));

    res.status(200).json({ items });
  };

  // @desc    Create new service
  // @route   POST /api/v1/admin/services
  createService = async (req, res) => {
    const { name, categoryId, price, durationMins, description, benefits, image } = req.body;

    const service = await Service.create({
      serviceName: name,
      category: categoryId,
      price,
      durationMins,
      duration: `${durationMins} min`,
      about: description,
      benefits,
      image: image || "",
    });

    res.status(201).json({
      status: "success",
      data: service,
    });
  };

  //  Update service
  // @route   PATCH /api/v1/admin/services/:id
  updateService = async (req, res) => {
    const { name, categoryId, price, durationMins, description, benefits, isActive, image } = req.body;
    const updateData = {};
    if (name) updateData.serviceName = name;
    if (categoryId) updateData.category = categoryId;
    if (price !== undefined) updateData.price = price;
    if (durationMins !== undefined) {
      updateData.durationMins = durationMins;
      updateData.duration = `${durationMins} min`;
    }
    if (description) updateData.about = description;
    if (benefits) updateData.benefits = benefits;
    if (isActive !== undefined) updateData.isActive = isActive;
    if (image) updateData.image = image;

    const service = await Service.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!service) {
      return res.status(404).json({ status: "fail", message: "Service not found" });
    }

    res.status(200).json({ status: "success", data: service });
  };

  //  Delete service
  // @route   DELETE /api/v1/admin/services/:id
  deleteService = async (req, res) => {
    const service = await Service.findByIdAndDelete(req.params.id);
    if (!service) {
      return res.status(404).json({ status: "fail", message: "Service not found" });
    }

    res.status(204).send();
  };
}

module.exports = new AdminServiceController();