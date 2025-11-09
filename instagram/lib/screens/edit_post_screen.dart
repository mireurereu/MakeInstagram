// lib/screens/edit_post_screen.dart

import 'dart.io';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/new_post_screen.dart'; // 다음 단계 파일

class EditPostScreen extends StatelessWidget {
  final File imageFile; // 이전 화면에서 선택한 이미지

  const EditPostScreen({super.key, required this.imageFile});

  void _goToNewPostScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPostScreen(imageFile: imageFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Edit'),
        actions: [
          // 'Next' 버튼
          TextButton(
            onPressed: () => _goToNewPostScreen(context),
            child: Text(
              'Next',
              style: TextStyle(color: Colors.blue, fontSize: 16.0),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 선택된 이미지
          Image.file(
            imageFile,
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.width, // 1:1 비율
          ),
          
          // 2. 필터 선택기 (플레이스홀더)
          Container(
            height: 100,
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Filter options would go here',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}