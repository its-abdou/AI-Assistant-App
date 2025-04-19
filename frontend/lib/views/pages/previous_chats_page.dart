import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/conversation_model.dart';
import 'package:frontend/providers/conversation_providers.dart';
import 'package:frontend/views/pages/new_chat_page.dart';
import 'package:frontend/views/pages/profile_page.dart';

import '../../utils/constants/image_strings.dart';
import '../../utils/constants/size.dart';
import '../../utils/themes/text_thems.dart';
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

    // Refresh conversations list when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsState = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewChatPage()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: isNetworkImage
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Conversations",
              style: TTextTheme.darkTextTheme.headlineSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: conversationsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final conversationData = ConversationData.fromConversation(conversation);

                      return ConversationCard(
                        conversationData: conversationData,
                        onMenuPressed: () {
                          _showBottomMenu(context, conversation);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewChatPage()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showBottomMenu(BuildContext context, Conversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1C),
      builder: (context) => BottomMenuWidget(conversation: conversation),
    );
  }
}