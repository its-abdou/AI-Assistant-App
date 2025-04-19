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
  bool isNetworkImage = false;
  String image = TImages.user;

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
            if (currentId == null) return; // If no currentId, do nothing

            // Access the state safely
            final conversations = ref.read(conversationsProvider);
            conversations.when(
              data: (list) {
                final conv = list.firstWhere((c) => c.id == currentId);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChatPage(
                          initialConversationId: conv.id,
                          initialTitle: conv.title,
                        ),
                  ),
                );
              },
              loading: () {
                // Optionally show a loading indicator or disable the button
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Loading conversations...')),
                );
              },
              error: (e, _) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading conversations: $e')),
                );
              },
            );
          },
        ),
        title: const Text('Conversations'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image:
                        isNetworkImage
                            ? NetworkImage(image)
                            : AssetImage(image) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
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
                  conversationData: ConversationData.fromConversation(
                    conversation,
                  ),
                  onMenuPressed: () => _showBottomMenu(context, conversation),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ChatPage(
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
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1C),
      builder: (_) => BottomMenuWidget(conversation: conversation),
    ).then((result) {
      if (result == 'delete' && mounted) {
        _performDeletion(context, conversation);
      } else if (result == 'rename' && mounted) {
        _showRenameDialog(context, conversation);
      }
    });
  }

  void _showRenameDialog(BuildContext context, Conversation conversation) {
    final TextEditingController titleController = TextEditingController(
      text: conversation.title,
    );

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1C),
            title: const Text(
              'Rename Conversation',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Enter new title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              autofocus: true,
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  final newTitle = titleController.text.trim();
                  if (newTitle.isNotEmpty) {
                    Navigator.pop(dialogContext);
                    _performRename(context, conversation, newTitle);
                  }
                },
                child: const Text(
                  'Rename',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _performRename(
    BuildContext context,
    Conversation conversation,
    String newTitle,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => const AlertDialog(
            backgroundColor: Color(0xFF1A1A1C),
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Processing...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
    );

    try {
      debugPrint(
        'Attempting to rename conversation ${conversation.id} to "$newTitle"',
      );
      await ref
          .read(conversationsProvider.notifier)
          .updateConversation(conversation.id, newTitle);
      debugPrint('Conversation renamed successfully');
      navigator.pop(); // Close the loading dialog
    } catch (e) {
      debugPrint('Error renaming conversation: $e');
      navigator.pop(); // Close the loading dialog
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to rename conversation: $e')),
        );
      }
    }
  }

  void _performDeletion(BuildContext context, Conversation conversation) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => const AlertDialog(
            backgroundColor: Color(0xFF1A1A1C),
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Processing...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
    );

    try {
      debugPrint('Attempting to delete conversation ${conversation.id}');
      await ref
          .read(conversationsProvider.notifier)
          .deleteConversation(conversation.id);
      debugPrint('Conversation deleted successfully');
      navigator.pop(); // Close the loading dialog
    } catch (e) {
      debugPrint('Error deleting conversation: $e');
      navigator.pop(); // Close the loading dialog
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete conversation: $e')),
        );
      }
    }
  }
}
