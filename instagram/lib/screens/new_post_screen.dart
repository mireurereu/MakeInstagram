// lib/screens/new_post_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';

class NewPostScreen extends StatefulWidget {
  final File imageFile; // 최종 편집된 이미지

  const NewPostScreen({super.key, required this.imageFile});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isSharing = false; // 공유 중 로딩 상태

  // (영상 2:06) 'Share' 버튼 클릭 시
  Future<void> _sharePost() async {
    setState(() {
      _isSharing = true; // 로딩 시작
    });

    String caption = _captionController.text;

    // --- 여기에서 실제 서버/백엔드 로직 수행 ---
    // 1. Firebase Storage에 이미지 파일 업로드
    // 2. Storage에서 URL 반환받기
    // 3. Firestore에 { 'imageUrl': url, 'caption': caption, ... } 데이터 저장
    // (지금은 2초 딜레이로 시뮬레이션)
  await Future.delayed(Duration(seconds: 2));

  debugPrint('Post Shared! Caption: $caption');
    // --- --- --- --- ---

    setState(() {
      _isSharing = false; // 로딩 끝
    });

    // (영상 2:15)
    // 업로드 완료 후, Post 스택(Create, Edit, New)을 모두 닫고
    // 피드 화면(Root)으로 돌아갑니다.
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);

    // TODO: 피드 화면이 새 게시물을 "자동으로" 리프레시 하도록
    // 상태 관리(Provider, Riverpod 등)를 통해 피드에 알림을 보내야 합니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('New post'),
        actions: [
          // 'Share' 버튼
          TextButton(
            onPressed: _isSharing ? null : _sharePost, // 공유 중 비활성화
            child: Text(
              'Share',
              style: TextStyle(
                color: _isSharing ? Colors.grey : Colors.blue,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // (영상 2:01) 캡션 입력란
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.file(
                      widget.imageFile,
                      width: 72.0,
                      height: 72.0,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Write a caption...', // (영상 2:01)
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[800]),
              // (영상 2:00) 'Tag people', 'Add location' 등... (플레이스홀더)
              ListTile(
                title: Text('Tag people', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.chevron_right, color: Colors.white),
              ),
              ListTile(
                title: Text('Add location', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
          
          // 공유 중일 때 로딩 오버레이
          if (_isSharing)
            Container(
              color: Color.fromRGBO(0, 0, 0, 0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Sharing...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}