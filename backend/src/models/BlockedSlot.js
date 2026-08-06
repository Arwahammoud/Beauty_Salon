const mongoose = require('mongoose');

// A blocked slot is an hour on a given day the admin manually closed for booking
// (e.g. lunch break, day off). Booked slots are NOT stored here — they are
// derived from real Appointments, so this collection only needs to remember
// what the admin blocked on purpose.
const blockedSlotSchema = new mongoose.Schema({
    date: { type: Date, required: true },
    hour: { type: Number, required: true }
}, { timestamps: true });

blockedSlotSchema.index({ date: 1, hour: 1 }, { unique: true });

module.exports = mongoose.model('BlockedSlot', blockedSlotSchema);
