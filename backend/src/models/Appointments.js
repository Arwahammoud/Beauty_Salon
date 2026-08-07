const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
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
    date: { type: Date, required: true }, 
    startTime: { type: String, required: true }, 
    endTime: { type: String, required: true },   
    status: { 
        type: String, 
        enum: ['pending', 'confirmed', 'completed', 'cancelled'], 
        default: 'pending' 
    },
    totalPrice: { type: Number, required: true }
}, { timestamps: true });

module.exports = mongoose.model('Appointment', appointmentSchema);