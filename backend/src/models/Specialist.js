const mongoose = require('mongoose');

const specialistSchema = new mongoose.Schema({
    name: { type: String, required: true },
    role: { type: String, required: true },
    image: { type: String, required: true },
    rating: { type: Number, default: 0 },
    experienceYears: { type: Number, default: 0 }
}, { timestamps: true });

module.exports = mongoose.model('Specialist', specialistSchema);
