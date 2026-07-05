const cookiesService = require("../utils/cookisService");
const jwtService = require("../utils/jwtService");

const optionalAuth = (req, res, next) => {
    try {
        const token = cookiesService.getData(req, "accessToken");
        if (token) {
            req._user = { ...jwtService.verify(token) };
        }
    } catch {
        req._user = null;
    }
    next();
};

module.exports = optionalAuth;