import 'package:flutter/material.dart';
import 'package:instagram/screens/new_post_screen.dart';

class EditPostScreen extends StatefulWidget {
  // [핵심] 오직 assetPath만 받습니다.
  final String assetPath; 
  
  const EditPostScreen({
    super.key, 
    required this.assetPath // required로 변경
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final List<String> _filters = ['Normal', 'Clarendon', 'Gingham', 'Moon', 'Lark', 'Reyes'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Icon(Icons.auto_fix_high),
        actions: [
          TextButton(
            onPressed: () {
              // [핵심] assetPath를 그대로 다음 화면으로 넘기고, 이동 직후 하단 모달이 뜨도록 autoShowShareSheet=true
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewPostScreen(imagePath: widget.assetPath, autoShowShareSheet: true),
                ),
              );
            },
            child: const Text('Next', style: TextStyle(color: Color(0xFF3797EF), fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          // 이미지 표시: 화면에서 유연하게 크기를 차지하도록 Flexible 사용
          Flexible(
            flex: 7,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(widget.assetPath, fit: BoxFit.cover),
            ),
          ),

          // 필터 리스트: 고정 높이 대신 Flexible로 화면 비율을 사용
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _filters[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: index == 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: index == 0 ? Image.asset(widget.assetPath, fit: BoxFit.cover) : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 하단 탭(필터/편집) — SafeArea로 키보드/홈바와 겹치지 않도록 함
          SafeArea(
            child: Container(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text('FILTER', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('EDIT', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}