const User = require("../models/User");

class FavoriteController {

  getFavoriteServices = async (req, res) => {
    const user = await User.findById(req.user._id).populate("favorites");

    res.status(200).json({
      status: "success",
      items: user.favorites || [],
    });
  };

  addFavoriteService = async (req, res) => {
    await User.findByIdAndUpdate(req.user._id, {
      $addToSet: { favorites: req.params.serviceId },
    });

    res.status(204).send();
  };

  
  removeFavoriteService = async (req, res) => {
    await User.findByIdAndUpdate(req.user._id, {
      $pull: { favorites: req.params.serviceId },
    });

    res.status(204).send();
  };
}

module.exports = new FavoriteController();