import 'package:flutter/material.dart';

class BioEditScreen extends StatefulWidget {
  final String initialBio;

  const BioEditScreen({super.key, required this.initialBio});

  @override
  State<BioEditScreen> createState() => _BioEditScreenState();
}

class _BioEditScreenState extends State<BioEditScreen> {
  late TextEditingController _controller;

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
    // 요청하신 대로, 확인 팝업 없이 바로 값을 반환하고 닫습니다.
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // 값 반환 없이 닫기
        ),
        title: Text('Bio'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.blue),
            onPressed: _onDone, // 완료 함수 호출
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 텍스트 필드 (스크린샷 참고)
            TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(color: Colors.black, fontSize: 16.0),
              // (신규) 여러 줄 입력이 가능하도록 설정
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Bio', // 'Bio' 레이블
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

            // 하단 도움말 텍스트 (스크린샷 참고)
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                children: [
                  TextSpan(
                      text:
                          'Your bio is visible to everyone on and off Instagram. '),
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