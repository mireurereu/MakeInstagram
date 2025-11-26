import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/data/user_state.dart'; // 상태 관리 파일 임포트
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart';
import 'package:instagram/screens/create_post_screen.dart';
import 'package:instagram/screens/post_viewer_screen.dart';
import 'package:instagram/widgets/create_bottom_sheet.dart';
import 'package:instagram/screens/main_navigation_screen.dart';
import 'package:instagram/screens/feed_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? username;

  const ProfileScreen({super.key, this.username});

  // 내 게시물 목록 (상태 유지)
  static final ValueNotifier<List<String>> myPostsNotifier = ValueNotifier<List<String>>([
    'https://picsum.photos/seed/post1/300/300',
    'https://picsum.photos/seed/post2/300/300',
    'https://picsum.photos/seed/post3/300/300',
  ]);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isCurrentUser = false;
  String _currentUsername = '';
  bool _isSuggestedVisible = false; // 추천 친구 창 열림 여부

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
    final int tabCount = _isCurrentUser ? 2 : (_currentUsername == 'imnotningning' ? 4 : 3);
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

  void _loadOtherUserData(String username) {
    setState(() {
      // 기본 더미 데이터
      _name = username;
      _bio = 'Instagram User';
      _avatarUrl = 'https://picsum.photos/seed/$username/200/200';
      _followerCount = '120';
      _mutualFollowers = [];
      _otherUserPosts = List.generate(9, (i) => 'https://picsum.photos/seed/${username}_$i/300/300');

      // 특정 유저(imwinter) 데이터 하드코딩
      if (username == 'imwinter') {
        _name = 'WINTER';
        _bio = 'aespa';
        _followerCount = '13M';
        _mutualFollowers = ['junehxuk', 'katarinabluu'];
      }

      // 특정 유저(imnotningning) 데이터 하드코딩 (요청: 4탭, NINGNING, aespa)
      if (username == 'imnotningning') {
        _name = 'NINGNING';
        _bio = 'aespa';
        _followerCount = '10.7M';
        _mutualFollowers = ['imwinter', 'katarinabluu', 'aespa_official'];
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

    if (result != null && result is Map) {
      setState(() {
        _name = result['name'];
        _bio = result['bio'];
        if (result['avatarUrl'] != null) {
          _avatarUrl = result['avatarUrl'];
          // UserState에도 업데이트
          UserState.updateMyAvatarUrl(_avatarUrl);
        }
      });
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
                            final myPosts = allPosts.where((post) => post['username'] == UserState.myId).toList();
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
                  const Center(child: Text('Tagged Posts', style: TextStyle(color: Colors.grey))),
                ]
              : (_currentUsername == 'imnotningning'
                  ? [
                      _buildOtherPostGrid(),
                      const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.ondemand_video, size: 48, color: Colors.grey), SizedBox(height: 8), Text('Reels', style: TextStyle(color: Colors.grey))])),
                      const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.loop, size: 48, color: Colors.grey), SizedBox(height: 8), Text('Reposts', style: TextStyle(color: Colors.grey))])),
                      const Center(child: Text('Tagged Posts', style: TextStyle(color: Colors.grey))),
                    ]
                  : [
                      _buildOtherPostGrid(),
                      const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.ondemand_video, size: 48, color: Colors.grey), SizedBox(height: 8), Text('Reels', style: TextStyle(color: Colors.grey))])),
                      const Center(child: Text('Tagged Posts', style: TextStyle(color: Colors.grey))),
                    ]),
        ),
      ),
      bottomNavigationBar: !_isCurrentUser ? _buildBottomNavBar() : null,
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
          Text(_currentUsername, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.add_box_outlined, size: 28), onPressed: _showCreateModal),
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
          Text(_currentUsername, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          if (_currentUsername == 'imwinter')
             Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.verified, color: _instaBlue, size: 18)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
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
            children: [
              CircleAvatar(
                radius: 44,
                backgroundImage: _getAvatarImageProvider(_avatarUrl),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('$postCount', 'Posts'),
                    _buildStatItem(_followerCount, 'Followers'),
                    // [수정] Following 클릭 시 리스트 화면으로 이동
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (_) => FollowingListScreen(username: _currentUsername)
                          )
                        ).then((_) => _refresh()); // 돌아왔을 때 숫자 갱신
                      },
                      child: _buildStatItem('$realFollowingCount', 'Following'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(_bio, style: const TextStyle(fontSize: 14)),
          
          if (!_isCurrentUser && _mutualFollowers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Followed by ${_mutualFollowers[0]} and others', style: const TextStyle(fontSize: 13)),
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
            crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
          ),
          itemCount: myPosts.length + 1,
            itemBuilder: (context, index) {
            if (index == myPosts.length) {
               return GestureDetector(
                 onTap: _showCreateModal,
                 child: Container(color: Colors.white, child: Icon(Icons.add, color: Colors.grey[400], size: 40)),
               );
            }
            final post = myPosts[index];
            final thumbnailUrl = (post['postImageUrls'] as List).first;
            
            return GestureDetector(
              onTap: () {
                // feed의 실제 데이터를 PostViewerScreen에 전달
                Navigator.push(context, MaterialPageRoute(builder: (_) => PostViewerScreen(posts: myPosts, initialIndex: index)));
              },
              child: ZoomableGridImage(imageUrl: thumbnailUrl),
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
        crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
      ),
      itemCount: _otherUserPosts.length,
      itemBuilder: (context, index) {
        final url = _otherUserPosts[index];
        return GestureDetector(
          onTap: () {
            final built = _otherUserPosts.map((p) => {
              'username': _currentUsername,
              'userAvatarUrl': _avatarUrl,
              'postImageUrls': [p],
              'likeCount': '0',
              'caption': '',
              'timestamp': '',
              'isVideo': false,
            }).toList();
            Navigator.push(context, MaterialPageRoute(builder: (_) => PostViewerScreen(posts: built, initialIndex: index)));
          },
          child: ZoomableGridImage(imageUrl: url),
        );
      },
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(children: [Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(label, style: const TextStyle(fontSize: 14))]);
  }

  Widget _buildMyButtons() {
    return Row(children: [
      Expanded(child: _grayBtn('Edit profile', _navigateToEditProfile)), const SizedBox(width: 6),
      Expanded(child: _grayBtn('Share profile', () {})), const SizedBox(width: 6),
      _iconBtn(Icons.person_add_outlined, () {}),
    ]);
  }

  // [수정] 타인 프로필 버튼 (팔로우/팔로잉 상태 반영)
  Widget _buildOtherButtons() {
    final bool isFollowing = UserState.amIFollowing(_currentUsername);

    return Row(children: [
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                onPressed: () {
                  setState(() {
                    UserState.toggleFollow(_currentUsername);
                    // 팔로우하면 추천 친구창 열기
                    _isSuggestedVisible = true;
                  });
                }, 
                child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
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
        }
      ),
    ]);
  }

  Widget _grayBtn(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEFEFEF), 
        foregroundColor: Colors.black, 
        elevation: 0, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
      ), 
      onPressed: onPressed, 
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))
    );
  }
  
  Widget _iconBtn(IconData icon, VoidCallback onPressed) => GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 36, height: 36, 
      decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(8)), 
      child: Icon(icon, size: 20)
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
                Text('Suggested for you', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('See All', style: TextStyle(color: Color(0xFF3797EF), fontWeight: FontWeight.w600)),
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
                      const Icon(Icons.close, size: 16, color: Colors.grey), // 닫기 버튼 흉내
                      const SizedBox(height: 4),
                      CircleAvatar(
                        radius: 34, 
                        backgroundImage: NetworkImage('https://picsum.photos/seed/suggest$index/100/100')
                      ),
                      const SizedBox(height: 10),
                      Text('User $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Suggested for you', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _instaBlue,
                          minimumSize: const Size(120, 30),
                          elevation: 0,
                        ),
                        child: const Text('Follow', style: TextStyle(color: Colors.white)),
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
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar; _SliverAppBarDelegate(this._tabBar);
  @override double get minExtent => _tabBar.preferredSize.height; @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(context, offset, overlaps) => Container(color: Colors.white, child: _tabBar);
  @override bool shouldRebuild(old) => false;
}

