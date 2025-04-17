import 'package:flutter/material.dart';
class BottomMenuWidget extends StatelessWidget {
  const BottomMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(bottom: 32),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.white),
            title: const Text(
              'Rename',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Handle Share action
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.white),
            title: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Handle Delete action
            },
          ),
        ],
      ),
    );
  }
}