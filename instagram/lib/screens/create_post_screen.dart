// lib/screens/create_post_screen.dart

import 'dart:io'; // File 사용
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/edit_post_screen.dart'; // 다음 단계 파일

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? _selectedImage; // 선택된 이미지를 저장할 File 객체
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 화면이 로드되자마자 갤러리를 띄웁니다.
    _pickImageFromGallery();
  }

  // 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return;

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      // 이미지를 선택하지 않고 뒤로가기 한 경우
      Navigator.pop(context); // Post 플로우 종료
    }
  }

  void _goToEditScreen() {
    if (_selectedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPostScreen(imageFile: _selectedImage!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('New post'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // 전체 플로우 취소
        ),
        actions: [
          // 'Next' 버튼
          TextButton(
            onPressed: _selectedImage != null ? _goToEditScreen : null,
            child: Text(
              'Next',
              style: TextStyle(
                color: _selectedImage != null ? Colors.blue : Colors.grey,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: _selectedImage != null
            // (영상 1:46 ~ 1:52) 선택된 이미지 미리보기
            ? Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            // 이미지를 선택하는 동안 로딩 인디케이터
            : CircularProgressIndicator(),
      ),
    );
  }
}