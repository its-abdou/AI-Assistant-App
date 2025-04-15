// Packages
import express from "express";
import "dotenv/config";
import morgan from "morgan";

// Utils
import connectMongodb from "./db/connectMongodb.js";

const PORT = process.env.PORT || 8000;

const app = express();

// middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));

app.listen(PORT, () => {
  console.log(`Server is running on Port ${PORT}`);
  connectMongodb();
});
