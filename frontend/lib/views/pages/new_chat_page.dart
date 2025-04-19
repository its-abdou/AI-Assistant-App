import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/conversation_providers.dart';
import 'package:frontend/utils/constants/size.dart';
import 'package:frontend/views/pages/chat_page.dart';

class NewChatPage extends ConsumerStatefulWidget {
  const NewChatPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends ConsumerState<NewChatPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  Future<void> _startNewChat() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      // Create a new conversation
      final conversation = await ref.read(conversationsProvider.notifier).createConversation("New Conversation");

      if (mounted) {
        // Navigate to the chat page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              conversationId: conversation.id,
              initialTitle: conversation.title,
            ),
          ),
        );

        // Send the first message (will happen after navigation)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(messagesProvider(conversation.id).notifier).sendMessage(message);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create conversation: ${e.toString()}')),
        );
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('New Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            const Spacer(),
            // Message input
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
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
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _startNewChat,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Start Chat'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}