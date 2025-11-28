import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:instagram/data/user_state.dart'; // 상태 관리 파일 임포트
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart';
import 'package:instagram/widgets/create_bottom_sheet.dart';
import 'package:instagram/screens/main_navigation_screen.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/widgets/post_card_widget.dart';
import 'package:instagram/widgets/comment_model.dart';

class ProfileScreen extends StatefulWidget {
  final String? username;

  const ProfileScreen({super.key, this.username});

  // 내 게시물 목록 (상태 유지)
  static final ValueNotifier<List<String>> myPostsNotifier =
      ValueNotifier<List<String>>([
        'https://picsum.photos/seed/post1/300/300',
        'https://picsum.photos/seed/post2/300/300',
        'https://picsum.photos/seed/post3/300/300',
      ]);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isCurrentUser = false;
  String _currentUsername = '';
  bool _isSuggestedVisible = false; // 추천 친구 창 열림 여부
  bool _isFollowingPressed = false; // Following 버튼 눌림 상태

  // 프로필 정보
  String _name = '';
  String _bio = '';
  String _avatarUrl = 'https://picsum.photos/seed/default/200/200';
  String _followerCount = '0';
  // _followingCount는 UserState에서 실시간으로 가져옵니다.

  List<String> _mutualFollowers = [];
  List<String> _otherUserPosts = []; // 타인 게시물

  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  void initState() {
    super.initState();
    // UserState에 정의된 내 ID 사용
    if (widget.username == null || widget.username == UserState.myId) {
      _isCurrentUser = true;
      _currentUsername = UserState.myId;
      _loadMyData();
    } else {
      _isCurrentUser = false;
      _currentUsername = widget.username!;
      _loadOtherUserData(_currentUsername);
    }

    // TabController 길이는 현재 사용자일 때 2, 타인 프로필일 때 기본 3.
    // 그러나 특정 사용자(imnotningning)는 4탭을 사용합니다.
    final int tabCount = _isCurrentUser
        ? 2
        : (_currentUsername == 'imnotningning' ? 4 : 3);
    _tabController = TabController(length: tabCount, vsync: this);
  }

  // 화면에 돌아왔을 때 팔로잉 숫자 갱신을 위해 setState 호출
  void _refresh() {
    setState(() {});
  }

  void _loadMyData() {
    setState(() {
      _name = 'puang';
      _bio = "I'm gonna be the God of Flutter!";
      _avatarUrl = UserState.getMyAvatarUrl();
      _followerCount = '3';
    });
  }

  // Edit Profile에서 돌아왔을 때 호출되는 함수
  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialName: _name,
          initialBio: _bio,
          initialAvatarUrl: _avatarUrl,
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _name = result['name'] ?? _name;
        _bio = result['bio'] ?? _bio;
        _avatarUrl = result['avatarUrl'] ?? _avatarUrl;

