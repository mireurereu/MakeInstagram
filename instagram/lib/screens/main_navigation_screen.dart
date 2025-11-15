// lib/screens/main_navigation_screen.dart

import 'package:flutter/material.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/screens/create_post_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/emoji_test_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 현재 선택된 탭 인덱스
  int _selectedIndex = 0;

  // 각 탭에 보여줄 화면 위젯 목록
  static final List<Widget> _widgetOptions = <Widget>[
    FeedScreen(),
    Text('Search Screen', style: TextStyle(color: Colors.black)), // 1. 텍스트 검은색
    Container(),
    Text('Reels Screen', style: TextStyle(color: Colors.black)), // 2. 텍스트 검은색
    ProfileScreen(),
  ];
  // 탭이 선택되었을 때 호출될 함수
  void _onItemTapped(int index) {
    if (index == 2) {
      // 2번 '+' 탭을 누르면...
      // setState를 하지 않고, 새로운 화면을 띄웁니다.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatePostScreen()),
      );
    } else {
      // 다른 탭들은 기존처럼 탭 이동
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 탭에 해당하는 화면을 보여줌
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter_outlined), // 릴스 아이콘
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // 프로필 아이콘
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // 현재 활성화된 탭
        selectedItemColor: Colors.white, // 선택된 아이콘 색상
        unselectedItemColor: Colors.grey, // 비선택 아이콘 색상
        onTap: _onItemTapped, // 탭 선택 시 호출
        backgroundColor: Colors.white, // 배경색
        type: BottomNavigationBarType.fixed, // 탭이 고정되도록 설정
        showSelectedLabels: false, // 선택된 라벨 숨기기
        showUnselectedLabels: false, // 비선택 라벨 숨기기
        elevation: 0.5,
      ),
    );
  }
}