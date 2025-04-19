// lib/views/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/conversation_model.dart';
import 'package:frontend/providers/conversation_providers.dart';
import 'package:frontend/utils/constants/colors.dart';
import 'package:frontend/utils/constants/size.dart';
import 'package:frontend/views/pages/previous_chats_page.dart';
import 'package:iconsax/iconsax.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String initialTitle;

  const ChatPage({
    Key? key,
    required this.conversationId,
    required this.initialTitle,
  }) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Set the current conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentConversationProvider.notifier).state = widget.conversationId;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    _messageController.clear();

    try {
      await ref.read(messagesProvider(widget.conversationId).notifier).sendMessage(message);

      // Scroll to bottom after message is sent
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showRenameDialog(Conversation conversation) {
    final TextEditingController titleController = TextEditingController(text: conversation.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1C),
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Enter new title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                Navigator.pop(context);
                try {
                  await ref.read(conversationsProvider.notifier).updateConversation(
                    conversation.id,
                    newTitle,
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to rename conversation: ${e.toString()}')),
                    );
                  }
                }
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider(widget.conversationId));
    final conversationsState = ref.watch(conversationsProvider);

    // Find the current conversation in the conversations list
    Conversation? currentConversation;
    conversationsState.whenData((conversations) {
      currentConversation = conversations.firstWhere(
            (conv) => conv.id == widget.conversationId,
        orElse: () => Conversation(
          id: widget.conversationId,
          userId: '',
          title: widget.initialTitle,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    });

    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messagesState is AsyncData && _scrollController.hasClients) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PreviousChatsPage()),
            );
          },
        ),
        title: currentConversation != null
            ? Text(currentConversation!.title)
            : Text(widget.initialTitle),
        actions: [
          if (currentConversation != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showRenameDialog(currentConversation!),
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messagesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Send a message to start a conversation',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message.sender == 'user';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUser)
                            const CircleAvatar(
                              backgroundColor: TColors.primary,
                              child: Icon(Iconsax.user, color: Colors.white),
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser ? TColors.primary : const Color(0xFF1A1A1C),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message.content,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.grey[200],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isUser)
                            const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Iconsax.user, color: Colors.white),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1C),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: TColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}