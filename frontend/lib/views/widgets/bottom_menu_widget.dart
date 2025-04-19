import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';

import '../../models/conversation_model.dart';

class BottomMenuWidget extends StatelessWidget {
  final Conversation conversation;

  const BottomMenuWidget({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Iconsax.edit, color: Colors.white),
          title: const Text('Rename', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context, 'rename'); // Signal parent to handle rename
          },
        ),
        ListTile(
          leading: const Icon(Iconsax.trash, color: Colors.red),
          title: const Text('Delete', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context, 'delete'); // Signal parent to handle delete
          },
        ),
      ],
    );
  }
}
