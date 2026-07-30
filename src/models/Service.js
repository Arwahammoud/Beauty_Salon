const mongoose = require("mongoose");

const serviceSchema = new mongoose.Schema(
  {
    serviceName: {
      type: String,
      required: [true, "Service name is required"],
      trim: true,
    },
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      required: [true, "Service must belong to a category"],
    },
    price: {
      type: Number,
      required: [true, "Service price is required"],
    },
    duration: {
      type: String, // مثل "45 min"
      required: true,
       default: 30
    },
    durationMins: {
      type: Number, // مثل 45 (ليسهل الحساب والفلترة بالفرونت إند)
      required: true,
    },
    image: {
      type: String,
    },
    about: {
      type: String,
    },
    benefits: [String], // مصفوفة فوائد الخدمة
    rating: {
      type: Number,
      default: 4.8,
    },
    reviewsCount: {
      type: Number,
      default: 0,
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

module.exports = mongoose.model("Service", serviceSchema);