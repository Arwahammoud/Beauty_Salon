// Reads the Accept-Language header the Flutter app sends on every request
// (see frontend/lib/services/api_service.dart) and exposes the resolved
// language as req.lang ('ar' | 'en'), which localize() and formatService()
// already rely on.
const lang = (req, res, next) => {
    const header = req.headers["accept-language"] || "";
    req.lang = header.toLowerCase().startsWith("ar") ? "ar" : "en";
    next();
};

module.exports = lang;
