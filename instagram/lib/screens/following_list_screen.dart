import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screen.dart'; // 다른 유저 프로필로 이동 시 필요

class FollowingListScreen extends StatefulWidget {
  const FollowingListScreen({super.key});

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 이전에 공유해주신 Mock 데이터 (영상 04:49 ~ 05:15)
  final List<Map<String, String>> followingList = const [
    {
      'username': 'yonghyeon5670',
      'name': '권용현',
      'avatarSeed': 'yonghyeon'
    },
    {'username': 'junehxuk', 'name': '최준혁', 'avatarSeed': 'junehxuk'},
    {'username': 'cch991112', 'name': '조찬희', 'avatarSeed': 'cch99'},
    {'username': 'haetbaaan', 'name': '신해빈', 'avatarSeed': 'haetbaaan'},
    {
      'username': 'cau_ai_',
      'name': '중앙대학교 AI학과 학생회',
      'avatarSeed': 'cauai'
    },
    {'username': 'imwinter', 'name': 'WINTER', 'avatarSeed': 'winter'},
    {'username': 'katarinabluu', 'name': 'KARINA', 'avatarSeed': 'karina'},
    {
      'username': 'chunganguniv',
      'name': 'Chung-Ang University',
      'avatarSeed': 'cauf'
    },
    {'username': 'aespa_official', 'name': 'aespa 에스파', 'avatarSeed': 'aespa'},
    // (스크린샷에 보이는 9명이 되도록 1명 제외)
  ];

  @override
  void initState() {
    super.initState();
    // 3개 탭, 'following' 탭(index: 1)이 기본으로 선택
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
      // (라이트 모드)
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // 아이콘/텍스트 색상
        elevation: 0.5,
        title: Text('ta_junhyuk', style: TextStyle(fontWeight: FontWeight.bold)),
        // (스크린샷 04:49) 탭 바
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: '3 followers'),
            Tab(text: '9 following'),
            Tab(text: '0 subscriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Followers 탭 (플레이스홀더)
          Center(child: Text('Followers list goes here')),

          // 2. Following 탭 (핵심 구현)
          _buildFollowingList(),

          // 3. Subscriptions 탭 (플레이스홀더)
          Center(child: Text('Subscriptions list goes here')),
        ],
      ),
    );
  }

  // 'Following' 탭의 전체 리스트
  Widget _buildFollowingList() {
    // ListView.builder 대신 Column + ListView.separated 사용
    // (상단의 고정된 위젯들 + 하단의 스크롤 리스트)
    return Column(
      children: [
        _buildSearchBar(),
        _buildSyncContacts(),
        _buildSortRow(),
        Divider(height: 1, color: Colors.grey[300]),
        // 남은 공간을 꽉 채우는 스크롤 리스트
        Expanded(
          child: ListView.separated(
            itemCount: followingList.length,
            itemBuilder: (context, index) {
              final user = followingList[index];
              return _buildUserTile(
                username: user['username']!,
                name: user['name']!,
                avatarSeed: user['avatarSeed']!,
              );
            },
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey[200], indent: 80),
          ),
        ),
      ],
    );
  }

  // (스크린샷) 검색창
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[200], // (라이트 모드)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // (스크린샷) 'Sync contacts'
  Widget _buildSyncContacts() {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        child: Icon(Icons.contact_page_outlined, color: Colors.black),
      ),
      title: Text('Sync contacts', style: TextStyle(color: Colors.black)),
      subtitle: Text('Find people you know', style: TextStyle(color: Colors.grey)),
      trailing: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: Text('Sync'),
      ),
      // TODO: 'X' 버튼 추가
    );
  }

  // (스크린샷) 'Sorted by Default'
  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sorted by Default',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Icon(Icons.swap_vert, color: Colors.black),
        ],
      ),
    );
  }

  // (스크린샷) 개별 유저 타일
  Widget _buildUserTile({
    required String username,
    required String name,
    required String avatarSeed,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage:
            NetworkImage('https://picsum.photos/seed/$avatarSeed/100/100'),
      ),
      title: Text(
        username,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        name,
        style: TextStyle(color: Colors.grey),
      ),
      // (스크린샷) 'Message' 버튼과 3점 메뉴
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200], // (라이트 모드)
              foregroundColor: Colors.black, // (라이트 모드)
            ),
            onPressed: () {
              // TODO: Unfollow 로직
            },
            child: Text('Message'),
          ),
          const SizedBox(width: 4.0),
          Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
      onTap: () {
        // 다른 유저의 프로필 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(username: username),
          ),
        );
      },
    );
  }
}