import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/message_model.dart';
import 'package:frontend/providers/conversation_providers.dart';
import 'package:frontend/views/pages/previous_chats_page.dart';
import 'package:frontend/utils/constants/colors.dart';
import 'package:frontend/utils/constants/size.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatPage extends ConsumerStatefulWidget {
  final String? initialConversationId;
  final String? initialTitle;

  const ChatPage({Key? key, this.initialConversationId, this.initialTitle})
    : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _conversationId;
  String _conversationTitle = 'New Chat';
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isCreating = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialConversationId != null) {
      _conversationId = widget.initialConversationId;
      _conversationTitle = widget.initialTitle ?? 'Chat';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentConversationProvider.notifier).state = _conversationId;
      });
    }
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image to reduce size
        maxWidth: 1200, // Limit image dimensions
        maxHeight: 1200,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (photo != null) {
        setState(() {
          _selectedImage = photo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  Future<void> _startConversation(String firstMessage, {XFile? image}) async {
    setState(() => _isCreating = true);
    try {
      final convo = await ref
          .read(conversationsProvider.notifier)
          .createConversation('New Conversation');
      _conversationId = convo.id;
      _conversationTitle = convo.title;
      ref.read(currentConversationProvider.notifier).state = _conversationId;

      await ref
          .read(messagesProvider(_conversationId!).notifier)
          .sendMessage(firstMessage, image: image);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting conversation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty && _selectedImage == null) return;

    setState(() => _isSending = true);

    try {
      if (_conversationId == null) {
        await _startConversation(message, image: _selectedImage);
      } else {
        await ref
            .read(messagesProvider(_conversationId!).notifier)
            .sendMessage(message, image: _selectedImage);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _selectedImage = null;
        });
        _messageController.clear();
      }
    }
  }

  void _startNewChat() {
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

  Widget _buildImagePreview() {
    if (_selectedImage == null) return const SizedBox.shrink();

    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A1C),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_selectedImage!.path),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageImage(
    String? imagePath,
    bool isNetworkImage,
    Message message,
  ) {
    if (imagePath == null) {
      if (message.meta != null && message.meta!['referenceImageUrl'] != null) {
        imagePath = message.meta!['referenceImageUrl'];
        isNetworkImage = true;
      } else {
        return const SizedBox.shrink();
      }
    }
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 200,
        maxWidth: double.infinity,
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            isNetworkImage
                ? Image.network(
                  imagePath!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: Colors.grey[800],
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    );
                  },
                )
                : Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        _conversationId != null
            ? ref.watch(messagesProvider(_conversationId!))
            : const AsyncValue<List<Message>>.data([]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
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

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollToBottom();
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isUser = msg.sender == 'user';

                    // Determine image source
                    String? imagePath;
                    bool isNetworkImage = false;

                    if (msg.meta != null) {
                      // Check for local file path (optimistic UI)
                      if (msg.meta!['image'] != null) {
                        imagePath = msg.meta!['image'];
                        isNetworkImage = false;
                      }
                      // Check for network URL from server
                      else if (msg.meta!['imageUrl'] != null) {
                        imagePath = msg.meta!['imageUrl'];
                        isNetworkImage = true;
                      }
                      // No need to explicitly check for referenceImageUrl here
                      // since it will be handled in _buildMessageImage
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment:
                            isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                color:
                                    isUser
                                        ? TColors.primary
                                        : const Color(0xFF1A1A1C),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (imagePath != null ||
                                      (msg.meta != null &&
                                          msg.meta!['referenceImageUrl'] !=
                                              null))
                                    _buildMessageImage(
                                      imagePath,
                                      isNetworkImage,
                                      msg,
                                    ),
                                  if (msg.content.isNotEmpty &&
                                      msg.content != '[Image]')
                                    Text(
                                      msg.content,
                                      style: TextStyle(
                                        color:
                                            isUser
                                                ? Colors.white
                                                : Colors.grey[200],
                                      ),
                                    ),
                                ],
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
            padding: const EdgeInsets.only(
              top: 20,
              left: 10,
              right: 10,
              bottom: 30,
            ),
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
            child: Column(
              children: [
                _buildImagePreview(),
                Row(
                  children: [
                    // Image picker button with dropdown options
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white,
                      ),
                      onSelected: (value) {
                        if (value == 'camera') {
                          _takePhoto();
                        } else if (value == 'gallery') {
                          _pickImage();
                        }
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'camera',
                              child: Row(
                                children: [
                                  Icon(Icons.camera_alt),
                                  SizedBox(width: 8),
                                  Text('Take Photo'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'gallery',
                              child: Row(
                                children: [
                                  Icon(Icons.image),
                                  SizedBox(width: 8),
                                  Text('Choose from Gallery'),
                                ],
                              ),
                            ),
                          ],
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText:
                              _selectedImage != null
                                  ? 'Add a caption (optional)...'
                                  : 'Type a message...',
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
                        onPressed:
                            _isCreating || _isSending ? null : _sendMessage,
                        icon:
                            _isCreating || _isSending
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
