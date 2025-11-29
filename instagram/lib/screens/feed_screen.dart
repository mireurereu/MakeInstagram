import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/screens/notifications_screen.dart';
import 'package:instagram/widgets/post_card_widget.dart';
import 'package:instagram/screens/_posted_banner.dart';
import 'package:instagram/widgets/suggested_reels_widget.dart';
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/data/user_state.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static final ScrollController feedScrollController = ScrollController();
  // Global feed notifier so other screens can prepend new posts
  static final ValueNotifier<List<Map<String, dynamic>>> feedNotifier = ValueNotifier<List<Map<String, dynamic>>>([
    {
      'id': 'my_post_1',
      'username': 'kkuma',
      'userAvatarUrl': 'assets/images/profiles/kkuma.jpg',
      'postImageUrls': ['assets/images/rilakkuma/r1.jpg'],
      'likeCount': '2,543',
      'caption': '오늘 날씨 정말 좋네요 ☀️',
      'timestamp': '2 hours ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c1_1', username: 'hellokitty', avatarUrl: 'assets/images/profiles/hellokitty.jpg', text: '날씨 좋아보여요! 😊'),
        Comment(id: 'my_c1_2', username: 'mymelody', avatarUrl: 'assets/images/profiles/mymelody.jpg', text: '어디야?'),
      ],
    },
    {
      'id': 'my_post_2',
      'username': 'kkuma',
      'userAvatarUrl': 'assets/images/profiles/kkuma.jpg',
      'postImageUrls': ['assets/images/rilakkuma/r2.jpg', 'assets/images/rilakkuma/r3.jpg'],
      'likeCount': '1,892',
      'caption': '카페에서 작업 중 ☕️',
      'timestamp': '1 day ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c2_1', username: 'hangyo', avatarUrl: 'assets/images/profiles/hangyo.jpg', text: '분위기 좋다!'),
      ],
    },
    {
      'id': 'my_post_3',
      'username': 'kkuma',
      'userAvatarUrl': 'assets/images/profiles/kkuma.jpg',
      'postImageUrls': ['assets/images/rilakkuma/r4.jpg'],
      'likeCount': '3,421',
      'caption': '오랜만에 운동 🏃‍♂️💪',
      'timestamp': '3 days ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c3_1', username: 'keroppi', avatarUrl: 'assets/images/profiles/keroppi.jpg', text: '나도 가고싶다'),
        Comment(id: 'my_c3_2', username: 'pochacco', avatarUrl: 'assets/images/profiles/pochacco.jpg', text: '같이 가자!'),
        Comment(id: 'my_c3_3', username: 'kkuma', avatarUrl: 'assets/images/profiles/kkuma.jpg', text: 'ㄱㄱ', replyToUsername: 'pochacco'),
      ],
    },
    {
      'id': 'my_post_4',
      'username': 'kkuma',
      'userAvatarUrl': 'assets/images/profiles/kkuma.jpg',
      'postImageUrls': ['assets/images/rilakkuma/r5.jpg', 'assets/images/rilakkuma/r6.jpg', 'assets/images/rilakkuma/r7.jpg'],
      'likeCount': '5,127',
      'caption': '주말 나들이 🌳🌿',
      'timestamp': '5 days ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c4_1', username: 'pompom', avatarUrl: 'assets/images/profiles/pompom.jpg', text: '예쁘다 ✨'),
        Comment(id: 'my_c4_2', username: 'keroppi', avatarUrl: 'assets/images/profiles/keroppi.jpg', text: '여기 어디에요?'),
        Comment(id: 'my_c4_3', username: 'kkuma', avatarUrl: 'assets/images/profiles/kkuma.jpg', text: '남산이에요!', replyToUsername: 'keroppi'),
      ],
    },
    {
      'id': 'my_post_5',
      'username': 'kkuma',
      'userAvatarUrl': 'assets/images/profiles/kkuma.jpg',
      'postImageUrls': ['assets/images/rilakkuma/r8.jpg'],
      'likeCount': '4,238',
      'caption': '맛집 발견! 🍜🔥',
      'timestamp': '1 week ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c5_1', username: 'cinnamo', avatarUrl: 'assets/images/profiles/cinnamo.jpg', text: '맛있겠다!'),
        Comment(id: 'my_c5_2', username: 'hellokitty', avatarUrl: 'assets/images/profiles/hellokitty.jpg', text: 'omg looks delicious 😋'),
      ],
    },
    {
      'id': 'seed1',
      'username': 'sanrio_official',
      'userAvatarUrl': 'assets/images/profiles/sanrio.jpg',
      'postImageUrls': ['assets/images/rilakkuma/kkuma_video.mp4'],
      'likeCount': '918,471',
      'caption': 'Ouch!',
      'timestamp': 'September 19',
      'isVideo': true,
      'isVerified': true,
      'comments': [
        Comment(id: 'c1_1', username: 'hellokitty', avatarUrl: 'assets/images/profiles/hellokitty.jpg', text: '😍😍😍'),
        Comment(id: 'c1_2', username: 'hangyo', avatarUrl: 'assets/images/profiles/hangyo.jpg', text: 'Amazing!!'),
        Comment(id: 'c1_3', username: 'sanrio_official', avatarUrl: 'assets/images/profiles/sanrio.jpg', text: 'Love this 💕'),
      ],
    },
    {
      'id': 'seed2',
      'username': 'attention',
      'userAvatarUrl': 'assets/images/post/ai.jpg',
      'postImageUrls': 'assets/images/post/post1.jpg',
      'likeCount': '999,999,999',
      'caption': 'Attention is all wou need',
      'timestamp': '5 days ago',
      'isVideo': false,
      'isSponsored': true,
      'sponsoredText': 'Install now',
      'comments': [
        Comment(id: 'c2_1', username: 'hanseo', avatarUrl: 'assets/images/profile3.jpg', text: 'Wow i love haksanghwai!'),
        Comment(id: 'c2_2', username: 'damin', avatarUrl: 'assets/images/profile4.jpg', text: 'seems good'),
      ],
    },
    {
      'id': 'seed3',
      'username': 'hangyo',
      'userAvatarUrl': 'assets/images/profiles/hangyo.jpg',
      'postImageUrls': ['assets/images/post/hg1.jpg','assets/images/post/hg2.jpg','assets/images/post/hg3.jpg','assets/images/post/hg4.jpg',
      'assets/images/post/hg5.jpg','assets/images/post/hg6.jpg','assets/images/post/hg7.jpg','assets/images/post/hg8.jpg',
      'assets/images/post/hg9.jpg','assets/images/post/hg10.jpg','assets/images/post/hg11.jpg','assets/images/post/hg12.jpg'],
      'likeCount': '1,367,684',
      'caption': '🎵✨',
      'timestamp': '5 days ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'c3_1', username: 'hellokitty', avatarUrl: 'assets/images/profiles/hellokitty.jpg', text: 'Gorgeous! 😻'),
        Comment(id: 'c3_2', username: 'sanrio_official', avatarUrl: 'assets/images/profiles/sanrio.jpg', text: 'Beautiful 💖'),
        Comment(id: 'c3_3', username: 'fashion_lover', avatarUrl: 'assets/images/profiles/profile4.jpg', text: 'Where did you get that outfit?'),
        Comment(id: 'c3_4', username: 'kuromi', avatarUrl: 'assets/images/profiles/kuromi.jpg', text: 'Thank you all! 🥰', replyToUsername: 'fashion_lover'),
      ],
    },
    {
      'id': 'seed4',
      'username': 'iamai',
      'userAvatarUrl': 'assets/images/post5.jpg',
      'postImageUrls': ['assets/images/post/song1.jpg','assets/images/post/song2.jpg'],
      'likeCount': '245,821',
      'caption': 'Recommend kpop songs for cold weather 🍂❄️',
      'timestamp': '17 hours ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'c4_1', username: 'music_life', avatarUrl: 'assets/images/post/pol.jpg', text: 'polaroid love!'),
        Comment(id: 'c4_2', username: 'newjeans_buddy', avatarUrl: 'assets/images/post/newjeans.jpg', text: 'Ditto of newjeans'),
        Comment(id: 'c4_3', username: 'hhhhhhhh', avatarUrl: 'assets/images/profile2.jpg', text: 'I agree. I love that', replyToUsername: 'newjeans_buddy'),
      ],
    },
    {
      'id': 'seed5',
      'username': 'mang_gom',
      'userAvatarUrl': 'assets/images/profile5.jpg',
      'postImageUrls': ['assets/images/post/mang_video.mp4'],
      'likeCount': '548',
      'caption': 'ad',
      'timestamp': '3 days ago',
      'isVideo': true,
      'isSponsored': true,
      'sponsoredText': 'Book now',
      'comments': [
        Comment(id: 'c6_1', username: 'traveler_123', avatarUrl: 'assets/images/sample2.jpg', text: 'Can i buy mang-go?'),
      ],
    },
    {
      'id': 'seed6',
      'username': 'hellokitty',
      'userAvatarUrl': 'assets/images/profiles/hellokitty.jpg',
      'postImageUrls': ['assets/images/kitty/k13.jpg','assets/images/kitty/k14.jpg','assets/images/kitty/k15.jpg','assets/images/kitty/k16.jpg','assets/images/kitty/k17.jpg','assets/images/kitty/k18.jpg'],
      'likeCount': '886,981',
      'caption': '사랑스러운 �🤍',
      'timestamp': '3 days ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'c7_1', username: 'sanrio_official', avatarUrl: 'assets/images/profiles/sanrio.jpg', text: '우리 윈터 💕'),
        Comment(id: 'c7_2', username: 'hangyo', avatarUrl: 'assets/images/profiles/hangyo.jpg', text: 'So cute 😊'),
        Comment(id: 'c7_3', username: 'winter_fan', avatarUrl: 'assets/images/sample1.jpg', text: '완전 사랑스러워요 ㅠㅠ'),
        Comment(id: 'c7_4', username: 'my_love', avatarUrl: 'assets/images/sample4.jpg', text: '여신이다...'),
      ],
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
        title: SvgPicture.asset(
          'assets/svg/Logo.svg',
          height: 32.0,
          fit: BoxFit.contain,
        ),
        actions: [
          // Notifications button with badge
          ValueListenableBuilder<bool>(
            valueListenable: NotificationsScreen.hasUnreadNotifications,
            builder: (context, hasUnread, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: NotificationsScreen.showCommentBubble,
                builder: (context, showBubble, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.black, size: 28),
                        onPressed: () {
                          // Clear badge when opening notifications
                          NotificationsScreen.hasUnreadNotifications.value = false;
                          NotificationsScreen.showCommentBubble.value = false;
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
                      // 말풍선 (댓글 알림 시 잠시 표시)
                      if (showBubble)
                        Positioned(
                          top: -6,
                          right: 36,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.chat_bubble,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const DmListScreen();
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    // 오른쪽에서 왼쪽으로 슬라이드
                    const begin = Offset(1.0, 0.0); // 오른쪽 시작
                    const end = Offset.zero; // 중앙 끝
                    const curve = Curves.easeInOut;
                    
                    var tween = Tween(begin: begin, end: end);
                    var curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    );
                    
                    return SlideTransition(
                      position: tween.animate(curvedAnimation),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: feedNotifier,
        builder: (context, feed, _) {
          // 더미 게시물만 feed에서 제외 (실제로 업로드한 게시물은 표시)
          final dummyPostIds = {'my_post_1', 'my_post_2', 'my_post_3', 'my_post_4', 'my_post_5'};
          final displayFeed = feed.where((post) => !dummyPostIds.contains(post['id'])).toList();
          
          return ListView(
            controller: feedScrollController,
            children: [
              _buildStoryBar(),
              // Posted banner (transient) — shows when a new post was just created
              ValueListenableBuilder<Map<String, String?>?>(
                valueListenable: postedBannerNotifier,
                builder: (c, banner, __) {
                  if (banner == null) return const SizedBox.shrink();
                  return PostedBanner(
                    imagePath: banner['image'] ?? '',
                    message: banner['message'] ?? 'Posted! Way to go.',
                    onSend: () {
                      postedBannerNotifier.value = null;
                    },
                  );
                },
              ),
              // build posts from feed notifier
              ...displayFeed.map((post) => PostCardWidget(
                key: ValueKey(post['id']),
                username: post['username'],
                userAvatarUrl: post['userAvatarUrl'],
                postImageUrls: (post['postImageUrls'] is List)
                    ? List<String>.from(post['postImageUrls'])
                    : [post['postImageUrls']?.toString() ?? ''],
                likeCount: post['likeCount'],
                caption: post['caption'],
                timestamp: post['timestamp'],
                isVideo: post['isVideo'] ?? false,
                isSponsored: post['isSponsored'] ?? false,
                sponsoredText: post['sponsoredText'],
                isVerified: post['isVerified'] ?? false,
                isLiked: post['isLiked'] ?? false,
                initialComments: (post['comments'] is List) 
                    ? List<Comment>.from(post['comments']) 
                    : [],
                
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
  
  ImageProvider _getStoryImageProvider(String imagePath) {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else {
      return NetworkImage(imagePath); // fallback
    }
  }
  // [신규] 스토리 바 위젯
  Widget _buildStoryBar() {
    return ValueListenableBuilder<String>(
      valueListenable: UserState.myAvatarUrlNotifier,
      builder: (context, myAvatarUrl, child) {
        // 스토리 데이터 (영상 00:11 상단 참조)
        final stories = [
          {'name': 'Your story', 'img': myAvatarUrl, 'isMe': true},
          {'name': 'keroppi', 'img': 'assets/images/profiles/keroppi.jpg', 'isMe': false},
          {'name': 'hangyo', 'img': 'assets/images/profiles/hangyo.jpg', 'isMe': false},
          {'name': 'sanrio_official', 'img': 'assets/images/profiles/sanrio.jpg', 'isMe': false},
          {'name': 'hellokitty', 'img': 'assets/images/profiles/hellokitty.jpg', 'isMe': false},
          {'name': 'pompom', 'img': 'assets/images/profiles/pompom.jpg', 'isMe': false},
        ];

        return SizedBox(
          height: 140, // 스토리 bar height
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // 가로 스크롤
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              final bool isMe = story['isMe'] == true;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  children: [
                    // 그라데이션 링 + 프로필 사진
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3.5), // 링 두께
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
                            padding: const EdgeInsets.all(2.5), // 사진과 링 사이 흰색 테두리
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: CircleAvatar(
                              radius: 34,
                              backgroundImage: _getStoryImageProvider(story['img'] as String),
                            ),
                          ),
                        ),
                        // 내 스토리일 때만 + 아이콘 표시
                        if (isMe)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.add_circle,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    // 이름
                    SizedBox(
                      width: 76,
                      child: Text(
                        story['name'] as String,
                        style: const TextStyle(fontSize: 12.0, color: Colors.black),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}