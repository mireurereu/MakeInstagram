import 'package:flutter/material.dart';

class NameEditScreen extends StatefulWidget {
  final String initialName;

  const NameEditScreen({super.key, required this.initialName});

  @override
  State<NameEditScreen> createState() => _NameEditScreenState();
}

class _NameEditScreenState extends State<NameEditScreen> {
  late TextEditingController _controller;

  // 인스타 블루
  final Color _instaBlue = const Color(0xFF3797EF);

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

  void _onDone() {
    final String newName = _controller.text;

    // 1. 변경 사항이 없으면 바로 닫기
    if (newName == widget.initialName) {
      Navigator.pop(context);
      return;
    }

    // 2. 변경 사항이 있으면 확인 팝업 (영상 04:06)
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          constraints: const BoxConstraints(maxWidth: 400),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // 둥근 모서리
          ),
          // 다이얼로그 타이틀 (중앙 정렬)
          title: Text(
            "Are you sure you want to change your name to $newName?",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          // 다이얼로그 내용
          content: Text(
            "You can only change your name twice within 14 days.",
            style: TextStyle(color: Colors.grey[800], fontSize: 15.0),
            textAlign: TextAlign.center,
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16), // 패딩 조절
          
          // 버튼 영역 (커스텀 컬럼 사용)
          actionsPadding: EdgeInsets.zero,
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 1, thickness: 0.5, color: Colors.grey),
                // Change name 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // 팝업 닫기
                      Navigator.pop(context, newName); // 변경된 이름 반환하며 화면 닫기
                    },
                    child: Text(
                      "Change name",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 57, 11, 85), // [수정] 인스타 블루
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 0.5, color: Colors.grey),
                // Cancel 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // 팝업만 닫기
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black, // [수정] 검은색
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Name',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: false, // 왼쪽 정렬 (영상 참고)
        actions: [
          IconButton(
            // [수정] 체크 아이콘 색상 변경
            icon: Icon(Icons.check, color: _instaBlue, size: 28.0),
            onPressed: _onDone,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름 입력 필드
            TextField(
              controller: _controller,
              autofocus: true,
              cursorColor: _instaBlue, // [수정] 커서 색상
              style: const TextStyle(color: Colors.black, fontSize: 16.0),
              decoration: InputDecoration(
                labelText: 'Name',
                floatingLabelStyle: const TextStyle(color: Colors.grey),
                labelStyle: const TextStyle(color: Colors.grey),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // 안내 문구 1
            Text(
              'Help people discover your account by using the name you\'re known by: either your full name, nickname, or business name.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
            ),
            const SizedBox(height: 16.0),
            
            // 안내 문구 2
            Text(
              'You can only change your name twice within 14 days.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
            ),
            const SizedBox(height: 16.0),
            
            // 안내 문구 3 (링크 포함)
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                children: [
                  const TextSpan(
                    text: 'Your name is visible to everyone on and off Instagram. '
                  ),
                  TextSpan(
                    text: 'Learn more',
                    style: TextStyle(color: _instaBlue), // [수정] 링크 색상
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