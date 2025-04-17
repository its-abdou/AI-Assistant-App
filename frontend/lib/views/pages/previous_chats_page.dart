import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:frontend/views/pages/profile_page.dart';

import '../../utils/constants/image_strings.dart';
import '../../utils/constants/size.dart';
import '../../utils/themes/text_thems.dart';
import '../widgets/bottom_menu_widget.dart';
import '../widgets/conversation_card.dart';

class PreviousChatsPage extends StatefulWidget {
  const PreviousChatsPage({super.key});

  @override
  State<PreviousChatsPage> createState() => _PreviousChatsPageState();
}

class _PreviousChatsPageState extends State<PreviousChatsPage> {
  bool isNetworkImage = false;
  String image = TImages.user;
  final List<ConversationData> conversations = [
    ConversationData(
      date: 'Tuesday, Apr 15',
      title: 'Creating a Flutter App Theme',
    ),
    ConversationData(
      date: 'Monday, Apr 14',
      title: 'Firefighting Scene Description',
    ),
    ConversationData(
      date: 'Sunday, Apr 13',
      title: 'Simple Java Code Example',
    ),
    ConversationData(
      date: 'Saturday, Apr 12',
      title: 'Morning Greetings and Assignments',
    ),
    ConversationData(
      date: 'Thursday, Apr 10',
      title: 'Anime Photo Generation Request',
    ),
    ConversationData(
      date: 'Wednesday, Mar 26',
      title: 'Roadmap to Becoming a Backend Developer',
    ),
  ];

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
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
              child: ListView.builder(
                itemCount: conversations.length,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (context, index) {
                  return ConversationCard(
                    conversationData: conversations[index],
                    onMenuPressed: () {
                      _showBottomMenu(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1C),
      builder: (context) => const BottomMenuWidget(),
    );
  }
}