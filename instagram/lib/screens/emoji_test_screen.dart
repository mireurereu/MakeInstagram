import 'package:flutter/material.dart';

class EmojiTestScreen extends StatelessWidget {
  const EmojiTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // [수정] 배경 흰색 고정
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emoji Test',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Checking Font Rendering...',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 24),
              // 이모지 테스트 (컬러 폰트 확인용)
              Text(
                '😀 😃 😄 😁 😂 🤣',
                style: TextStyle(fontSize: 40),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                '🥰 😍 🫶 🥳 🎉 ❤️‍🔥',
                style: TextStyle(fontSize: 40),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Text(
                'If you see boxes (□) instead of faces,\nthe device font fallback needs adjustment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}