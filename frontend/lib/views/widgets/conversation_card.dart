import 'package:flutter/material.dart';
import 'package:frontend/models/conversation_model.dart';
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

  factory ConversationData.fromConversation(Conversation c) {
    final dt = c.updatedAt;
    // format date...
    final weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final months   = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dayOfWeek = weekdays[dt.weekday - 1];
    final month    = months[dt.month - 1];
    final formatted = '$dayOfWeek, $month ${dt.day}';
    return ConversationData(date: formatted, title: c.title, id: c.id);
  }
}

class ConversationCard extends StatelessWidget {
  final ConversationData conversationData;
  final VoidCallback onTap;
  final VoidCallback onMenuPressed;

  const ConversationCard({
    Key? key,
    required this.conversationData,
    required this.onTap,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversationData.date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
