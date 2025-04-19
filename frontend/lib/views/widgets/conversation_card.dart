import 'package:flutter/material.dart';
import 'package:frontend/models/conversation_model.dart';
import 'package:frontend/views/pages/chat_page.dart';
import 'package:iconsax/iconsax.dart';

class ConversationData {
  final String date;
  final String title;
  final String? id;

  ConversationData({
    required this.date,
    required this.title,
    this.id,
  });

  // Create from Conversation model
  factory ConversationData.fromConversation(Conversation conversation) {
    // Format the date
    final DateTime date = conversation.updatedAt;
    final String formattedDate = _formatDate(date);

    return ConversationData(
      date: formattedDate,
      title: conversation.title,
      id: conversation.id,
    );
  }

  static String _formatDate(DateTime date) {
    // Get day of week
    final List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final String dayOfWeek = weekdays[date.weekday - 1];

    // Get month
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final String month = months[date.month - 1];

    return '$dayOfWeek, $month ${date.day}';
  }
}

class ConversationCard extends StatelessWidget {
  final ConversationData conversationData;
  final VoidCallback onMenuPressed;

  const ConversationCard({
    Key? key,
    required this.conversationData,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (conversationData.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                conversationId: conversationData.id!,
                initialTitle: conversationData.title,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversationData.date,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversationData.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(Iconsax.more, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}