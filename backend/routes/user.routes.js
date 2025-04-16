import express from "express";
import userController from "../controllers/user.controller.js";
import protectRoute from "../middlewares/protectRoute.js";

const router = express.Router();

router.use(protectRoute);
router.get("/profile", userController.getProfile);
router.put("/profile", userController.updateProfile);

export default router;
