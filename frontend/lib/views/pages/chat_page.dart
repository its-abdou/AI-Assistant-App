// lib/views/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/message_model.dart';
import 'package:frontend/providers/conversation_providers.dart';
import 'package:frontend/views/pages/previous_chats_page.dart';
import 'package:frontend/utils/constants/colors.dart';
import 'package:frontend/utils/constants/size.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String? initialConversationId;
  final String? initialTitle;

  const ChatPage({Key? key, this.initialConversationId, this.initialTitle}) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  String? _conversationId;
  String _conversationTitle = 'New Chat';
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isCreating = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Initialize if navigated from existing conversation
    if (widget.initialConversationId != null) {
      _conversationId = widget.initialConversationId;
      _conversationTitle = widget.initialTitle ?? 'Chat';
      ref.read(currentConversationProvider.notifier).state = _conversationId;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startConversation(String firstMessage) async {
    setState(() => _isCreating = true);
    try {
      final convo = await ref.read(conversationsProvider.notifier)
          .createConversation('New Conversation');
      _conversationId = convo.id;
      _conversationTitle = convo.title;
      ref.read(currentConversationProvider.notifier).state = _conversationId;

      await ref
          .read(messagesProvider(_conversationId!).notifier)
          .sendMessage(firstMessage);
      _scrollToBottom();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isCreating = false);
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    if (_conversationId == null) {
      await _startConversation(message);
      _messageController.clear();
      return;
    }

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await ref
          .read(messagesProvider(_conversationId!).notifier)
          .sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _startNewChat() {
    // Navigate back to previous chats
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChatPage()),
    );
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

  @override
  Widget build(BuildContext context) {
    final messagesAsync = _conversationId != null
        ? ref.watch(messagesProvider(_conversationId!))
        : const AsyncValue<List<Message>>.data([]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PreviousChatsPage()),
            );
          },
        ),
        title: Text(_conversationTitle),
        actions: [
          if (_conversationId != null)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New Chat',
              onPressed: _startNewChat,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
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
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isUser = msg.sender == 'user';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUser)
                            const CircleAvatar(
                              backgroundColor: TColors.primary,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? TColors.primary
                                    : const Color(0xFF1A1A1C),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                msg.content,
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
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
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
                    icon: _isCreating || _isSending
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
