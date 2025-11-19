import 'package:flutter/material.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart';
import 'package:instagram/screens/create_post_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? username;

  const ProfileScreen({super.key, this.username});

  // [핵심] 전역에서 접근 가능한 내 게시물 목록 (상태 감지기)
  // 앱을 껐다 켜면 초기화되지만, 실행 중에는 유지됩니다.
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

  // 프로필 정보
  String _name = '';
  String _bio = '';
  String _avatarUrl = 'https://picsum.photos/seed/default/200/200';
  String _followerCount = '0';
  String _followingCount = '0';
  List<String> _mutualFollowers = [];
  
  // 타인 게시물 (고정 리스트)
  List<String> _otherUserPosts = [];

  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    const String loggedInUser = 'ta_junhyuk';

    if (widget.username == null || widget.username == loggedInUser) {
      _isCurrentUser = true;
      _currentUsername = loggedInUser;
      _loadMyData();
    } else {
      _isCurrentUser = false;
      _currentUsername = widget.username!;
      _loadOtherUserData(_currentUsername);
    }
  }

  void _loadMyData() {
    setState(() {
      _name = 'puang';
      _bio = "I'm gonna be the God of Flutter!!";
      _avatarUrl = 'https://picsum.photos/seed/junhyuk/200/200';
      // _postCount는 ValueNotifier의 길이를 사용하므로 여기서 설정 안 함
      _followerCount = '3';
      _followingCount = '9';
    });
  }

  void _loadOtherUserData(String username) {
    if (username == 'imwinter') {
      setState(() {
        _name = 'WINTER';
        _bio = 'aespa';
        _avatarUrl = 'https://picsum.photos/seed/winter/200/200';
        _followerCount = '13M';
        _followingCount = '4';
        _mutualFollowers = ['junehxuk', 'katarinabluu', 'aespa_official'];
        _otherUserPosts = List.generate(12, (i) => 'https://picsum.photos/seed/winter$i/300/300');
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              // [수정] ValueListenableBuilder로 감싸서 게시물 수가 변하면 헤더도 갱신
              child: _isCurrentUser 
                  ? ValueListenableBuilder<List<String>>(
                      valueListenable: ProfileScreen.myPostsNotifier,
                      builder: (context, posts, _) => _buildProfileHeader(posts.length),
                    )
                  : _buildProfileHeader(_otherUserPosts.length),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorWeight: 1.0,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.person_pin_outlined)),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // [핵심 수정] 게시물 그리드 (실시간 반영)
            _isCurrentUser ? _buildMyPostGrid() : _buildOtherPostGrid(),
            const Center(child: Text('Tagged Posts', style: TextStyle(color: Colors.grey))),
          ],
        ),
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

  // 헤더 (게시물 수 동적 표시)
  Widget _buildProfileHeader(int postCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 44, backgroundImage: NetworkImage(_avatarUrl)),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('$postCount', 'Posts'), // 동적 게시물 수
                    _buildStatItem(_followerCount, 'Followers'),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowingListScreen())),
                      child: _buildStatItem(_followingCount, 'Following'),
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
          
          // [수정] 스토리 하이라이트 제거됨 (영상 반영)

          const SizedBox(height: 16),
          _isCurrentUser ? _buildMyButtons() : _buildOtherButtons(),
        ],
      ),
    );
  }

  // [핵심] 내 게시물 그리드 (ValueListenableBuilder 사용)
  Widget _buildMyPostGrid() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: ProfileScreen.myPostsNotifier,
      builder: (context, posts, _) {
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
          ),
          // 게시물 + 1 (추가 버튼)
          itemCount: posts.length + 1,
          itemBuilder: (context, index) {
            // 마지막 아이템은 '+' 버튼
            if (index == posts.length) {
               return GestureDetector(
                 onTap: _showCreateModal,
                 child: Container(color: Colors.white, child: Icon(Icons.add, color: Colors.grey[400], size: 40)),
               );
            }
            return ZoomableGridImage(imageUrl: posts[index]);
          },
        );
      },
    );
  }

  // 타인 게시물 그리드
  Widget _buildOtherPostGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
      ),
      itemCount: _otherUserPosts.length,
      itemBuilder: (context, index) => ZoomableGridImage(imageUrl: _otherUserPosts[index]),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(children: [Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(label, style: const TextStyle(fontSize: 14))]);
  }

  Widget _buildMyButtons() {
    return Row(children: [
      Expanded(child: _grayBtn('Edit profile', _navigateToEditProfile)), const SizedBox(width: 6),
      Expanded(child: _grayBtn('Share profile', () {})), const SizedBox(width: 6),
      _iconBtn(),
    ]);
  }

  Widget _buildOtherButtons() {
    return Row(children: [
      Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _instaBlue, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))), 
      const SizedBox(width: 6),
      Expanded(child: _grayBtn('Message', () {})), const SizedBox(width: 6),
      _iconBtn(),
    ]);
  }

  Widget _grayBtn(String text, VoidCallback onPressed) {
    return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEFEFEF), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: onPressed, child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)));
  }
  
  Widget _iconBtn() => Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.person_add_outlined, size: 20));

  void _showCreateModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
           const SizedBox(height: 16), const Text('Create', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const Divider(),
           ListTile(leading: const Icon(Icons.grid_on), title: const Text('Post'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen())); }),
           ListTile(leading: const Icon(Icons.movie_outlined), title: const Text('Reel'), onTap: (){}),
           ListTile(leading: const Icon(Icons.history), title: const Text('Story'), onTap: (){}),
        ]),
      ),
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
    _overlayEntry = OverlayEntry(builder: (context) => Stack(children: [Container(color: Colors.black54), Center(child: Material(color: Colors.transparent, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.imageUrl, width: MediaQuery.of(context).size.width * 0.9, fit: BoxFit.cover))))]));
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