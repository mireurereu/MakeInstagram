import 'package:flutter/material.dart';
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/screens/notifications_screen.dart';
import 'package:instagram/widgets/post_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // [핵심 수정] 외부에서 접근 가능한 데이터 저장소 (static)
  static final ValueNotifier<List<Map<String, dynamic>>> feedNotifier = 
      ValueNotifier<List<Map<String, dynamic>>>([
    {
      'username': 'karinabluu',
      'userAvatarUrl': 'https://picsum.photos/seed/karina/100/100',
      'postImageUrls': ['assets/images/post_1.jpg', 'assets/images/post_2.jpg'],
      'likeCount': '1,367,685',
      'caption': 'more',
      'timestamp': '5 days ago',
      'isVideo': false,
    },
    {
      'username': 'aespa_official',
      'userAvatarUrl': 'https://picsum.photos/seed/aespa/100/100',
      'postImageUrls': ['assets/images/video_thumb.jpg'],
      'likeCount': '918,471',
      'caption': 'Bee~ Gese Stay Alive 🐝',
      'timestamp': '5 days ago',
      'isVideo': true,
    },
    {
      'username': 'imwinter',
      'userAvatarUrl': 'https://picsum.photos/seed/winter/100/100',
      'postImageUrls': ['assets/images/post_3.jpg', 'assets/images/post_4.jpg'],
      'likeCount': '886,981',
      'caption': '사랑스러운 🗿🤍',
      'timestamp': '3 days ago',
      'isVideo': false,
    },
  ]);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Image.asset(
          'assets/images/insta_logo.png',
          height: 32,
          errorBuilder: (c, e, s) => const Text('Instagram', style: TextStyle(fontFamily: 'Billabong', fontSize: 30)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DmListScreen())),
          ),
        ],
      ),
      // [핵심 수정] ValueListenableBuilder 사용
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: HomeScreen.feedNotifier,
        builder: (context, feedData, child) {
          return ListView.builder(
            itemCount: feedData.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    _buildStoryBar(),
                    const Divider(height: 1, color: Color(0xFFDBDBDB)),
                  ],
                );
              }
              final post = feedData[index - 1];
              return PostCardWidget(
                username: post['username'],
                userAvatarUrl: post['userAvatarUrl'],
                postImageUrls: post['postImageUrls'],
                likeCount: post['likeCount'],
                caption: post['caption'],
                timestamp: post['timestamp'],
                isVideo: post['isVideo'],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStoryBar() {
    final stories = [
      {'name': 'Your story', 'img': 'https://picsum.photos/seed/junhyuk/100/100', 'isMe': true},
      {'name': 'newjeans', 'img': 'https://picsum.photos/seed/newjeans/100/100', 'isMe': false},
      {'name': 'katarinabluu', 'img': 'https://picsum.photos/seed/karina/100/100', 'isMe': false},
      {'name': 'aespa_official', 'img': 'https://picsum.photos/seed/aespa/100/100', 'isMe': false},
      {'name': 'winter', 'img': 'https://picsum.photos/seed/winter/100/100', 'isMe': false},
    ];
    return SizedBox(
      height: 115,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        itemCount: stories.length,
        itemBuilder: (c, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: stories[i]['isMe'] == true ? null : const LinearGradient(
                  colors: [Color(0xFFFBAA47), Color(0xFFD91A46), Color(0xFFA60F93)], begin: Alignment.bottomLeft, end: Alignment.topRight),
              ),
              child: Container(
                padding: const EdgeInsets.all(2), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(stories[i]['img'] as String)),
              ),
            ),
            const SizedBox(height: 4), Text(stories[i]['name'] as String, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}