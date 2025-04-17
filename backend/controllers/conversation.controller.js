import Conversation from "../models/conversation.model.js";
class ConversationController {
  static listConversations = async (req, res) => {
    try {
      const conversations = await Conversation.find({
        userId: req.user.id,
      }).sort({ updatedAt: -1 });
      res.json(conversations);
    } catch (err) {
      res.status(500).json({ error: "Server error" });
    }
  };

  static createConversation = async (req, res) => {
    try {
      const conversation = await Conversation.create({
        userId: req.user.id,
        title: req.body.title || "New Conversation",
      });
      if (conversation == null) {
        return res.status(400).json({ message: "Nope" });
      }

      res.status(201).json(conversation);
    } catch (err) {
      res.status(500).json({ error: "Could not create conversation" });
    }
  };

  static getConversation = async (req, res) => {
    try {
      const conversation = await Conversation.findOne({
        _id: req.params.conversationId,
        userId: req.user.id,
      });
      if (!conversation)
        return res.status(404).json({ message: "Conversation not found" });
      res.json(conversation);
    } catch (err) {
      res.status(500).json({ error: "Error fetching conversation" });
    }
  };

  static updateConversation = async (req, res) => {
    try {
      const conversation = await Conversation.findOneAndUpdate(
        { _id: req.params.conversationId, userId: req.user.id },
        { title: req.body.title, updatedAt: Date.now() },
        { new: true }
      );
      if (!conversation)
        return res.status(404).json({ message: "Conversation not found" });
      res.json(conversation);
    } catch (err) {
      res.status(500).json({ error: "Failed to update conversation" });
    }
  };

  static deleteConversation = async (req, res) => {
    try {
      const deleted = await Conversation.findOneAndDelete({
        _id: req.params.conversationId,
        userId: req.user.id,
      });
      if (!deleted)
        return res.status(404).json({ message: "Conversation not found" });
      res.status(204).json({ message: "Conversation deleted" });
    } catch (err) {
      res.status(500).json({ error: "Failed to delete conversation" });
    }
  };
}

export default ConversationController;
