import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screen.dart'; // 프로필 이동용

class FollowingListScreen extends StatefulWidget {
  const FollowingListScreen({super.key});

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 영상 데이터 (04:49 ~ 05:15)
  final List<Map<String, String>> followingList = const [
    {'username': 'yonghyeon5670', 'name': '권용현', 'avatarSeed': 'yonghyeon'},
    {'username': 'junehxuk', 'name': '최준혁', 'avatarSeed': 'junehxuk'},
    {'username': 'cch991112', 'name': '조찬희', 'avatarSeed': 'cch99'},
    {'username': 'haetbaaan', 'name': '신해빈', 'avatarSeed': 'haetbaaan'},
    {'username': 'cau_ai_', 'name': '중앙대학교 AI학과 학생회', 'avatarSeed': 'cauai'},
    {'username': 'imwinter', 'name': 'WINTER', 'avatarSeed': 'winter'},
    {'username': 'katarinabluu', 'name': 'KARINA', 'avatarSeed': 'karina'},
    {'username': 'chunganguniv', 'name': 'Chung-Ang University', 'avatarSeed': 'cauf'},
    {'username': 'aespa_official', 'name': 'aespa 에스파', 'avatarSeed': 'aespa'},
  ];

  // 인스타 블루
  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  void initState() {
    super.initState();
    // 3개 탭 중 'following' (index 1)을 기본 선택
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
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
        title: const Text(
          'ta_junhyuk', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 1.0,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: '3 followers'),
            Tab(text: '9 following'),
            Tab(text: '0 subscriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text('Followers list')),
          
          // [핵심] Following 탭 리스트 구현
          _buildFollowingList(),
          
          const Center(child: Text('Subscriptions list')),
        ],
      ),
    );
  }

  Widget _buildFollowingList() {
    return Column(
      children: [
        // 1. 검색창
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              fillColor: const Color(0xFFEFEFEF), // 연한 회색 배경
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.zero, // 높이 슬림하게
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // 2. 주소록 동기화 (Sync contacts)
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5), // 테두리 아이콘 느낌
              ),
              child: const Center(
                child: Icon(Icons.person_add_alt_1, color: Colors.black, size: 24),
              ),
            ),
          ),
          title: const Text('Sync contacts', style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: const Text('Find people you know', style: TextStyle(color: Colors.grey, fontSize: 13)),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _instaBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(70, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () {}, 
            child: const Text('Sync', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),

        // 3. 정렬 헤더
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
        
        // 구분선
        const Divider(height: 1, color: Color(0xFFE0E0E0)),

        // 4. 유저 리스트
        Expanded(
          child: ListView.builder(
            itemCount: followingList.length,
            itemBuilder: (context, index) {
              final user = followingList[index];
              return _buildUserTile(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(Map<String, String> user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage('https://picsum.photos/seed/${user['avatarSeed']}/100/100'),
      ),
      title: Text(
        user['username']!, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        user['name']!, 
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message 버튼 (회색)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEFEFEF), 
              foregroundColor: Colors.black, 
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              minimumSize: const Size(0, 32),
            ),
            onPressed: () {
              // 채팅방 이동 로직 등
            }, 
            child: const Text('Message', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            constraints: const BoxConstraints(), // 아이콘 버튼 패딩 제거
            onPressed: () {},
          ),
        ],
      ),
      onTap: () {
        // 해당 유저의 프로필로 이동
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ProfileScreen(username: user['username'])
          )
        );
      },
    );
  }
}