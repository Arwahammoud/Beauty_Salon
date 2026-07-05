const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    }, 
    phone: {
        type: String,
        unique: [true, "Phone must be unique"],
        required: true
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
    avatar: {
        type: String
    },
    available: Boolean,
    role: {
        type: "String",
        enum: ["customer" , "admin"],
        default: "customer"
    },
    dateOfBirth: { type: Date },
    points:{
        type :Number,
        default :0
    },
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
