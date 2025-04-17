import express from "express";
const router = express.Router();
import conversationController from "../controllers/conversation.controller.js";

import protectRoute from "../middlewares/protectRoute.js";

router.use(protectRoute);

router.get("/", conversationController.listConversations);
router.post("/", conversationController.createConversation);
router.get("/:conversationId", conversationController.getConversation);
router.put("/:conversationId", conversationController.updateConversation);
router.delete("/:conversationId", conversationController.deleteConversation);

export default router;
