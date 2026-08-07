const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        unique: true
    },
    nameAr: {
        type: String,
        default: '',
    },
    image: {
        type: String, 
        required: true 
    },
    isActive: { 
        type: Boolean, 
        default: true 
    }
}, { timestamps: true });

// إضافة : لنحسب عدد الخدمات تلقائياً عند طلب القسم
categorySchema.virtual('servicesCount', {
    ref: 'Service',
    localField: '_id',
    foreignField: 'categoryId',
    count: true
});

module.exports = mongoose.model('Category', categorySchema);