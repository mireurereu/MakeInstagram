import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/screens/create_post_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/search_screen.dart'; 
import 'package:instagram/screens/reels_screen.dart';
import 'package:instagram/data/user_state.dart';

// Global key so other screens can programmatically change tabs (e.g. after posting)
final GlobalKey<_MainNavigationScreenState> mainNavKey = GlobalKey<_MainNavigationScreenState>();

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // 탭별 화면 리스트
  static final List<Widget> _screens = [
    const FeedScreen(), // 0: 홈
    const SearchScreen(), // 1: 검색 (파일 없으면 Text('Search')로 대체)
    const SizedBox(), // 2: 게시물 작성 (Push로 이동하므로 비워둠)
    const ReelsScreen(), // 3: 릴스 (파일 없으면 Text('Reels')로 대체)
    const ProfileScreen(), // 4: 프로필
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // [수정] 2번(+) 탭 누르면 게시물 작성 화면으로 Push (탭 이동 X)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreatePostScreen(),
          fullscreenDialog: true, // 모달 느낌
        ),
      );
    } else {
      // 다른 탭은 정상적으로 이동
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Allow external callers to change the active tab programmatically.
  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // [수정] IndexedStack으로 상태 유지 (탭 이동해도 스크롤 위치 등 기억)
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      
      // 하단 탭바
      bottomNavigationBar: Container(
        // [수정] 상단 얇은 회색 구분선 추가
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFDBDBDB), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white, // 배경 흰색
          type: BottomNavigationBarType.fixed, // 아이콘 간격 고정
          showSelectedLabels: false, // 라벨 숨김
          showUnselectedLabels: false,
          selectedItemColor: Colors.black, // [수정] 선택됨: 검은색
          unselectedItemColor: Colors.black, // [수정] 비선택: 검은색 (투명도 없음)
          elevation: 0, // 자체 그림자 제거 (Container 보더로 대체)
          
          items: [
            // 1. Home (Filled vs Outlined)
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined, size: 28),
              label: 'Home',
            ),
            // 2. Search (굵기 차이 or 동일)
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1 ? Icons.search : Icons.search, size: 28), 
              // 선택 시 약간 굵은 느낌을 주고 싶다면 shadows 추가 등의 트릭 사용 가능
              label: 'Search',
            ),
            // 3. Add (네모 플러스)
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined, size: 28),
              label: 'Add',
            ),
            // 4. Reels (Filled vs Outlined)
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 3 ? Icons.movie : Icons.movie_outlined, size: 28),
              label: 'Reels',
            ),
            // 5. Profile (내 프로필 사진)
            BottomNavigationBarItem(
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300], // 이미지 로딩 전 배경
                  // [수정] 선택되었을 때만 검은색 테두리 표시
                  border: _selectedIndex == 4
                      ? Border.all(color: Colors.black, width: 1.5)
                      : null,
                  image: DecorationImage(
                    image: _getImageProvider(UserState.getMyAvatarUrl()),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}