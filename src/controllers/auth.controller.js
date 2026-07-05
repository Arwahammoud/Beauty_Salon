const User = require("../models/User");
const cookiesService = require("../utils/cookisService");
const jwtService = require("../utils/jwtService");
const passwordService = require("../utils/passwordService");

class AuthController {
    
    // منطق حظر المستخدم عند المحاولات الفاشلة
    handleFailedLoginAttempts = async (user) => {
        user.failedLoginAttempts = +(user.failedLoginAttempts || 0) + 1;

        if (user.failedLoginAttempts >= 5) {
            user.blocked = true;
            user.lockedUntil = new Date(Date.now() + (1 * 60 * 1000)); // حظر لمدة 30 دقيقة
        }
        await user.save();
    }

    resetFailedLoginAttempts = async (user) => {
        user.blocked = false;
        user.lockedUntil = null;
        user.failedLoginAttempts = 0;
        await user.save();
    }

    // تسجيل مستخدم جديد
    register = async (req, res) => {
        console.log("arraived this data")
        const {name ,  phone, email, password } = req.body;
        console.log("111")

        const hashed = await passwordService.hash(password);

        let user = await User.create({ name, phone, email, password: hashed, role: "customer" });

        user = user.toObject();
        delete user.password;

        res.status(201).json({ user });
    }

    // تسجيل الدخول
    login = async (req, res) => {
        const { email, password } = req.body;

        let user = await User.findOne({ email });

        if (!user) {
            return res.status(400).json({ message: "Invalid Data" });
        }

        // التحقق من الحظر
        if (user.blocked) {
            if (user.lockedUntil && user.lockedUntil <= Date.now()) {
                await this.resetFailedLoginAttempts(user);
            } else {
                return res.status(400).json({ message: "You cannot login now, account is locked" });
            }
        }

        const isVerified = await passwordService.compare(password, user.password);
        if (!isVerified) {
            await this.handleFailedLoginAttempts(user);
            return res.status(400).json({ message: "Invalid Data" });
        }

        await this.resetFailedLoginAttempts(user);

        const userData = { _id: user._id, email: user.email, role: user.role };
        const token = jwtService.generateAccessToken(userData);
        const refreshToken = jwtService.generateRefreshToken(userData);

        cookiesService.setAccessToken(res, token);
        cookiesService.setRefreshToken(res, refreshToken);

        user = user.toObject();
        delete user.password;
        res.status(201).json({ user });
    }

    // تسجيل الخروج
    logout = async (req, res) => {
        cookiesService.clearTokens(res);
        res.status(200).json({ message: "Logged out Successfully" });
    }

    // بروفايل المستخدم
    profile = async (req, res) => {
        if (!req._user) {
            return res.status(200).json({ data: null });
        }

        const user = await User.findById(req._user._id).select("-password");
        res.status(200).json({ data: user });
    }

    // تجديد التوكن
    refreshToken = async (req, res) => {
        const refreshToken = cookiesService.getRefreshToken(req);

        if (!refreshToken) {
            return res.status(401).json({ message: "Refresh Token Required" });
        }

        const decoded = jwtService.verifyRefreshToken(refreshToken);
        const data = { _id: decoded._id, email: decoded.email, role: decoded.role };

        const token = jwtService.generateAccessToken(data);
        const refToken = jwtService.generateRefreshToken(data);
        
        cookiesService.setAccessToken(res, token);
        cookiesService.setRefreshToken(res, refToken);

        res.status(200).json({ message: "Refreshed Token Successfully" });
    }
}

module.exports = new AuthController();