        // 프로필 사진이 변경되었는지 확인하고 UserState에 저장
        if (result['avatarUrl'] != null &&
            result['avatarUrl'] != UserState.getMyAvatarUrl()) {
          UserState.setMyAvatarUrl(result['avatarUrl']);
          UserState.setProfilePictureChanged(true); // 프로필 사진 변경 플래그 설정
        }
      });
    }
  }

  void _loadOtherUserData(String username) {
    setState(() {
      // 기본 더미 데이터
      _name = username;
      _bio = 'Instagram User';
      _avatarUrl = 'https://picsum.photos/seed/$username/200/200';
      _followerCount = '120';
      _mutualFollowers = [];
      _otherUserPosts = List.generate(
        9,
        (i) => 'https://picsum.photos/seed/${username}_$i/300/300',
      );

      // 특정 유저(hellokitty) 데이터 하드코딩
      if (username == 'hellokitty') {
        _name = 'HELLO KITTY';
        _bio = 'Sanrio Official';
        _avatarUrl = 'assets/images/profiles/hellokitty.jpg';
        _followerCount = '13M';
        _mutualFollowers = ['mymelody', 'hangyo'];
        _otherUserPosts = [
          'assets/images/kitty/k1.jpg',
          'assets/images/kitty/k2.jpg',
          'assets/images/kitty/k3.jpg',
          'assets/images/kitty/k4.jpg',
          'assets/images/kitty/k5.jpg',
          'assets/images/kitty/k6.jpg',
          'assets/images/kitty/k7.jpg',
          'assets/images/kitty/k8.jpg',
          'assets/images/kitty/k9.jpg',
          'assets/images/kitty/k10.jpg',
          'assets/images/kitty/k11.jpg',
          'assets/images/kitty/k12.jpg',
        ];
      }

      // 특정 유저(imnotningning) 데이터 하드코딩 (요청: 4탭, NINGNING, aespa)
      if (username == 'imnotningning') {
        _name = 'NINGNING';
        _bio = 'aespa';
        _followerCount = '10.7M';
        _mutualFollowers = ['hellokitty', 'hangyo', 'sanrio_official'];
        // 다른 사용자 게시물 수는 이미 9로 세팅되어 있음
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ImageProvider _getAvatarImageProvider(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else if (url.startsWith('assets/')) {
      return AssetImage(url);
    } else {
      return FileImage(File(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isCurrentUser ? _buildMyAppBar() : _buildOtherUserAppBar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // 프로필 헤더
                  _isCurrentUser
                      ? ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: FeedScreen.feedNotifier,
                          builder: (context, allPosts, _) {
                            final myPosts = allPosts
                                .where(
                                  (post) => post['username'] == UserState.myId,
                                )
                                .toList();
                            return _buildProfileHeader(myPosts.length);
                          },
                        )
                      : _buildProfileHeader(_otherUserPosts.length),

                  // [추가] 추천 친구 섹션 (다른 사람 프로필이고, 팔로우 중이며, 펼쳐졌을 때)
                  if (!_isCurrentUser && _isSuggestedVisible)
                    _buildSuggestedSection(),
                ],
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorWeight: 1.0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: _isCurrentUser
                      ? const [
                          Tab(icon: Icon(Icons.grid_on)),
                          Tab(icon: Icon(Icons.person_pin_outlined)),
                        ]
                      : (_currentUsername == 'imnotningning'
                            ? const [
                                Tab(icon: Icon(Icons.grid_on)),
                                Tab(icon: Icon(Icons.ondemand_video)),
                                Tab(icon: Icon(Icons.loop)),
                                Tab(icon: Icon(Icons.person_pin_outlined)),
                              ]
                            : const [
                                Tab(icon: Icon(Icons.grid_on)),
                                Tab(icon: Icon(Icons.ondemand_video)),
                                Tab(icon: Icon(Icons.person_pin_outlined)),
                              ]),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _isCurrentUser
              ? [
                  _buildMyPostGrid(),
                  const Center(
                    child: Text(
                      'Tagged Posts',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ]
              : (_currentUsername == 'imnotningning'
                    ? [
                        _buildOtherPostGrid(),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.ondemand_video,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Reels',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.loop, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Reposts',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Tagged Posts',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ]
                    : [
                        _buildOtherPostGrid(),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.ondemand_video,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Reels',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Tagged Posts',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ]),
        ),
      ),
      bottomNavigationBar: !_isCurrentUser ? _buildBottomNavBar() : null,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFDBDBDB), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) {
            Navigator.pop(context);
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
              (route) => false,
            );
            mainNavKey.currentState?.changeTab(index);
          }
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined, size: 28),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined, size: 28),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<String>(
              valueListenable: UserState.myAvatarUrlNotifier,
              builder: (context, avatarUrl, child) {
                return Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.black, width: 1.5),
                    image: DecorationImage(
                      image: _getAvatarImageProvider(avatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  AppBar _buildMyAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          const Icon(Icons.lock_outline, size: 18),
          const SizedBox(width: 6),
          Text(
            _currentUsername,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_box_outlined, size: 28),
          onPressed: _showCreateModal,
        ),
        IconButton(icon: const Icon(Icons.menu, size: 28), onPressed: () {}),
      ],
    );
  }

  AppBar _buildOtherUserAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          Text(
            _currentUsername,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          if (_currentUsername == 'hellokitty')
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.verified, color: _instaBlue, size: 18),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
      ],
    );
  }

  Widget _buildProfileHeader(int postCount) {
    // [핵심] 팔로잉 숫자는 UserState에서 실시간으로 가져옴
    final realFollowingCount = UserState.getFollowingCount(_currentUsername);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 사진
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: _getAvatarImageProvider(_avatarUrl),
                  ),
                  // What's new 말풍선
                  Positioned(
                    top: -12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              "What's\nnew?",
                              style: TextStyle(fontSize: 10, height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // 말풍선 꼬리
                          Positioned(
                            bottom: -4,
                            left: 20,
                            child: CustomPaint(
                              size: const Size(8, 5),
                              painter: _BubbleTailPainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // + 아이콘
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 28),
              // 이름과 통계를 세로로 배치
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이름
                      Text(
                        _name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 통계를 가로로 배치
                      Row(
                        children: [
                          _buildStatItem('$postCount', 'posts'),
                          const Spacer(flex: 2),
                          _buildStatItem(_followerCount, 'followers'),
                          const Spacer(flex: 2),
                          // [수정] Following 클릭 시 리스트 화면으로 이동 + 눌렀을 때만 그라데이션 효과
                          GestureDetector(
                            onTapDown: (_) {
                              setState(() {
                                _isFollowingPressed = true;
                              });
                            },
                            onTapUp: (_) {
                              setState(() {
                                _isFollowingPressed = false;
                              });
                            },
                            onTapCancel: () {
                              setState(() {
                                _isFollowingPressed = false;
                              });
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FollowingListScreen(
                                    username: _currentUsername,
                                  ),
                                ),
                              ).then((_) => _refresh()); // 돌아왔을 때 숫자 갱신
                            },
                            child: Container(
                              decoration: _isFollowingPressed
                                  ? BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFFE8E8E8), // 왼쪽 진한 회색
                                          Color(0xFFF8F8F8), // 오른쪽 연한 회색
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    )
                                  : null,
                              padding: _isFollowingPressed
                                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                                  : null,
                              child: _buildStatItem(
                                '$realFollowingCount',
                                'following',
                              ),
                            ),
                          ),
                          const Spacer(flex: 1),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bio
          Text(_bio, style: const TextStyle(fontSize: 14)),

          if (!_isCurrentUser && _mutualFollowers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Followed by ${_mutualFollowers[0]} and others',
                style: const TextStyle(fontSize: 13),
              ),
            ),

          const SizedBox(height: 16),
          _isCurrentUser ? _buildMyButtons() : _buildOtherButtons(),
        ],
      ),
    );
  }

  Widget _buildMyPostGrid() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: FeedScreen.feedNotifier,
      builder: (context, allPosts, _) {
        // feed에서 내 게시물만 필터링 (feedNotifier에 이미 최신순이므로 역순 제거)
        final myPosts = allPosts
            .where((post) => post['username'] == UserState.myId)
            .toList();

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 3 / 4,
          ),
          itemCount: myPosts.length + 1,
          itemBuilder: (context, index) {
            if (index == myPosts.length) {
              return GestureDetector(
                onTap: _showCreateModal,
                child: Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.add, color: Colors.black, size: 40),
                ),
              );
            }
            final post = myPosts[index];
            final thumbnailUrl = (post['postImageUrls'] as List).first;

            return GestureDetector(
              onTap: () {
                // 클릭한 게시물부터 시작하는 피드 화면 열기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _ProfilePostFeedScreen(
                      posts: myPosts,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              onLongPressStart: (_) {
                _showPostPreview(context, thumbnailUrl);
              },
              onLongPressEnd: (_) {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Image.network(thumbnailUrl, fit: BoxFit.cover),
            );
          },
        );
      },
    );
  }

  Widget _buildOtherPostGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 3 / 4,
      ),
      itemCount: _otherUserPosts.length,
      itemBuilder: (context, index) {
        final url = _otherUserPosts[index];
        return GestureDetector(
          onTap: () {
            final built = _otherUserPosts
                .map(
                  (p) => {
                    'username': _currentUsername,
                    'userAvatarUrl': _avatarUrl,
                    'postImageUrls': [p],
                    'likeCount': '0',
                    'caption': '',
                    'timestamp': '',
                    'isVideo': false,
                  },
                )
                .toList();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _ProfilePostFeedScreen(
                  posts: built,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ZoomableGridImage(imageUrl: url),
        );
      },
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildMyButtons() {
    return Row(
      children: [
        Expanded(child: _grayBtn('Edit profile', _navigateToEditProfile)),
        const SizedBox(width: 6),
        Expanded(child: _grayBtn('Share profile', () {})),
        const SizedBox(width: 6),
        _iconBtn(Icons.person_add_outlined, () {}),
      ],
    );
  }

  // [수정] 타인 프로필 버튼 (팔로우/팔로잉 상태 반영)
  Widget _buildOtherButtons() {
    final bool isFollowing = UserState.amIFollowing(_currentUsername);

    return Row(
      children: [
        Expanded(
          child: isFollowing
              ? _grayBtn('Following', () {
                  setState(() {
                    UserState.toggleFollow(_currentUsername);
                  });
                })
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _instaBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      UserState.toggleFollow(_currentUsername);
                      // 팔로우하면 추천 친구창 열기
                      _isSuggestedVisible = true;
                    });
                  },
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Expanded(child: _grayBtn('Message', () {})), const SizedBox(width: 6),
        // 추천 친구 토글 버튼
        _iconBtn(
          _isSuggestedVisible ? Icons.person_add : Icons.person_add_outlined,
          () {
            setState(() {
              _isSuggestedVisible = !_isSuggestedVisible;
            });
          },
        ),
      ],
    );
  }

  Widget _grayBtn(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEFEFEF),
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onPressed) => GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20),
    ),
  );

  // [신규] 추천 친구 섹션 위젯
  Widget _buildSuggestedSection() {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 10),
      height: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Suggested for you',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFF3797EF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ), // 닫기 버튼 흉내
                      const SizedBox(height: 4),
                      CircleAvatar(
                        radius: 34,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/seed/suggest$index/100/100',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'User $index',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Suggested for you',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _instaBlue,
                          minimumSize: const Size(120, 30),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateBottomSheet(),
    );
  }

  void _showPostPreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => _PostPreviewOverlay(
        avatarUrl: _avatarUrl,
        username: _currentUsername,
        postImageUrl: imageUrl,
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(context, offset, overlaps) =>
      Container(color: Colors.white, child: _tabBar);
  @override
  bool shouldRebuild(old) => false;
}

