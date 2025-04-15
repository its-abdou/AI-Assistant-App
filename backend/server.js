// Packages
import express from "express";
import "dotenv/config";
import morgan from "morgan";
import cors from "cors";
// Utils
import connectMongodb from "./db/connectMongodb.js";

// Routes
import authRoutes from "./routes/auth.routes.js";
import userRoutes from "./routes/user.routes.js";

// Config
const PORT = process.env.PORT || 8000;

const app = express();

// middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));
app.use(cors());

//routes
app.use("/api/v1/auth", authRoutes);
app.use("/api/v1/user", userRoutes);

app.listen(PORT, () => {
  console.log(`Server is running on Port ${PORT}`);
  connectMongodb();
});
