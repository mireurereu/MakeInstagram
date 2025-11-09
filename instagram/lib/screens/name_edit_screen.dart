import 'package:flutter/material.dart';

class NameEditScreen extends StatefulWidget {
  final String initialName;

  const NameEditScreen({super.key, required this.initialName});

  @override
  State<NameEditScreen> createState() => _NameEditScreenState();
}

class _NameEditScreenState extends State<NameEditScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- (수정됨!) ---
  void _onDone() {
    final String newName = _controller.text;

    // 1. 이름이 변경되지 않았으면 그냥 닫기
    if (newName == widget.initialName) {
      Navigator.pop(context);
      return;
    }

    // 2. 이름이 변경되었으면, (영상 4:06) 확인 다이얼로그 띄우기
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // (스크린샷) 둥근 모서리
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          // (스크린샷) 제목
          title: Text(
            "Are you sure you want to change your name to $newName!!",
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          // (스크린샷) 본문
          content: Text(
            "You can only change your name twice within 14 days.",
            style: TextStyle(color: Colors.grey[700], fontSize: 14.0),
            textAlign: TextAlign.center,
          ),
          
          actionsPadding: EdgeInsets.zero, // 버튼 패딩 제거
          buttonPadding: EdgeInsets.zero, // 버튼 패딩 제거
          
          // (스크린샷) 세로로 쌓인 버튼들
          actions: <Widget>[
            Divider(height: 1, color: Colors.grey[300]),
            // 1. "Change name" 버튼
            SizedBox(
              width: double.infinity, // 꽉 채우기
              child: TextButton(
                child: Text(
                  "Change name",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold), // 파란색, 굵게
                ),
                onPressed: () {
                  // 1. 다이얼로그 닫기
                  Navigator.pop(dialogContext);
                  // 2. 이전 화면(EditProfile)으로 '새 이름'을 반환하며 닫기
                  Navigator.pop(context, newName);
                },
              ),
            ),
            Divider(height: 1, color: Colors.grey[300]),
            // 2. "Cancel" 버튼
            SizedBox(
              width: double.infinity,
              child: TextButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.black87, fontSize: 16.0), // 검은색
                ),
                onPressed: () {
                  // 다이얼로그만 닫기
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Name'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.blue),
            onPressed: _onDone, // (수정) 다이얼로그를 띄우는 함수로 연결
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // (이전과 동일) 텍스트 필드
            TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(color: Colors.black, fontSize: 16.0),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            // (이전과 동일) 도움말 텍스트
            Text(
              'Help people discover your account by using the name you\'re known by: either your full name, nickname, or business name.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
            ),
            const SizedBox(height: 12.0),
            Text(
              'You can only change your name twice within 14 days.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
            ),
            const SizedBox(height: 12.0),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                children: [
                  TextSpan(
                      text:
                          'Your name is visible to everyone on and off Instagram. '),
                  TextSpan(
                    text: 'Learn more',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}