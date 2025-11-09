import 'package:flutter/material.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart';

// 1. StatelessWidget -> StatefulWidget으로 변경
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 2. Name과 Bio를 '상태(State)'로 관리
  String _name = 'puang';
  String _bio = 'I\'m gonna be the God of Flutter!';
  // (임시) 프로필 아바타 URL
  String _avatarUrl = 'https://picsum.photos/seed/profile/200/200';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // TODO: 이곳에서 Firebase로부터 _name, _bio, _avatarUrl을 불러와야 합니다.
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 3. 'Edit Profile' 버튼을 눌렀을 때 호출되는 함수 (핵심!)
  void _navigateToEditProfile() async {
    // EditProfileScreen으로 이동하고, 결과가 올 때까지 'await'(대기)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          // 4. 현재 상태값을 EditProfileScreen으로 전달
          initialName: _name,
          initialBio: _bio,
          initialAvatarUrl: _avatarUrl,
        ),
      ),
    );

    // 5. EditProfileScreen에서 'Done'을 눌러 돌아왔고, result가 있다면
    if (result != null && result is Map) {
      // 6. setState를 호출하여 화면을 갱신!
      setState(() {
        _name = result['name'];
        _bio = result['bio'];
        _avatarUrl = result['avatarUrl'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 7. TabController를 위해 DefaultTabController -> Scaffold로 변경
    return Scaffold(
      // (라이트 모드) 전역 테마 사용
      appBar: _buildAppBar(context),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildProfileHeader(context), // 8. _name, _bio 상태 사용
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController, // 7. 컨트롤러 연결
                  tabs: [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.person_pin_outlined)),
                  ],
                  indicatorColor: Colors.black, // (라이트 모드)
                  labelColor: Colors.black, // (라이트 모드)
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController, // 7. 컨트롤러 연결
          children: [
            // 첫 번째 탭: 포스트 그리드
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Image.network(
                  'https://picsum.photos/seed/post${index + 1}/200/200',
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      // (라이트 모드) 전역 테마 사용
      title: Row(
        children: [
          Icon(Icons.lock_outline, size: 20.0),
          const SizedBox(width: 4.0),
          Text(
            'ta_junhyuk',
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

  // (수정) _buildProfileHeader가 _name과 _bio 상태를 사용
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
                backgroundImage: NetworkImage(_avatarUrl), // 8. _avatarUrl 상태 사용
              ),
              _buildStatColumn('3', 'Posts'),
              _buildStatColumn('3', 'Followers'),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FollowingListScreen()),
                  );
                },
                child: _buildStatColumn('9', 'Following'),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(_name, // 8. _name 상태 사용
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(_bio, style: TextStyle(color: Colors.black)), // 8. _bio 상태 사용
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // (라이트 모드)
                    foregroundColor: Colors.black, // (라이트 모드)
                  ),
                  onPressed: _navigateToEditProfile, // (수정) 3. 함수 호출
                  child: Text('Edit profile'),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // (라이트 모드)
                    foregroundColor: Colors.black, // (라이트 모드)
                  ),
                  onPressed: () { /* TODO */ },
                  child: Text('Share profile'),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200], // (라이트 모드)
                  foregroundColor: Colors.black, // (라이트 모드)
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  minimumSize: Size(36, 36),
                ),
                onPressed: () { /* TODO */ },
                child: Icon(Icons.person_add_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
}

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
    return Container(color: Colors.white, child: _tabBar); // (라이트 모드)
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}