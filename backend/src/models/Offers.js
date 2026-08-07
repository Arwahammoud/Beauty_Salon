const mongoose = require("mongoose");

const offerSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, "Offer title is required"],
      trim: true,
    },
    description: {
      type: String,
      required: [true, "Offer description is required"],
    },
    image: {
      type: String,
      required: [true, "Offer image is required"],
    },
    discountPercentage: {
      type: Number,
      required: [true, "Discount percentage is required"], // مثلاً 20 يعني 20%
    },
    expiryDate: {
      type: Date,
      required: [true, "Expiry date is required"],
    },
    startDate: {
      type: Date,
      default: Date.now,
    },
    badge: {
      type: String,
      default: "LIMITED",
    },
    serviceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      transform: (doc, ret) => {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

module.exports = mongoose.model("Offer", offerSchema);