class ZoomableGridImage extends StatefulWidget {
  final String imageUrl;
  const ZoomableGridImage({super.key, required this.imageUrl});
  @override State<ZoomableGridImage> createState() => _ZoomableGridImageState();
}
class _ZoomableGridImageState extends State<ZoomableGridImage> {
  OverlayEntry? _overlayEntry;
  void _showOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final screenW = MediaQuery.of(context).size.width;
    final imageWidth = screenW * 0.9;
    _overlayEntry = OverlayEntry(builder: (context) {
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
                      errorBuilder: (c, e, s) => Container(width: imageWidth, height: imageWidth, color: Colors.grey[300]),
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
                      border: Border(top: BorderSide(color: const Color(0xFFECECEC))),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.favorite, color: Colors.black)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.send_outlined, color: Colors.black)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz, color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
    overlay.insert(_overlayEntry!);
  }
  void _removeOverlay() { _overlayEntry?.remove(); _overlayEntry = null; }
  @override Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _showOverlay(context), onLongPressEnd: (_) => _removeOverlay(), onLongPressCancel: () => _removeOverlay(),
      child: Image.network(widget.imageUrl, fit: BoxFit.cover, loadingBuilder: (c, child, l) => l==null?child:Container(color: Colors.grey[200])),
    );
  }
}