const Service = require("../models/Service");

class ServiceController {
  
  getAll = async (req, res) => {
    let filter = {};
    if (req.query.categoryId) {
      filter.categoryId = req.query.categoryId;
    }

    const services = await Service.find(filter).populate("categoryId", "name");

    res.status(200).json({
      status: "success",
      results: services.length,
      data: {
        items: services,
      },
    });
  };

  getOne = async (req, res) => {
    const service = await Service.findById(req.params.id).populate("categoryId");

    if (!service) {
      return res.status(404).json({
        status: "fail",
        message: "Service not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: service,
    });
  };

 
  create = async (req, res) => {
    const service = await Service.create(req.body);

    res.status(201).json({
      status: "success",
      data: {
        service,
      },
    });
  };

 
  update = async (req, res) => {
    const service = await Service.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!service) {
      return res.status(404).json({
        status: "fail",
        message: "Service not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: {
        service,
      },
    });
  };

 
  delete = async (req, res) => {
    const service = await Service.findByIdAndDelete(req.params.id);

    if (!service) {
      return res.status(404).json({
        status: "fail",
        message: "Service not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: null,
    });
  };
}

module.exports = new ServiceController();