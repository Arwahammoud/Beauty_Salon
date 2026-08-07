const mongoose = require('mongoose');

// Generic key/value store for small admin-configurable settings (e.g. the
// Gemini API key) that shouldn't live in a .env file that has to be edited
// by hand and redeployed.
const settingSchema = new mongoose.Schema({
    key: { type: String, required: true, unique: true },
    value: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model('Setting', settingSchema);
