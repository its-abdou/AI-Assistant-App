import Message from "../models/message.model.js";
import Conversation from "../models/conversation.model.js";
import ModelClient, { isUnexpected } from "@azure-rest/ai-inference";
import { AzureKeyCredential } from "@azure/core-auth";

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
    const { conversationId } = req.params;

    try {
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

      const formattedMessages = history.map((msg) => {
        if (msg.sender === "assistant") {
          return { role: "assistant", content: msg.content };
        }

        if (msg.meta?.imageUrl) {
          return {
            role: "user",
            content: [
              { type: "text", text: msg.content },
              { type: "image_url", image_url: { url: msg.meta.imageUrl } },
            ],
          };
        } else {
          return { role: "user", content: msg.content };
        }
      });

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

      // 5. Save assistant reply
      const assistantMessage = new Message({
        conversationId,
        sender: "assistant",
        content: assistantReply,
      });
      await assistantMessage.save();

      res.status(201).json([userMessage, assistantMessage]);
    } catch (err) {
      console.error("Error in message controller:", err);
      res.status(500).json({ error: "Message processing failed." });
    }
  };
}

export default messageController;
