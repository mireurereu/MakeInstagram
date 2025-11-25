import 'package:flutter/material.dart';
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/screens/notifications_screen.dart';
import 'package:instagram/widgets/post_card_widget.dart';
import 'package:instagram/screens/_posted_banner.dart';
import 'package:instagram/widgets/suggested_reels_widget.dart';
import 'package:instagram/widgets/comment_model.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  // Global feed notifier so other screens can prepend new posts
  static final ValueNotifier<List<Map<String, dynamic>>> feedNotifier = ValueNotifier<List<Map<String, dynamic>>>([
    {
      'id': 'seed1',
      'username': 'aespa_official',
      'userAvatarUrl': 'https://picsum.photos/seed/aespa/100/100',
      'postImageUrls': ['https://picsum.photos/seed/video_thumb/600/600'],
      'likeCount': '918,471',
      'caption': 'Ouch!',
      'timestamp': 'September 19',
      'isVideo': true
    },
    {
      'id': 'seed2',
      'username': 'kingshot_mobile',
      'userAvatarUrl': 'https://picsum.photos/seed/kingshot/100/100',
      'postImageUrls': ['https://picsum.photos/seed/post1/600/600','https://picsum.photos/seed/post2/600/600'],
      'likeCount': '3,120',
      'caption': '적을 물리치고 1%가 되어라!',
      'timestamp': '5 days ago',
      'isVideo': false
    },
    {
      'id': 'seed3',
      'username': 'katarinabluu',
      'userAvatarUrl': 'https://picsum.photos/seed/karina/100/100',
      'postImageUrls': ['https://picsum.photos/seed/post1/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600'],
      'likeCount': '1,367,684',
      'caption': ' ',
      'timestamp': '5 days ago',
      'isVideo': false
    },
    {
      'id': 'seed4',
      'username': 'beom_jun__k',
      'userAvatarUrl': 'https://picsum.photos/seed/beom/100/100',
      'postImageUrls': ['https://picsum.photos/seed/post1/600/600','https://picsum.photos/seed/post2/600/600'],
      'likeCount': '58,918',
      'caption': '두번재 순례길\n햇빛도 그늘도 바람도 오르막도 내리막도 친구들도 \n전부 다 사랑해 정말로!!',
      'timestamp': '17 hours ago',
      'isVideo': false
    },
    
    {
      'id': 'seed5',
      'username': 'hotelsdotcom',
      'userAvatarUrl': 'https://picsum.photos/seed/hotels/100/100',
      'postImageUrls': ['https://picsum.photos/seed/video_thumb/600/600'],
      'likeCount': '548',
      'caption': 'ad',
      'timestamp': '3 days ago',
      'isVideo': true
    },
    {
      'id': 'seed6',
      'username': 'imwinter',
      'userAvatarUrl': 'https://picsum.photos/seed/winter/100/100',
      'postImageUrls': ['https://picsum.photos/seed/winter1/600/600','https://picsum.photos/seed/winter2/600/600'],
      'likeCount': '886,981',
      'caption': '사랑스러운 🗿🤍',
      'timestamp': '3 days ago',
      'isVideo': false
    }
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Image.asset(
          'assets/images/insta_logo.png',
          height: 32.0,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text('Instagram', style: TextStyle(color: Colors.black, fontFamily: 'Billabong', fontSize: 28.0, fontWeight: FontWeight.w500)),
        ),
        actions: [
          // Notifications button with badge
          ValueListenableBuilder<bool>(
            valueListenable: NotificationsScreen.hasUnreadNotifications,
            builder: (context, hasUnread, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.black, size: 28),
                    onPressed: () {
                      // Clear badge when opening notifications
                      NotificationsScreen.hasUnreadNotifications.value = false;
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsScreen()));
                    },
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(icon: const Icon(Icons.send_outlined, color: Colors.black, size: 28), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (c) => const DmListScreen())); }),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: feedNotifier,
        builder: (context, feed, _) {
          return ListView(
            children: [
              _buildStoryBar(),
              const SizedBox(height: 8),
              // Posted banner (transient) — shows when a new post was just created
              ValueListenableBuilder<Map<String, String?>?>(
                valueListenable: postedBannerNotifier,
                builder: (c, banner, __) {
                  if (banner == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: PostedBanner(
                      imagePath: banner['image'] ?? '',
                      message: banner['message'] ?? 'Posted! Way to go.',
                      onSend: () {
                        postedBannerNotifier.value = null;
                      },
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFDBDBDB)),
              // build posts from feed notifier
              ...feed.map((post) => PostCardWidget(
                key: ValueKey(post['id']),
                username: post['username'],
                userAvatarUrl: post['userAvatarUrl'],
                postImageUrls: List<String>.from(post['postImageUrls']),
                likeCount: post['likeCount'],
                caption: post['caption'],
                timestamp: post['timestamp'],
                isVideo: post['isVideo'] ?? false,
                initialComments: post['comments'] != null ? List<Comment>.from(post['comments']) : null,
                onLikeChanged: (postId, likeCount, isLiked) {
                  final current = feedNotifier.value;
                  final idx = current.indexWhere((p) => p['id'] == postId);
                  if (idx != -1) {
                    current[idx]['likeCount'] = likeCount.toString();
                    current[idx]['isLiked'] = isLiked;
                    // trigger notifier update
                    feedNotifier.value = List<Map<String, dynamic>>.from(current);
                  }
                },
                onCommentsChanged: (postId, comments) {
                  final current = feedNotifier.value;
                  final idx = current.indexWhere((p) => p['id'] == postId);
                  if (idx != -1) {
                    current[idx]['comments'] = comments;
                    feedNotifier.value = List<Map<String, dynamic>>.from(current);
                  }
                },
              )),
              const SuggestedReelsWidget(),
            ],
          );
        },
      ),
    );
  }

  // transient posted banner notifier: {'image': path, 'message': text}
  static final ValueNotifier<Map<String, String?>?> postedBannerNotifier = ValueNotifier(null);
  // [신규] 스토리 바 위젯
  Widget _buildStoryBar() {
    // 스토리 데이터 (영상 00:11 상단 참조)
    final stories = [
      {'name': 'Your story', 'img': 'https://picsum.photos/seed/junhyuk/100/100', 'isMe': true},
      {'name': 'newjeans', 'img': 'https://picsum.photos/seed/newjeans/100/100', 'isMe': false},
      {'name': 'katarinabluu', 'img': 'https://picsum.photos/seed/katarina/100/100', 'isMe': false},
      {'name': 'aespa_official', 'img': 'https://picsum.photos/seed/aespa/100/100', 'isMe': false},
      {'name': 'winter', 'img': 'https://picsum.photos/seed/winter/100/100', 'isMe': false},
    ];

    return SizedBox(
      height: 128, // 스토리 bar height increased to avoid overflow on small devices
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // 가로 스크롤
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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