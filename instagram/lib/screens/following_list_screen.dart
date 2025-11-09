// lib/screens/following_list_screen.dart

import 'package:flutter/material.dart';

class FollowingListScreen extends StatelessWidget {
  const FollowingListScreen({super.key});

  // 영상 4:49 ~ 5:15에 나온 테스트 유저 데이터
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
    {'username': 'imnotningning', 'name': 'NINGNING', 'avatarSeed': 'ningning'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // (영상 4:49) 상단 앱 바
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'ta_junhyuk', // 내 유저 이름
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // (영상 4:49 ~ 5:15) 팔로잉 목록
      body: ListView.builder(
        itemCount: followingList.length,
        itemBuilder: (context, index) {
          final user = followingList[index];
          return _buildUserTile(
            username: user['username']!,
            name: user['name']!,
            avatarSeed: user['avatarSeed']!,
          );
        },
      ),
    );
  }

  // 각 유저를 표시하는 리스트 타일
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
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        name,
        style: TextStyle(color: Colors.grey),
      ),
      // 'Following' 버튼 (영상 4:49)
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800], // 어두운 버튼
          foregroundColor: Colors.white, // 흰색 글씨
        ),
        onPressed: () {
          // TODO: Unfollow 로직
        },
        child: Text('Following'),
      ),
    );
  }
}