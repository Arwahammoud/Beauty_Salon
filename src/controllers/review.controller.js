const Review = require("../models/Review");

class ReviewController {
 
  getServiceReviews = async (req, res) => {
    const reviews = await Review.find({ service: req.params.serviceId });

    res.status(200).json({
      status: "success",
      results: reviews.length,
      items: reviews, 
    });
  };

  
  createReview = async (req, res) => {
    const { comment } = req.body;
    
    const review = await Review.create({
      service: req.params.serviceId,
      user: req.user._id,
      userName: req.user.name, 
      comment,
    });

    res.status(201).json({
      status: "success",
      data: review,
    });
  };
}

module.exports = new ReviewController();