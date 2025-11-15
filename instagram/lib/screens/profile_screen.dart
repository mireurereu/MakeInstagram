import 'package:flutter/material.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart';

// --- 1. (수정) username 파라미터 추가 ---
class ProfileScreen extends StatefulWidget {
  final String? username; // 'ta_junhyuk' 또는 'imwinter' 등

  const ProfileScreen({
    super.key,
    this.username, // null이면 '내 프로필'로 간주
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- 2. (수정) 상태 변수 및 로직 변경 ---
  bool _isCurrentUser = false;
  String _currentUsername = '';

  // 프로필 정보 (상태 변수)
  String _name = '';
  String _bio = '';
  String _avatarUrl = 'https://picsum.photos/seed/default/200/200';
  int _postCount = 0;
  String _followerCount = '0';
  String _followingCount = '0';
  List<String> _mutualFollowers = [];

  List<String> _posts = [
    'https://picsum.photos/seed/lenovo_box/300/300', // 왼쪽 (인덱스 0)
    'https://picsum.photos/seed/flutter_code/300/300', // 오른쪽 (인덱스 1)
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // (임시) 현재 로그인한 유저 이름 (원래는 Provider 등에서 가져옴)
    const String loggedInUser = 'ta_junhyuk';

    if (widget.username == null || widget.username == loggedInUser) {
      // '내 프로필'일 경우
      _isCurrentUser = true;
      _currentUsername = loggedInUser;
      _loadMyData(); // 이전에 저장된 내 데이터 로드
    } else {
      // '다른 유저 프로필'일 경우
      _isCurrentUser = false;
      _currentUsername = widget.username!;
      _loadOtherUserData(_currentUsername); // 3. (신규) 다른 유저 데이터 로드
    }
  }

  // (기존) '내 프로필' 데이터 로드
  void _loadMyData() {
    setState(() {
      _name = 'puang';
      _bio = 'I\'m gonna be the God of Flutter!';
      _avatarUrl = 'https://picsum.photos/seed/profile/200/200';
      _postCount = 3;
      _followerCount = '3';
      _followingCount = '9';
    });
  }

  // --- 3. (신규) '다른 유저' 데이터 로드 ---
  void _loadOtherUserData(String username) {
    // (임시) Firebase/서버에서 데이터를 가져오는 대신 Mock 데이터 사용
    if (username == 'imwinter') {
      setState(() {
        _name = 'WINTER';
        _bio = 'aespa';
        _avatarUrl = 'https://picsum.photos/seed/winter/200/200';
        _followerCount = '13M';
        _followingCount = '4';
        _mutualFollowers = ['junehxuk', 'katarinabluu', 'aespa_official'];
        _posts = [
          'https://picsum.photos/seed/winter1/300/300',
          'https://picsum.photos/seed/winter2/300/300',
          'https://picsum.photos/seed/winter3/300/300',
          'https://picsum.photos/seed/winter4/300/300',
          'https://picsum.photos/seed/winter5/300/300',
          'https://picsum.photos/seed/winter6/300/300',
        ];
      });
    }
    // TODO: 'karina', 'aespa_official' 등 다른 유저 데이터도 추가
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // (기존) 'Edit Profile' 이동 로직 (변경 없음)
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
        _avatarUrl = result['avatarUrl'];
      });
    }
  }

  // --- 4. (수정) Build 메서드에서 AppBar 분기 ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // (라이트 모드)
      appBar: _isCurrentUser
          ? _buildMyAppBar(context) // '내 프로필' 앱 바
          : _buildOtherUserAppBar(context), // '다른 유저' 앱 바
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildProfileHeader(context),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.person_pin_outlined)),
                  ],
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        // (TabBarView, GridView 등 나머지 코드는 동일...)
        body: TabBarView(
          controller: _tabController,
          children: [
            // 첫 번째 탭: 포스트 그리드
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: _isCurrentUser ? _posts.length + 1 : _posts.length, // (수정) _postCount 상태 사용
              itemBuilder: (context, index) {
                // (수정) '내 프로필'이고, 마지막 인덱스일 경우
                if (_isCurrentUser && index == _posts.length) {
                  // 4. '+' 버튼을 렌더링
                  return _buildAddPostButton();
                }

                // (수정) 그 외에는 _posts 리스트의 이미지를 렌더링
                final postUrl = _posts[index];
                return Image.network(
                  postUrl,
                  fit: BoxFit.cover,
                );
              },
            ),
            // 두 번째 탭: 태그된 포스트
            Center(
              child: Text(
                'Tagged Posts',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAddPostButton() {
    return GestureDetector(
      onTap: () => _showCreateModal(context), // 5. 탭하면 함수 호출
      child: Container(
        color: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.grey[800],
          size: 40.0,
        ),
      ),
    );
  }

  void _navigateAndAddPost() async {
    // 참고: 
    // 현재 `new_post_screen`은 'Share' 버튼을 누르면 `popUntil`을 사용해
    // 'FeedScreen'으로 돌아가도록 설계되어 있습니다.
    //
    // 'ProfileScreen'에서 즉시 갱신을 보려면 `new_post_screen`이
    // `popUntil` 대신 `pop(newPostUrl)`을 반환하도록 수정해야 합니다.
    //
    // 여기서는 "게시물 추가"를 시뮬레이션하여
    // "가장 왼쪽에 추가되는" UI를 즉시 보여드립니다.

    // 1. (시뮬레이션) 1초간 '업로드' 대기
    print('Posting new photo...');
    await Future.delayed(Duration(seconds: 1));
    
    // 2. (시뮬레이션) 새 게시물 URL 생성
    final String newPostUrl =
        'https://picsum.photos/seed/new_post_${DateTime.now().millisecondsSinceEpoch}/300/300';

    // 3. (핵심) setState 호출
    setState(() {
      // "가장 왼쪽에 업로드" -> 리스트의 맨 앞(index 0)에 추가
      _posts.insert(0, newPostUrl);
    });
    print('New post added to the left!');


    /* --- (참고) 실제 앱을 위한 주석 ---
    
    // 1. `new_post_screen` 등이 URL을 반환하도록 수정했다면,
    //    아래 코드를 사용하여 실제 업로드 로직을 실행할 수 있습니다.
    
    final newPostUrl = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    // 2. URL을 성공적으로 반환받았다면, state 갱신
    if (newPostUrl != null && newPostUrl is String) {
      setState(() {
        _posts.insert(0, newPostUrl);
      });
    }
    
    */
  }

  // --- 5. (수정) '내 프로필' 앱 바 ---
  // (기존 _buildAppBar에서 이름 변경)
  AppBar _buildMyAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.lock_outline, size: 20.0),
          const SizedBox(width: 4.0),
          Text(
            _currentUsername,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add_box_outlined, size: 28.0),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.menu, size: 28.0),
          onPressed: () {},
        ),
      ],
    );
  }

  // --- 6. (신규) '다른 유저 프로필' 앱 바 ---
  AppBar _buildOtherUserAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: Row(
        children: [
          Text(
            _currentUsername,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
          if (_currentUsername == 'imwinter') // (임시) 인증 배지
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(Icons.verified, color: Colors.blue, size: 20.0),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, size: 28.0),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, size: 28.0),
          onPressed: () {},
        ),
      ],
    );
  }

  // --- 7. (수정) 프로필 헤더 (버튼 분기) ---
  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundImage: NetworkImage(_avatarUrl), // (상태 사용)
              ),
              _buildStatColumn('$_postCount', 'Posts'), // (상태 사용)
              _buildStatColumn(_followerCount, 'Followers'), // (상태 사용)
                  GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        // 1단계에서 만든 새 팔로잉 화면으로 연결
                        builder: (context) => const FollowingListScreen()),
                  );
                },
                child: _buildStatColumn(_followingCount, 'Following'), // (상태 사용)
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(_name, // (상태 사용)
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(_bio, style: TextStyle(color: Colors.black)), // (상태 사용)
          
          // (스크린샷) 'Followed by...' (다른 유저 프로필일 때만)
          if (!_isCurrentUser && _mutualFollowers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              // 하드코딩된 Text.rich 대신 헬퍼 함수 호출
              child: _buildFollowedByText(),
            ),
            
          const SizedBox(height: 16.0),

          // --- 8. (핵심) 현재 유저 여부에 따라 버튼 분기 ---
          _isCurrentUser
              ? _buildEditProfileButtons() // '내 프로필' 버튼
              : _buildFollowMessageButtons(), // '다른 유저' 버튼
        ],
      ),
    );
  }

  // (기존) 스탯 컬럼 (변경 없음)
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(count,
            style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.black, fontSize: 14.0)),
      ],
    );
  }

  Widget _buildFollowedByText() {
    // 1. TextSpan 리스트를 만듭니다.
    List<TextSpan> textSpans = [
      TextSpan(text: 'Followed by '),
    ];

    // 스크린샷은 3명까지 이름을 보여줍니다.
    // TODO: 1명, 2명, 4명 이상일 때의 로직을 추가해야 함
    // (임시) 스크린샷과 동일한 3명 케이스만 우선 처리
    if (_mutualFollowers.length == 3) {
      // 1. 첫 번째 이름 (junehxuk)
      textSpans.add(TextSpan(
        text: _mutualFollowers[0],
        style: TextStyle(fontWeight: FontWeight.bold),
        // TODO: 탭하면 junehxuk 프로필로 이동하는 recognizer 추가
      ));
      
      // 2. 콤마
      textSpans.add(TextSpan(text: ', '));
      
      // 3. 두 번째 이름 (katarinabluu)
      textSpans.add(TextSpan(
        text: _mutualFollowers[1],
        style: TextStyle(fontWeight: FontWeight.bold),
        // TODO: 탭하면 katarinabluu 프로필로 이동
      ));
      
      // 4. 'and'
      textSpans.add(TextSpan(text: ' and '));
      
      // 5. 세 번째 이름 (aespa_official)
      textSpans.add(TextSpan(
        text: _mutualFollowers[2],
        style: TextStyle(fontWeight: FontWeight.bold),
        // TODO: 탭하면 aespa_official 프로필로 이동
      ));
    } 
    // 3명 외의 경우 (1명, 2명, 4명 이상...)
    else if (_mutualFollowers.isNotEmpty) {
      // 우선 첫 번째 사람 이름만 표시
      textSpans.add(TextSpan(
          text: _mutualFollowers[0],
          style: TextStyle(fontWeight: FontWeight.bold)));
      if (_mutualFollowers.length > 1) {
        textSpans.add(TextSpan(text: ' and others'));
      }
    }

    // 2. 완성된 TextSpan 리스트로 Text.rich 위젯을 반환
    return Text.rich(
      TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 13.0),
        children: textSpans,
      ),
    );
  }

  // --- 9. (수정) 'Edit Profile' 버튼 로직 ---
  // (기존 _buildProfileHeader에서 분리)
  Widget _buildEditProfileButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
            onPressed: _navigateToEditProfile,
            child: Text('Edit profile'),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
            onPressed: () { /* TODO */ },
            child: Text('Share profile'),
          ),
        ),
      ],
    );
  }

  // --- 10. (신규) 'Follow/Message' 버튼 로직 ---
  Widget _buildFollowMessageButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200], // (라이트 모드)
              foregroundColor: Colors.black, // (라이트 모드)
            ),
            onPressed: () { /* TODO: Unfollow 로직 */ },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Following'),
                Icon(Icons.keyboard_arrow_down, size: 20.0),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
            onPressed: () { /* TODO: Message (ChatRoomScreen) */ },
            child: Text('Message'),
          ),
        ),
        const SizedBox(width: 8.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            minimumSize: Size(36, 36),
          ),
          onPressed: () { /* TODO */ },
          child: Icon(Icons.person_add_outlined),
        ),
      ],
    );
  }

  // --- (신규) 'Create' 바텀 시트를 띄우는 함수 ---
  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // (라이트 모드)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 모달 상단 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(height: 16.0),
              
              // 'Create' 타이틀
              Text(
                'Create',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              Divider(color: Colors.grey[300], height: 24),
              
              // 1. Reel
              ListTile(
                leading: Icon(Icons.movie_filter_outlined, color: Colors.black),
                title: Text('Reel', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  // TODO: 릴스 만들기 화면으로 이동
                  print('Navigate to Create Reel');
                },
              ),
              
              // 2. Post
              ListTile(
                leading: Icon(Icons.grid_on_outlined, color: Colors.black),
                title: Text('Post', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  _navigateAndAddPost(); // 'Post'를 탭하면 기존 함수 호출
                },
              ),
              
              // 3. Share only to profile
              ListTile(
                leading: Icon(Icons.person_pin_outlined, color: Colors.black),
                title: Text('Share only to profile',
                    style: TextStyle(color: Colors.black)),
                trailing: Chip( // 'New' 칩
                  label: Text('New', style: TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
                ),
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  // TODO: 'Share only' 기능 구현
                  print('Navigate to Share only to profile');
                },
              ),
              const SizedBox(height: 16.0), // 하단 여백
            ],
          ),
        );
      },
    );
  }
}

// (기존) Sliver 탭 바 델리게이트 (변경 없음)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}