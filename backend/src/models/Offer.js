const mongoose = require('mongoose');

const offerSchema = new mongoose.Schema({
    badge: { type: String, default: 'LIMITED' },
    title: { type: String, required: true },
    titleAr: { type: String, default: '' },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    discountLabel: { type: String, required: true },
    discountLabelAr: { type: String, default: '' },
    image: { type: String, required: true },
    serviceId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Service',
        required: true
    },
    isActive: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model('Offer', offerSchema);
