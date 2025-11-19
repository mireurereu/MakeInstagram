import 'package:flutter/material.dart';
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/screens/notifications_screen.dart';
import 'package:instagram/widgets/post_card_widget.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. 상단 앱바
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        // [수정] 로고 이미지 (없으면 텍스트로 대체)
        title: Image.asset(
          'assets/images/insta_logo.png', // 로고 에셋 경로
          height: 32.0,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // 에셋 없을 시 텍스트 로고 (Billabong 폰트 느낌)
            return const Text(
              'Instagram',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Billabong', // 폰트가 있다면 적용
                fontSize: 28.0,
                fontWeight: FontWeight.w500, // 약간 굵게
              ),
            );
          },
        ),
        actions: [
          // 알림(하트) 아이콘 -> 알림 화면으로 이동
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          // DM(번개 말풍선) 아이콘 -> DM 목록으로 이동
          IconButton(
            icon: const Icon(Icons.send_outlined, color: Colors.black, size: 28), // 또는 커스텀 아이콘
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DmListScreen()),
              );
            },
          ),
        ],
      ),

      // 2. 메인 바디
      body: ListView(
        children: [
          // [수정] 스토리 바 추가
          _buildStoryBar(),
          
          const Divider(height: 1, color: Color(0xFFDBDBDB)), // 구분선

          // [수정] 게시물 리스트 (영상 데이터 반영)
          // 1. 카리나 게시물 (캐러셀)
          PostCardWidget(
            username: 'karinabluu',
            userAvatarUrl: 'https://picsum.photos/seed/karina/100/100',
            postImageUrls: const [
              'https://picsum.photos/seed/post1/600/600',
              'https://picsum.photos/seed/post2/600/600',
            ],
            likeCount: '1,367,685',
            caption: 'more',
            timestamp: '5 days ago',
          ),

          // 2. 에스파 공식 (동영상 느낌)
          PostCardWidget(
            username: 'aespa_official',
            userAvatarUrl: 'https://picsum.photos/seed/aespa/100/100',
            postImageUrls: const ['https://picsum.photos/seed/video_thumb/600/600'],
            likeCount: '918,471',
            caption: 'Bee~ Gese Stay Alive 🐝',
            timestamp: '5 days ago',
            isVideo: true, // 비디오 아이콘 표시
          ),

          // 3. 윈터 게시물
          PostCardWidget(
            username: 'imwinter',
            userAvatarUrl: 'https://picsum.photos/seed/winter/100/100',
            postImageUrls: const [
              'https://picsum.photos/seed/winter1/600/600',
              'https://picsum.photos/seed/winter2/600/600',
            ],
            likeCount: '886,981',
            caption: '사랑스러운 🗿🤍',
            timestamp: '3 days ago',
          ),
        ],
      ),
    );
  }

  // [신규] 스토리 바 위젯
  Widget _buildStoryBar() {
    // 스토리 데이터 (영상 00:11 상단 참조)
    final stories = [
      {'name': 'Your story', 'img': 'https://picsum.photos/seed/junhyuk/100/100', 'isMe': true},
      {'name': 'newjeans', 'img': 'https://picsum.photos/seed/newjeans/100/100', 'isMe': false},
      {'name': 'katarinabluu', 'img': 'https://picsum.photos/seed/karina/100/100', 'isMe': false},
      {'name': 'aespa_official', 'img': 'https://picsum.photos/seed/aespa/100/100', 'isMe': false},
      {'name': 'winter', 'img': 'https://picsum.photos/seed/winter/100/100', 'isMe': false},
    ];

    return SizedBox(
      height: 100, // 스토리 바 높이
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // 가로 스크롤
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          final bool isMe = story['isMe'] == true;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                // 그라데이션 링 + 프로필 사진
                Container(
                  padding: const EdgeInsets.all(3.0), // 링 두께
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // 내 스토리는 링 없음 (또는 회색), 팔로잉은 무지개 링
                    gradient: isMe
                        ? null
                        : const LinearGradient(
                            colors: [
                              Color(0xFFFBAA47), // 노랑
                              Color(0xFFD91A46), // 빨강
                              Color(0xFFA60F93), // 보라
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2.0), // 사진과 링 사이 흰색 테두리
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(story['img'] as String),
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                // 이름
                Text(
                  story['name'] as String,
                  style: const TextStyle(fontSize: 12.0, color: Colors.black),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}