const User = require("../models/User");
const passwordService = require("../utils/passwordService");
const formatUser = require("../utils/formatUser");
const formatService = require("../utils/formatService");

class UserController {
     getAll = async (req, res) => {
        const data = await User.find().select("-password");
        res.status(200).json({ data });
    }

    getOne = async (req, res) => {
        const id = req.params.id;
        const data = await User.findById(id).select("-password");
        if (!data) return res.status(404).json({ message: "User Not Found" });
        res.status(200).json({ data });
    }

    add = async (req, res) => {

        const { name, phone, email, password, birthDate } = req.body;

        const data = await User.create({
            name, phone, email, password, birthDate
        });

        const userObj = data.toObject();
        delete userObj.password;

        res.status(201).json({ data: userObj });
    }

    update = async (req, res) => {
        const id = req.params.id;
        const data = await User.findById(id);
        if (!data) return res.status(404).json({ message: "User Not Found" });

        const { name, phone, email, role, birthDate, avatar, available } = req.body;

        data.name = name ?? data.name;
        data.phone = phone ?? data.phone;
        data.email = email ?? data.email;
        data.role = role ?? data.role;
        data.birthDate = birthDate ?? data.birthDate;
        data.avatar = avatar ?? data.avatar;
        data.available = available ?? data.available;

        await data.save();

        const userObj = data.toObject();
        delete userObj.password;

        res.status(200).json({ data: userObj });
    }

    remove = async (req, res) => {
        const id = req.params.id;
        const data = await User.findById(id);
        if (!data) return res.status(404).json({ message: "User Not Found" });

        await User.findByIdAndDelete(id);
        res.status(200).json({ data: null });
    }

    changeRole = async (req, res) => {
        const id = req.params.id;

        const user = await User.findById(id);

        if (!user) {
            return res.status(404).json({
                message: "User Not Found"
            });
        }

        user.role = "admin";

        await user.save();

        const userObj = user.toObject();
        delete userObj.password;

        res.status(200).json({
            data: userObj
        });
    }

    // ==================== Self-service "me" endpoints ====================
    // These act on the logged-in user (req.user is set by the auth middleware).

    getMe = async (req, res) => {
        const user = await User.findById(req.user._id);
        return res.status(200).json(formatUser(user));
    }

    updateMe = async (req, res) => {
        const user = await User.findById(req.user._id);

        const { name, email, phone, birthDate } = req.body;

        if (name !== undefined) user.name = name;
        if (email !== undefined) user.email = email;
        if (phone !== undefined) user.phone = phone;
        if (birthDate !== undefined) user.birthDate = birthDate;

        await user.save();

        return res.status(200).json(formatUser(user));
    }

    // ==================== POST /me/avatar ====================
    // multipart/form-data, field name "image" — the CloudinaryStorage multer
    // engine (see routes/user.routes.js) already uploaded the file by the
    // time this runs, so req.file.path is the resulting Cloudinary URL.
    // Returns {url} to match ApiService.uploadImage's generic contract,
    // while also persisting it on the user doc here so it's a single call.
    updateMyAvatar = async (req, res) => {
        if (!req.file) {
            return res.status(400).json({
                error: { code: "NO_FILE", message: "image file is required" },
            });
        }

        const user = await User.findById(req.user._id);
        user.avatar = req.file.path;
        await user.save();

        return res.status(201).json({ url: user.avatar });
    }

    changeMyPassword = async (req, res) => {
        const { oldPassword, newPassword } = req.body;

        if (!oldPassword || !newPassword) {
            return res.status(400).json({
                error: { code: "MISSING_FIELDS", message: "oldPassword and newPassword are required." },
            });
        }

        if (newPassword.length < 8) {
            return res.status(400).json({
                error: { code: "WEAK_PASSWORD", message: "New password must be at least 8 characters." },
            });
        }

        const user = await User.findById(req.user._id).select("+password");

        const isCorrect = await passwordService.compare(oldPassword, user.password);
        if (!isCorrect) {
            return res.status(400).json({
                error: { code: "WRONG_PASSWORD", message: "Old password is incorrect." },
            });
        }

        if (oldPassword === newPassword) {
            return res.status(400).json({
                error: { code: "SAME_PASSWORD", message: "New password must be different from the old one." },
            });
        }

        user.password = await passwordService.hash(newPassword);
        await user.save();

        return res.status(200).json({ success: true });
    }

    deleteMe = async (req, res) => {
        await User.findByIdAndDelete(req.user._id);
        return res.status(204).send();
    }

    // ==================== Favorites ====================

    getFavoriteServices = async (req, res) => {
        const user = await User.findById(req.user._id).populate({
            path: "favoriteServices",
            populate: ["specialistId", "categoryId"],
        });

        const items = user.favoriteServices.map((s) => formatService(s, s.categoryId));
        return res.status(200).json({ items });
    }

    addFavoriteService = async (req, res) => {
        await User.findByIdAndUpdate(req.user._id, {
            $addToSet: { favoriteServices: req.params.serviceId },
        });
        return res.status(204).send();
    }

    removeFavoriteService = async (req, res) => {
        await User.findByIdAndUpdate(req.user._id, {
            $pull: { favoriteServices: req.params.serviceId },
        });
        return res.status(204).send();
    }

    getFavoriteCategories = async (req, res) => {
        const user = await User.findById(req.user._id).populate("favoriteCategories");
        const items = user.favoriteCategories.map((c) => ({
            id: c._id,
            title: c.name,
            image: c.image || "",
        }));
        return res.status(200).json({ items });
    }

    addFavoriteCategory = async (req, res) => {
        await User.findByIdAndUpdate(req.user._id, {
            $addToSet: { favoriteCategories: req.params.categoryId },
        });
        return res.status(204).send();
    }

    removeFavoriteCategory = async (req, res) => {
        await User.findByIdAndUpdate(req.user._id, {
            $pull: { favoriteCategories: req.params.categoryId },
        });
        return res.status(204).send();
    }
}

module.exports = new UserController();
