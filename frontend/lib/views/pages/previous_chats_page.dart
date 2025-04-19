
// lib/views/pages/previous_chats_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/conversation_model.dart';
import 'package:frontend/providers/conversation_providers.dart';
import 'package:frontend/utils/constants/image_strings.dart';
import 'package:frontend/utils/constants/size.dart';
import 'package:frontend/utils/themes/text_thems.dart';
import 'package:frontend/views/pages/chat_page.dart';
import 'package:frontend/views/pages/profile_page.dart';
import '../widgets/bottom_menu_widget.dart';
import '../widgets/conversation_card.dart';

class PreviousChatsPage extends ConsumerStatefulWidget {
  const PreviousChatsPage({super.key});

  @override
  ConsumerState<PreviousChatsPage> createState() => _PreviousChatsPageState();
}

class _PreviousChatsPageState extends ConsumerState<PreviousChatsPage> {
  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentId = ref.watch(currentConversationProvider);
    final conversationsState = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentId != null) {
              conversationsState.whenData((list) {
                final conv = list.firstWhere((c) => c.id == currentId);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      initialConversationId: conv.id,
                      initialTitle: conv.title,
                    ),
                  ),
                );
              });
            }
          },
        ),

        title: const Text('Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: conversationsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (conversations) {
            if (conversations.isEmpty) {
              return const Center(
                child: Text(
                  'No conversations yet. Start a new chat!',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ConversationCard(
                  conversationData: ConversationData.fromConversation(conversation),
                  onMenuPressed: () => _showBottomMenu(context, conversation),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          initialConversationId: conversation.id,
                          initialTitle: conversation.title,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showBottomMenu(BuildContext context, Conversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1C),
      builder: (_) => BottomMenuWidget(conversation: conversation),
    );
  }
}
