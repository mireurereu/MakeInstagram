import 'package:flutter/material.dart';

class BioEditScreen extends StatefulWidget {
  final String initialBio;

  const BioEditScreen({super.key, required this.initialBio});

  @override
  State<BioEditScreen> createState() => _BioEditScreenState();
}

class _BioEditScreenState extends State<BioEditScreen> {
  late TextEditingController _controller;

  // 인스타그램 공식 블루 색상 상수 정의
  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDone() {
    // 변경된 값을 가지고 이전 화면으로 돌아감
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 완전 흰색
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black), // 닫기 버튼 검은색
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bio',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0, // 영상 비율에 맞춘 폰트 사이즈
          ),
        ),
        centerTitle: false, // 안드로이드에서도 왼쪽 정렬 방지 (인스타는 중앙 or 왼쪽 상황에 따라 다름, 여기선 왼쪽)
        actions: [
          IconButton(
            // [수정 1] 인스타그램 고유 블루 색상 적용
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
            TextField(
              controller: _controller,
              autofocus: true,
              // [수정 2] 커서 색상 변경
              cursorColor: _instaBlue, 
              style: const TextStyle(
                color: Colors.black, 
                fontSize: 16.0,
                height: 1.2, // 줄 간격 조정
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Bio',
                // 라벨이 떠오를 때 색상 (회색)
                floatingLabelStyle: const TextStyle(color: Colors.grey),
                labelStyle: const TextStyle(color: Colors.grey),
                // 포커스 잡혔을 때 밑줄 색상 (검은색)
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                // 평소 밑줄 색상 (연한 회색)
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.only(bottom: 8.0),
              ),
            ),
            const SizedBox(height: 16.0),

            // 하단 안내 문구
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[600], fontSize: 13.0),
                children: [
                  const TextSpan(
                    text: 'Your bio is visible to everyone on and off Instagram. '
                  ),
                  TextSpan(
                    text: 'Learn more',
                    // [수정 3] 링크 텍스트 색상 변경
                    style: TextStyle(color: _instaBlue),
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