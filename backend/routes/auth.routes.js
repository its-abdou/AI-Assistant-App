import express from "express";
const router = express.Router();
import authController from "../controllers/auth.controller.js";

router.post("/signup", authController.signup);
//router.post("/login", authController.login);
//router.get("/google", authController.googleAuth);
//router.get("/google/callback", authController.googleCallback);

export default router;
