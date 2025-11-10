import 'package:flutter/material.dart';

class EmojiTestScreen extends StatelessWidget {
  const EmojiTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emoji test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Emoji test — should render color emoji:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 12),
              Text(
                '😀 😃 😄 😁 😂 🤣 🥰 😍 🫶 🥳 🎉 ❤️‍🔥',
                style: TextStyle(fontSize: 48),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                'If these appear as boxes, your app font fallback needs adjustment.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
