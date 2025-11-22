import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/data/user_state.dart'; // 데이터 파일 임포트

class FollowingListScreen extends StatefulWidget {
  final String username; // [추가] 누구의 팔로잉 목록인지

  const FollowingListScreen({super.key, this.username = 'ta_junhyuk'});

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, String>> _followingList; // 동적 리스트

  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    
    // [핵심] UserState에서 해당 유저의 팔로잉 목록 가져오기
    _followingList = UserState.getFollowingList(widget.username);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.username, // 상단 타이틀: 유저 이름
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 1.0,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            const Tab(text: '0 followers'),
            Tab(text: '${_followingList.length} following'),
            const Tab(text: '0 subscriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text('Followers list')),
          _buildFollowingList(), // 팔로잉 탭
          const Center(child: Text('Subscriptions list')),
        ],
      ),
    );
  }

  Widget _buildFollowingList() {
    return Column(
      children: [
        // 검색창
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              fillColor: const Color(0xFFEFEFEF),
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // 정렬 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Sorted by Default', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Icon(Icons.swap_vert, color: Colors.black),
            ],
          ),
        ),
        
        const Divider(height: 1, color: Color(0xFFE0E0E0)),

        // 유저 리스트
        Expanded(
          child: ListView.builder(
            itemCount: _followingList.length,
            itemBuilder: (context, index) {
              final user = _followingList[index];
              return _buildUserTile(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(Map<String, String> user) {
    final username = user['username']!;
    final isFollowing = UserState.amIFollowing(username);
    final bool isMe = username == UserState.myId;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage('https://picsum.photos/seed/${user['img']}/100/100'),
      ),
      title: Text(
        username, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        user['name']!, 
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      // 팔로우/팔로잉 버튼
      trailing: isMe 
        ? null 
        : SizedBox(
            width: 100,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? const Color(0xFFEFEFEF) : _instaBlue,
                foregroundColor: isFollowing ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
              onPressed: () {
                setState(() {
                  UserState.toggleFollow(username);
                });
              }, 
              child: Text(
                isFollowing ? 'Following' : 'Follow', 
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
              ),
            ),
          ),
      onTap: () {
        // [핵심] 프로필 화면으로 이동
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ProfileScreen(username: username)
          )
        ).then((_) => setState((){})); // 돌아왔을 때 상태 갱신
      },
    );
  }
}