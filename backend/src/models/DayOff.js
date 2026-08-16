const mongoose = require('mongoose');

// A day off blocks an entire day from new bookings — either for the whole
// salon (specialistId is null) or for one specific specialist only.
const dayOffSchema = new mongoose.Schema({
    date: { type: Date, required: true },
    specialistId: { type: mongoose.Schema.Types.ObjectId, ref: 'Specialist', default: null },
    note: { type: String, default: "" },
}, { timestamps: true });

dayOffSchema.index({ date: 1, specialistId: 1 }, { unique: true });

module.exports = mongoose.model('DayOff', dayOffSchema);
