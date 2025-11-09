// lib/screens/dm_list_screen.dart

import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/chat_room_screen.dart'; // 곧 생성할 파일

class DmListScreen extends StatelessWidget {
  const DmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // (영상 0:37) 상단 유저 이름
        title: Row(
          children: [
            Text(
              'ta_junhyuk', // 영상의 유저 이름
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 30.0),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // (영상 0:38) 검색창
          _buildSearchBar(),

          // (영상 0:38) 메시지 / 요청
          _buildMessageRequestsRow(),

          // (영상 0:38 ~ 1:02) 대화 목록
          Expanded(
            child: ListView(
              children: [
                // 영상에 나오는 테스트 데이터
                _buildChatItem(
                  context: context,
                  username: '최준혁',
                  status: 'Sent 3m ago',
                  avatarUrl: 'https://picsum.photos/seed/junhyuk/100/100',
                ),
                _buildChatItem(
                  context: context,
                  username: '신해빈',
                  status: 'Seen',
                  avatarUrl: 'https://picsum.photos/seed/haebin/100/100',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 검색창 위젯
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[900], // 어두운 회색 배경
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 'Messages'와 'Requests' 텍스트가 있는 행
  Widget _buildMessageRequestsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Messages',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Text(
            'Requests (1)', // (영상 0:38)
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  // 개별 채팅 목록 아이템
  Widget _buildChatItem({
    required BuildContext context,
    required String username,
    required String status,
    required String avatarUrl,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Text(
        username,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        status,
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Icon(Icons.camera_alt_outlined, color: Colors.grey),
      onTap: () {
        // 채팅방으로 이동!
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(username: username),
          ),
        );
      },
    );
  }
}