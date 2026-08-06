require("dotenv").config();
const express = require("express");
const app = express();
const { default: mongoose } = require("mongoose");
const notFound = require("./middlewares/notFound");
const cookies = require("cookie-parser");
const errorHandler = require("./middlewares/errorHandler");
const xssSanitize = require("./middlewares/xss");
const cors = require("cors");

app.use(cors({
    origin: true,
    credentials: true
}));

app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); 
app.use(require("morgan")("dev"));
app.use(cookies());
app.use(xssSanitize);

// Resolves the response language from the Accept-Language header the
// frontend sends (based on the user's selected app locale).
app.use((req, res, next) => {
    const header = req.headers["accept-language"] || "";
    req.lang = header.toLowerCase().startsWith("ar") ? "ar" : "en";
    next();
});

//apis
app.get("/api/health", (req, res) => res.status(200).json("API is Healthy"));
app.use("/api/v1/auth", require("./routes/auth.routes"));
app.use("/api/v1/users", require("./routes/user.routes"));
app.use("/api/v1/categories", require("./routes/category.routes"));
app.use("/api/v1/services", require("./routes/service.routes"));
app.use("/api/v1/bookings", require("./routes/booking.routes"));
app.use("/api/v1/offers", require("./routes/offer.routes"));
app.use("/api/v1/chat", require("./routes/chat.routes"));
app.use("/api/v1/support", require("./routes/support.routes"));
app.use("/api/v1/admin", require("./routes/admin.routes"));

app.use(errorHandler);
app.use(notFound);


const PORT = process.env.PORT || 4000;

 mongoose.connect(process.env.MONGODB_URL)
    .then(() => {
        console.log("Connected to database successfully")
        app.listen(PORT, () => {
            console.log("Server is running successfully");
        })
 })
    .catch(err => {
        console.log("Mongodb Error:", err.message);
    })