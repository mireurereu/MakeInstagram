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

  // Global feed notifier so other screens can prepend new posts
  static final ValueNotifier<List<Map<String, dynamic>>> feedNotifier = ValueNotifier<List<Map<String, dynamic>>>([
    {
      'id': 'my_post_1',
      'username': 'ta_junhyuk',
      'userAvatarUrl': 'assets/images/profile3.jpg',
      'postImageUrls': ['https://picsum.photos/seed/myphoto1/600/600'],
      'likeCount': '2,543',
      'caption': '오늘 날씨 정말 좋네요 ☀️',
      'timestamp': '2 hours ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c1_1', username: 'imwinter', avatarUrl: 'https://picsum.photos/seed/winter/100/100', text: '날씨 좋아보여요! 😊'),
        Comment(id: 'my_c1_2', username: 'junehxuk', avatarUrl: 'https://picsum.photos/seed/june/100/100', text: '어디야?'),
      ],
    },
    {
      'id': 'my_post_2',
      'username': 'ta_junhyuk',
      'userAvatarUrl': 'assets/images/profile3.jpg',
      'postImageUrls': ['https://picsum.photos/seed/myphoto2/600/600', 'https://picsum.photos/seed/myphoto3/600/600'],
      'likeCount': '1,892',
      'caption': '카페에서 작업 중 ☕️',
      'timestamp': '1 day ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c2_1', username: 'katarinabluu', avatarUrl: 'https://picsum.photos/seed/karina/100/100', text: '분위기 좋다!'),
      ],
    },
    {
      'id': 'my_post_3',
      'username': 'ta_junhyuk',
      'userAvatarUrl': 'assets/images/profile3.jpg',
      'postImageUrls': ['https://picsum.photos/seed/myphoto4/600/600'],
      'likeCount': '3,421',
      'caption': '오랜만에 운동 🏃‍♂️💪',
      'timestamp': '3 days ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c3_1', username: 'yonghyeon5670', avatarUrl: 'https://picsum.photos/seed/yong/100/100', text: '나도 가고싶다'),
        Comment(id: 'my_c3_2', username: 'cch991112', avatarUrl: 'https://picsum.photos/seed/cch/100/100', text: '같이 가자!'),
        Comment(id: 'my_c3_3', username: 'ta_junhyuk', avatarUrl: 'assets/images/profile3.jpg', text: 'ㄱㄱ', replyToUsername: 'cch991112'),
      ],
    },
    {
      'id': 'my_post_4',
      'username': 'ta_junhyuk',
      'userAvatarUrl': 'assets/images/profile3.jpg',
      'postImageUrls': ['https://picsum.photos/seed/myphoto5/600/600', 'https://picsum.photos/seed/myphoto6/600/600', 'https://picsum.photos/seed/myphoto7/600/600'],
      'likeCount': '5,127',
      'caption': '주말 나들이 🌳🌿',
      'timestamp': '5 days ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c4_1', username: 'haetbaaan', avatarUrl: 'https://picsum.photos/seed/haet/100/100', text: '예쁘다 ✨'),
        Comment(id: 'my_c4_2', username: 'cau_ai_', avatarUrl: 'https://picsum.photos/seed/cau/100/100', text: '여기 어디에요?'),
        Comment(id: 'my_c4_3', username: 'ta_junhyuk', avatarUrl: 'assets/images/profile3.jpg', text: '남산이에요!', replyToUsername: 'cau_ai_'),
      ],
    },
    {
      'id': 'my_post_5',
      'username': 'ta_junhyuk',
      'userAvatarUrl': 'assets/images/profile3.jpg',
      'postImageUrls': ['https://picsum.photos/seed/myphoto8/600/600'],
      'likeCount': '4,238',
      'caption': '맛집 발견! 🍜🔥',
      'timestamp': '1 week ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'my_c5_1', username: 'chunganguniv', avatarUrl: 'https://picsum.photos/seed/chungang/100/100', text: '맛있겠다!'),
        Comment(id: 'my_c5_2', username: 'imwinter', avatarUrl: 'https://picsum.photos/seed/winter/100/100', text: 'omg looks delicious 😋'),
      ],
    },
    {
      'id': 'seed1',
      'username': 'aespa_official',
      'userAvatarUrl': 'https://picsum.photos/seed/aespa/100/100',
      'postImageUrls': ['https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'],
      'likeCount': '918,471',
      'caption': 'Ouch!',
      'timestamp': 'September 19',
      'isVideo': true,
      'isVerified': true,
      'comments': [
        Comment(id: 'c1_1', username: 'imwinter', avatarUrl: 'https://picsum.photos/seed/winter/100/100', text: '😍😍😍'),
        Comment(id: 'c1_2', username: 'katarinabluu', avatarUrl: 'https://picsum.photos/seed/karina/100/100', text: 'Amazing!!'),
        Comment(id: 'c1_3', username: 'newjeans_official', avatarUrl: 'https://picsum.photos/seed/newjeans/100/100', text: 'Love this 💕'),
      ],
    },
    {
      'id': 'seed2',
      'username': 'kingshot_mobile',
      'userAvatarUrl': 'https://picsum.photos/seed/kingshot/100/100',
      'postImageUrls': ['https://picsum.photos/seed/post1/600/600','https://picsum.photos/seed/post2/600/600'],
      'likeCount': '3,120',
      'caption': '적을 물리치고 1%가 되어라!',
      'timestamp': '5 days ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'c2_1', username: 'gamer_pro', avatarUrl: 'https://picsum.photos/seed/gamer/100/100', text: '이 게임 완전 재밌어요!'),
        Comment(id: 'c2_2', username: 'mobile_master', avatarUrl: 'https://picsum.photos/seed/mobile/100/100', text: 'ㄹㅇ 꿀잼'),
      ],
    },
    {
      'id': 'seed3',
      'username': 'katarinabluu',
      'userAvatarUrl': 'https://picsum.photos/seed/karina/100/100',
      'postImageUrls': ['https://picsum.photos/seed/post1/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600','https://picsum.photos/seed/post2/600/600'],
      'likeCount': '1,367,684',
      'caption': ' ',
      'timestamp': '5 days ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'c3_1', username: 'imwinter', avatarUrl: 'https://picsum.photos/seed/winter/100/100', text: 'Gorgeous! 😻'),
        Comment(id: 'c3_2', username: 'aespa_official', avatarUrl: 'https://picsum.photos/seed/aespa/100/100', text: 'Beautiful 💖'),
        Comment(id: 'c3_3', username: 'fashion_lover', avatarUrl: 'https://picsum.photos/seed/fashion/100/100', text: 'Where did you get that outfit?'),
        Comment(id: 'c3_4', username: 'katarinabluu', avatarUrl: 'https://picsum.photos/seed/karina/100/100', text: 'Thank you all! 🥰', replyToUsername: 'fashion_lover'),
      ],
    },
    {
      'id': 'seed4',
      'username': 'beom_jun__k',
      'userAvatarUrl': 'https://picsum.photos/seed/beom/100/100',
      'postImageUrls': ['https://picsum.photos/seed/post1/600/600','https://picsum.photos/seed/post2/600/600'],
      'likeCount': '58,918',
      'caption': '두번재 순례길\n햇빛도 그늘도 바람도 오르막도 내리막도 친구들도 \n전부 다 사랑해 정말로!!',
      'timestamp': '17 hours ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'c4_1', username: 'hiker_life', avatarUrl: 'https://picsum.photos/seed/hiker/100/100', text: '너무 멋져요!'),
        Comment(id: 'c4_2', username: 'travel_buddy', avatarUrl: 'https://picsum.photos/seed/travel/100/100', text: '순례길 어디인가요?'),
        Comment(id: 'c4_3', username: 'beom_jun__k', avatarUrl: 'https://picsum.photos/seed/beom/100/100', text: '제주 올레길이에요!', replyToUsername: 'travel_buddy'),
      ],
    },
    {
      'id': 'seed_akmu',
      'username': 'akmu_suhyun',
      'userAvatarUrl': 'https://picsum.photos/seed/akmu/100/100',
      'postImageUrls': ['https://picsum.photos/seed/akmu1/600/600'],
      'likeCount': '245,821',
      'caption': '🎵✨',
      'timestamp': '2 days ago',
      'isVideo': false,
      'isVerified': true,
      'comments': [
        Comment(id: 'c5_1', username: 'music_fan', avatarUrl: 'https://picsum.photos/seed/musicfan/100/100', text: '노래 너무 좋아요 💙'),
        Comment(id: 'c5_2', username: 'kpop_lover', avatarUrl: 'https://picsum.photos/seed/kpop/100/100', text: '목소리 천사예요'),
        Comment(id: 'c5_3', username: 'akmu_fan', avatarUrl: 'https://picsum.photos/seed/akmufan/100/100', text: '수현님 최고!! 👏'),
      ],
    },
    
    {
      'id': 'seed5',
      'username': 'hotelsdotcom',
      'userAvatarUrl': 'https://picsum.photos/seed/hotels/100/100',
      'postImageUrls': ['https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'],
      'likeCount': '548',
      'caption': 'ad',
      'timestamp': '3 days ago',
      'isVideo': true,
      'comments': [
        Comment(id: 'c6_1', username: 'traveler_123', avatarUrl: 'https://picsum.photos/seed/traveler/100/100', text: '할인 코드 있나요?'),
      ],
    },
    {
      'id': 'seed6',
      'username': 'imwinter',
      'userAvatarUrl': 'https://picsum.photos/seed/winter/100/100',
      'postImageUrls': ['https://picsum.photos/seed/winter1/600/600','https://picsum.photos/seed/winter2/600/600'],
      'likeCount': '886,981',
      'caption': '사랑스러운 🗿🤍',
      'timestamp': '3 days ago',
      'isVideo': false,
      'comments': [
        Comment(id: 'c7_1', username: 'aespa_official', avatarUrl: 'https://picsum.photos/seed/aespa/100/100', text: '우리 윈터 💕'),
        Comment(id: 'c7_2', username: 'katarinabluu', avatarUrl: 'https://picsum.photos/seed/karina/100/100', text: 'So cute 😊'),
        Comment(id: 'c7_3', username: 'winter_fan', avatarUrl: 'https://picsum.photos/seed/winterfan/100/100', text: '완전 사랑스러워요 ㅠㅠ'),
        Comment(id: 'c7_4', username: 'my_love', avatarUrl: 'https://picsum.photos/seed/mylove/100/100', text: '여신이다...'),
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
                postImageUrls: List<String>.from(post['postImageUrls']),
                likeCount: post['likeCount'],
                caption: post['caption'],
                timestamp: post['timestamp'],
                isVideo: post['isVideo'] ?? false,
                isVerified: post['isVerified'] ?? false,
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
          {'name': 'newjeans', 'img': 'https://picsum.photos/seed/newjeans/100/100', 'isMe': false},
          {'name': 'katarinabluu', 'img': 'https://picsum.photos/seed/katarina/100/100', 'isMe': false},
          {'name': 'aespa_official', 'img': 'https://picsum.photos/seed/aespa/100/100', 'isMe': false},
          {'name': 'winter', 'img': 'https://picsum.photos/seed/winter/100/100', 'isMe': false},
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