import 'package:flutter/material.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 릴스는 검은 배경
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 배경 (영상 대신 이미지)
            Opacity(
              opacity: 0.6,
              child: Image.network(
                'https://picsum.photos/seed/reels/600/800',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            const Text(
              'Reels',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
            // 우측 하단 아이콘들
            Positioned(
              bottom: 20,
              right: 10,
              child: Column(
                children: const [
                  Icon(Icons.favorite_border, color: Colors.white, size: 30),
                  SizedBox(height: 4),
                  Text('110K', style: TextStyle(color: Colors.white)),
                  SizedBox(height: 20),
                  Icon(Icons.comment, color: Colors.white, size: 30),
                  SizedBox(height: 4),
                  Text('2,000', style: TextStyle(color: Colors.white)),
                  SizedBox(height: 20),
                  Icon(Icons.send, color: Colors.white, size: 30),
                  SizedBox(height: 20),
                  Icon(Icons.more_vert, color: Colors.white, size: 30),
                ],
              ),
            ),
            // 좌측 하단 정보
            Positioned(
              bottom: 20,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(radius: 14, backgroundColor: Colors.grey),
                      SizedBox(width: 8),
                      Text('user_reels', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Text('• Follow', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Reels description goes here...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}