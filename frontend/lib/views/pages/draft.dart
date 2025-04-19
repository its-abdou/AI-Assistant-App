import 'package:flutter/material.dart';

void main() {
  runApp(CopilotMock());
}

class CopilotMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CopilotScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CopilotScreen extends StatelessWidget {
  final Color backgroundColor = Color(0xFF0F172A); // Very dark navy
  final Color textColor = Color(0xFFF5E9D7); // Approximate beige
  final Color buttonColor = Color(0xFF1E293B); // Dark blue for buttons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.menu, color: textColor, size: 28),
              SizedBox(height: 40),
              Text(
                'Hi Abd, what should\nwe dive into today?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 40),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  CopilotButton(text: 'Write a first draft'),
                  CopilotButton(text: 'Get advice'),
                  CopilotButton(text: 'Learn something'),
                ],
              ),
              Spacer(),
              CopilotInputCard(textColor: textColor, buttonColor: buttonColor),
            ],
          ),
        ),
      ),
    );
  }
}

class CopilotButton extends StatelessWidget {
  final String text;

  const CopilotButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class CopilotInputCard extends StatelessWidget {
  final Color textColor;
  final Color buttonColor;

  const CopilotInputCard({
    required this.textColor,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message Copilot',
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Quick ▼',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.add, color: textColor),
          SizedBox(width: 12),
          Icon(Icons.mic_none, color: textColor),
          Card(

          )
        ],
      ),
    );
  }
}

