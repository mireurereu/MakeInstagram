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
  int _remaining = 150; // [복구] 남은 글자 수 저장 변수
  static const int _maxChars = 150;

  // 인스타그램 공식 블루 색상 상수 정의
  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBio);
    
    // [복구] 초기 남은 글자 수 계산
    _remaining = _maxChars - _controller.text.length;
    
    // [복구] 입력할 때마다 남은 글자 수 갱신 (카운트 다운)
    _controller.addListener(() {
      setState(() {
        _remaining = (_maxChars - _controller.text.length).clamp(0, _maxChars);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDone() {
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bio',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: _instaBlue, size: 28.0),
            onPressed: _onDone,
          ),
        ],
      ),
      // 키보드가 올라오면 화면을 밀어올려 하단 요소가 키보드 위에 붙도록 함
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const SizedBox(height: 8),
          // 1. 텍스트 입력 필드 (화면의 남은 공간을 차지)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                cursorColor: _instaBlue,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  height: 1.2,
                ),
                maxLines: null, // 여러 줄 입력 허용
                keyboardType: TextInputType.multiline,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_maxChars),
                ],
                decoration: InputDecoration(
                  labelText: 'Bio',
                  floatingLabelStyle: const TextStyle(color: Colors.grey),
                  labelStyle: const TextStyle(color: Colors.grey),
                  // [복구] 텍스트 필드 밑줄 (UnderlineInputBorder) 다시 추가
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
                  // 기본 카운터 숨김 (아래에 커스텀으로 배치)
                  counterText: "", 
                ),
              ),
            ),
          ),

          // 2. 하단 고정 영역 (키보드 바로 위)
          // 순서: 글자 수 -> 구분선 -> 안내 문구
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 2-1. 남은 글자 수 표시 (오른쪽 정렬)
              Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                child: Text(
                  '$_remaining', // [복구] 남은 글자 수 표시
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.grey[600], 
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              
              // 2-2. 구분선
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              
              // 2-3. 안내 문구 (RichText 복구)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[600], fontSize: 13.0),
                    children: [
                      const TextSpan(
                        text: 'Your bio is visible to everyone on and off Instagram. '
                      ),
                      TextSpan(
                        text: 'Learn more',
                        style: TextStyle(color: _instaBlue), // 파란색 링크 스타일 복구
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}