import 'package:flutter/material.dart';
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/screens/notifications_screen.dart';
import 'package:instagram/widgets/post_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Instagram_logo.svg/1200px-Instagram_logo.svg.png',
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
      body: ListView(
        children: [
          _buildStoryBar(),
          const Divider(height: 1, color: Color(0xFFDBDBDB)),
          const PostCardWidget(
            username: 'karinabluu', userAvatarUrl: 'https://picsum.photos/seed/karina/100/100',
            postImageUrls: ['https://picsum.photos/seed/post1/600/600', 'https://picsum.photos/seed/post2/600/600'],
            likeCount: '1,367,685', caption: 'more', timestamp: '5 days ago',
          ),
          const PostCardWidget(
             username: 'aespa_official', userAvatarUrl: 'https://picsum.photos/seed/aespa/100/100',
             postImageUrls: ['https://picsum.photos/seed/video_thumb/600/600'],
             likeCount: '918,471', caption: 'Bee~ Gese Stay Alive 🐝', timestamp: '5 days ago', isVideo: true,
          ),
          const PostCardWidget(
            username: 'imwinter', userAvatarUrl: 'https://picsum.photos/seed/winter/100/100',
            postImageUrls: ['https://picsum.photos/seed/winter1/600/600', 'https://picsum.photos/seed/winter2/600/600'],
            likeCount: '886,981', caption: '사랑스러운 🗿🤍', timestamp: '3 days ago',
          ),
        ],
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
      height: 100,
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