class _PostPreviewOverlay extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final String postImageUrl;

  const _PostPreviewOverlay({
    required this.avatarUrl,
    required this.username,
    required this.postImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.92,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더 (프로필 사진 + ID)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: avatarUrl.startsWith('http')
                            ? NetworkImage(avatarUrl)
                            : avatarUrl.startsWith('assets/')
                            ? AssetImage(avatarUrl) as ImageProvider
                            : FileImage(File(avatarUrl)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // 게시물 이미지
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(0),
                  ),
                  child: Image.network(
                    postImageUrl,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                ),
                // 하단 아이콘 4개
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, size: 28),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, size: 28),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_outlined, size: 28),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZoomableGridImage extends StatefulWidget {
  final String imageUrl;
  const ZoomableGridImage({super.key, required this.imageUrl});
  @override
  State<ZoomableGridImage> createState() => _ZoomableGridImageState();
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ZoomableGridImageState extends State<ZoomableGridImage> {
  OverlayEntry? _overlayEntry;
  void _showOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final screenW = MediaQuery.of(context).size.width;
    final imageWidth = screenW * 0.9;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Container(color: Colors.black54),
            // Centered column with enlarged image and action bar immediately beneath it
            Center(
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.imageUrl,
                        width: imageWidth,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: imageWidth,
                          height: imageWidth,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    // action bar directly attached under image
                    Container(
                      width: imageWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border(
                          top: BorderSide(color: const Color(0xFFECECEC)),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.search, color: Colors.black),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.send_outlined,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _showOverlay(context),
      onLongPressEnd: (_) => _removeOverlay(),
      onLongPressCancel: () => _removeOverlay(),
      child: Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (c, child, l) =>
            l == null ? child : Container(color: Colors.grey[200]),
      ),
    );
  }
}

