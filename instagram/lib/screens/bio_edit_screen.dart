import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BioEditScreen extends StatefulWidget {
  final String initialBio;

  const BioEditScreen({super.key, required this.initialBio});

  @override
  State<BioEditScreen> createState() => _BioEditScreenState();
}

class _BioEditScreenState extends State<BioEditScreen> {
  late TextEditingController _controller;
  int _remaining = 150;
  static const int _maxChars = 150;

  // 인스타그램 공식 블루 색상 상수 정의
  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBio);
    _remaining = _maxChars - _controller.text.length;
    _controller.addListener(() {
      final len = _controller.text.characters.length;
      setState(() {
        _remaining = (_maxChars - len).clamp(0, _maxChars);
      });
    });
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
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                cursorColor: _instaBlue,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  height: 1.2,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_maxChars),
                ],
                decoration: InputDecoration(
                  labelText: 'Bio',
                  floatingLabelStyle: const TextStyle(color: Colors.grey),
                  labelStyle: const TextStyle(color: Colors.grey),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 8.0),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // Bottom info + counter that stays above keyboard
            AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey[600], fontSize: 13.0),
                            children: [
                              const TextSpan(
                                text: 'Your bio is visible to everyone on and off Instagram. '
                              ),
                              TextSpan(
                                text: 'Learn more',
                                style: TextStyle(color: _instaBlue),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Remaining counter
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0, right: 4.0),
                        child: Text(
                          '$_remaining',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                        ),
                      ),
                    ],
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