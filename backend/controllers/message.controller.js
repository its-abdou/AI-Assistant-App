import Message from "../models/message.model.js";
import Conversation from "../models/conversation.model.js";
import ModelClient, { isUnexpected } from "@azure-rest/ai-inference";
import { AzureKeyCredential } from "@azure/core-auth";
import { generateTitleFromMessages } from "../utils/generateTitle.js";
import { getBase64FromUrl } from "../utils/imageEncode.js";

const endpoint = "https://models.github.ai/inference";
const token = process.env["GITHUB_TOKEN"];
const model = "openai/gpt-4.1";

const client = ModelClient(endpoint, new AzureKeyCredential(token));

class messageController {
  static listMessages = async (req, res) => {
    try {
      console.log("Conversation ID from params:", req.params.conversationId);
      console.log("User ID from request:", req.user.id);
      const conversation = await Conversation.findOne({
        _id: req.params.conversationId,
        userId: req.user.id,
      });
      if (!conversation)
        return res.status(404).json({ message: "Conversation not found" });

      const messages = await Message.find({
        conversationId: conversation._id,
      }).sort({ createdAt: 1 });
      res.json(messages);
    } catch (err) {
      res.status(500).json({ error: "Failed to fetch messages" });
    }
  };

  static createMessage = async (req, res) => {
    const { content, meta } = req.body;
    let { conversationId } = req.params;

    try {
      let conversation;

      if (!conversationId || conversationId === "new") {
        conversation = await Conversation.create({
          userId: req.user.id,
          title: "Temporary...",
        });
        conversationId = conversation._id;
      } else {
        conversation = await Conversation.findOne({
          _id: conversationId,
          userId: req.user.id,
        });
        if (!conversation)
          return res.status(404).json({ message: "Conversation not found" });
      }

      const userMessage = new Message({
        conversationId,
        sender: "user",
        content,
        meta,
      });
      await userMessage.save();

      const history = await Message.find({ conversationId }).sort({
        createdAt: 1,
      });

      const formattedMessages = [];
      let userImageUrl = null;

      for (const msg of history) {
        if (msg.sender === "assistant") {
          formattedMessages.push({ role: "assistant", content: msg.content });
        } else if (msg.meta?.imageUrl) {
          try {
            const base64Image = await getBase64FromUrl(msg.meta.imageUrl);
            userImageUrl = msg.meta.imageUrl; // Store the latest user image URL

            formattedMessages.push({
              role: "user",
              content: [
                { type: "text", text: msg.content },
                { type: "image_url", image_url: { url: base64Image } },
              ],
            });
          } catch (imageError) {
            console.error("Image processing failed:", imageError);
            formattedMessages.push({ role: "user", content: msg.content });
          }
        } else {
          formattedMessages.push({ role: "user", content: msg.content });
        }
      }

      const response = await client.path("/chat/completions").post({
        body: {
          model,
          messages: formattedMessages,
          temperature: 1,
          top_p: 1,
        },
      });

      if (isUnexpected(response)) {
        throw response.body.error;
      }

      const assistantReply = response.body.choices[0].message.content;

      // Create metadata for the assistant message to preserve image context
      const assistantMeta = userImageUrl
        ? { referenceImageUrl: userImageUrl }
        : null;

      const assistantMessage = new Message({
        conversationId,
        sender: "assistant",
        content: assistantReply,
        meta: assistantMeta,
      });
      await assistantMessage.save();

      const messageCount = await Message.countDocuments({ conversationId });
      if (messageCount <= 2) {
        const title = await generateTitleFromMessages(content, assistantReply);
        conversation.title = title;
        await conversation.save();
      }

      res.status(201).json({
        conversationId,
        messages: [userMessage, assistantMessage],
      });
    } catch (err) {
      console.error("Error in message controller:", err);
      res.status(500).json({ error: "Message processing failed." });
    }
  };
}

export default messageController;
