const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    phone: {
        type: String,
        default: null
    },
    email: {
        type: String,
        unique: true,
        required: true
    }, 
    password: {
        type: String,
        required: true
    },
    passwordResetToken: {
      type: String,
      default: null,
      select: false,
    },

    passwordResetExpires: {
      type: Date,
      default: null,
      select: false,
    },
    avatar: {
        type: String
    },
    available: Boolean,
    role: {
        type: String,
        enum: ["customer" , "admin"],
        default: "customer"
    },
    isActive : {
        type : Boolean ,
        default : true
    },
    birthDate: { type: Date, default: null },
    loyaltyPoints: {
        type: Number,
        default: 0
    },
    favoriteServices: [{ type: mongoose.Schema.Types.ObjectId, ref: "Service" }],
    favoriteCategories: [{ type: mongoose.Schema.Types.ObjectId, ref: "Category" }],
    // block mechanism to sometime if he get failed 5 times
    blocked: { 
        type: Boolean,
        default: false
    },
    failedLoginAttempts: {
        type: Number,
        default: 0
    },
    lockedUntil: Date
}, { timestamps: true })

module.exports = mongoose.model("User", userSchema);
