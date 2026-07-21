const cookiesService = require("../utils/cookisService");
const jwtService = require("../utils/jwtService");

const optionalAuth = (req, res, next) => {
    try {
        const token = cookiesService.getData(req, "accessToken");
        if (token) {
            req.user = { ...jwtService.verify(token) };
        }
    } catch {
        req.user = null;
    }
    next();
};

module.exports = optionalAuth;