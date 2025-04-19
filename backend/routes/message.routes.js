import express from "express";
const router = express.Router({ mergeParams: true });
import messageController from "../controllers/message.controller.js";

import protectRoute from "../middlewares/protectRoute.js";

router.use(protectRoute);

router.get("/", messageController.listMessages);
router.post("/", messageController.createMessage);

export default router;
