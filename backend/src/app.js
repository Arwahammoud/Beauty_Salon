require("dotenv").config();
const express = require("express");
const app = express();
const { default: mongoose } = require("mongoose");
const notFound = require("./middlewares/notFound");
const cookies = require("cookie-parser");
const errorHandler = require("./middlewares/errorHandler");
const xssSanitize = require("./middlewares/xss");
const lang = require("./middlewares/lang");
const cors = require("cors");
const Category = require("./models/Category");
const seedDatabase = require("./scripts/seed");

app.use(cors({
    origin: true,
    credentials: true
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(require("morgan")("dev"));
app.use(cookies());
app.use(xssSanitize);
app.use(lang);

//apis
app.get("/api/health", (req, res) => res.status(200).json("API is Healthy"));
app.use("/api/v1/users", require("./routes/user.routes"));
app.use("/api/v1/auth", require("./routes/auth.routes"));
app.use("/api/v1/categories", require("./routes/category.routes"));
app.use("/api/v1/services", require("./routes/service.routes"));
app.use("/api/v1/bookings", require("./routes/booking.routes"));
app.use("/api/v1/favorite", require("./routes/favorite.routes"));
app.use("/api/v1/offers", require("./routes/offer.routes"));
app.use("/api/v1/notification", require("./routes/notification.routes"));
app.use("/api/v1/chat", require("./routes/chat.routes"));
app.use("/api/v1/admin", require("./routes/admin.routes"));
app.use("/api/v1/admin_service", require("./routes/adminService.routes"));


app.use(errorHandler);
app.use(notFound);


const PORT = process.env.PORT || 3000;

 mongoose.connect(process.env.MONGODB_URL)
    .then(async () => {
        console.log("Connected to database successfully")

        // First run in a fresh local environment: the database has no
        // categories yet, so seed the demo data automatically instead of
        // requiring a manual `npm run seed`. Never runs again once data
        // exists, so it won't wipe real data on normal restarts.
        const categoryCount = await Category.countDocuments();
        if (categoryCount === 0) {
            console.log("No data found — seeding demo data for first run...");
            await seedDatabase();
            console.log("Seeding complete.");
        }

        app.listen(PORT, () => {
            console.log("Server is running successfully");
        })
 })
    .catch(err => {
        console.log("Mongodb Error:", err.message);
    })