// 프로필 게시물 피드 화면 (세로 스크롤)
class _ProfilePostFeedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  final int initialIndex;

  const _ProfilePostFeedScreen({
    required this.posts,
    required this.initialIndex,
  });

  @override
  State<_ProfilePostFeedScreen> createState() => _ProfilePostFeedScreenState();
}

class _ProfilePostFeedScreenState extends State<_ProfilePostFeedScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // 초기 위치로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && widget.initialIndex > 0) {
        // 각 포스트의 대략적인 높이를 계산하여 스크롤
        _scrollController.jumpTo(widget.initialIndex * 600.0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Posts',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return PostCardWidget(
            key: ValueKey(post['id'] ?? 'post_$index'),
            username: post['username'] as String? ?? 'user',
            userAvatarUrl: post['userAvatarUrl'] as String? ?? '',
            postImageUrls: List<String>.from(
              post['postImageUrls'] ?? [post['image'] ?? ''],
            ),
            likeCount: post['likeCount']?.toString() ?? '0',
            caption: post['caption'] as String? ?? '',
            timestamp: post['timestamp'] as String? ?? '',
            isVideo: post['isVideo'] as bool? ?? false,
            initialComments: (post['comments'] as List<Comment>?) ?? [],
            isVerified: post['isVerified'] as bool? ?? false,
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFDBDBDB), width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 4, // Profile tab
        onTap: (index) {
          if (index == 0) {
            // Home: Navigate back and switch to Home tab
            Navigator.popUntil(context, (route) => route.isFirst);
            mainNavKey.currentState?.changeTab(0);
          } else if (index == 1) {
            // Search
            Navigator.popUntil(context, (route) => route.isFirst);
            mainNavKey.currentState?.changeTab(1);
          } else if (index == 2) {
            // Add post
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushNamed(context, '/create_post');
          } else if (index == 3) {
            // Reels
            Navigator.popUntil(context, (route) => route.isFirst);
            mainNavKey.currentState?.changeTab(3);
          } else if (index == 4) {
            // Profile: Go back
            Navigator.pop(context);
          }
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined, size: 28),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined, size: 28),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<String>(
              valueListenable: UserState.myAvatarUrlNotifier,
              builder: (context, avatarUrl, child) {
                return Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.black, width: 1.5),
                    image: DecorationImage(
                      image: _getImageProvider(avatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }
}