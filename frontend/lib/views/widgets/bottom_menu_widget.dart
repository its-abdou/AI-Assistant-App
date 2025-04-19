import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/conversation_model.dart';
import 'package:frontend/providers/conversation_providers.dart';
import 'package:iconsax/iconsax.dart';

class BottomMenuWidget extends ConsumerWidget {
  final Conversation? conversation;

  const BottomMenuWidget({Key? key, this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (conversation != null) ...[
            ListTile(
              leading: const Icon(Iconsax.edit, color: Colors.white),
              title: const Text(
                'Rename',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _showRenameDialog(context, ref, conversation!);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _showDeleteConfirmationDialog(context, ref, conversation!);
              },
            ),
          ] else
            const Text(
              'No conversation selected',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    Conversation conversation,
  ) {
    final TextEditingController titleController = TextEditingController(
      text: conversation.title,
    );

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
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
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final newTitle = titleController.text.trim();
                  if (newTitle.isNotEmpty) {
                    try {
                      // Show a loading indicator while renaming
                      Navigator.pop(dialogContext); // Close the dialog
                      _showLoadingDialog(context);

                      // Perform the rename operation
                      await ref
                          .read(conversationsProvider.notifier)
                          .updateConversation(conversation.id, newTitle);

                      // Dismiss the loading dialog
                      if (context.mounted) {
                        Navigator.pop(context); // Close the loading dialog
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // Close the loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to rename conversation: ${e.toString()}',
                            ),
                          ),
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

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Conversation conversation,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1C),
            title: const Text('Delete Conversation'),
            content: const Text(
              'Are you sure you want to delete this conversation? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // Show a loading indicator while deleting
                    Navigator.pop(
                      dialogContext,
                    ); // Close the confirmation dialog
                    _showLoadingDialog(context);

                    // Perform the delete operation
                    await ref
                        .read(conversationsProvider.notifier)
                        .deleteConversation(conversation.id);

                    // Dismiss the loading dialog and navigate back
                    if (context.mounted) {
                      Navigator.pop(context); // Close the loading dialog
                      // Navigate back to the conversations list
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close the loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete conversation: ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
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
  }
}
