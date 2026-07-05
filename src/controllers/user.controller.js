const User = require("../models/User");

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
    
        const { name, phone, email, password, dateOfBirth } = req.body;
        
        const data = await User.create({ 
            name, phone, email, password, dateOfBirth 
        });
      
        const userObj = data.toObject();
        delete userObj.password;
        
        res.status(201).json({ data: userObj });
    }

    update = async (req, res) => {
        const id = req.params.id;
        const data = await User.findById(id);
        if (!data) return res.status(404).json({ message: "User Not Found" });
        
        const { name, phone, email, role, dateOfBirth, avatar, available } = req.body;
        
        data.name = name ?? data.name;
        data.phone = phone ?? data.phone;
        data.email = email ?? data.email;
        data.role = role ?? data.role;
        data.dateOfBirth = dateOfBirth ?? data.dateOfBirth;
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
}

module.exports = new UserController();