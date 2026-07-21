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

//apis
app.get("/api/health", (req, res) => res.status(200).json("API is Healthy"));
app.use("/api/v1/users", require("./routes/user.routes"));
app.use("/api/v1/auth", require("./routes/auth.routes"));
//app.use("/api/v1/category", require("./routes/category.routes"));

app.use(errorHandler);
app.use(notFound);


const PORT = process.env.PORT || 3000;

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