const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema({
    name: { type: String, required: true },
    nameAr: { type: String, default: '' },
    // The admin "add service" screen has no description/image fields yet,
    // so these can't be required or every create from that screen would fail.
    description: { type: String, default: '' },
    descriptionAr: { type: String, default: '' },
    price: { type: Number, required: true },
    duration: { type: Number, required: true }, // duration in minutes

    // ربط الخدمة بالقسم
    categoryId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category',
        required: true
    },

    specialistId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Specialist',
        required: true
    },

    image: { type: String, default: '' },
    benefits: [{ type: String }],
    benefitsAr: [{ type: String }],

    averageRating: { type: Number, default: 0 },
    reviewsCount: { type: Number, default: 0 },

    isActive: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model('Service', serviceSchema);