const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
    userId: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    },
    serviceId: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'Service', 
        required: true 
    },
    // This app's review screen only collects a comment, no star rating —
    // default it so the field stays valid without asking the client for it.
    rating: {
        type: Number,
        min: 1,
        max: 5,
        default: 5
    },
    comment: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model('Review', reviewSchema);