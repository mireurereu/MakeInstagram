import 'package:flutter/material.dart';
import 'package:instagram/screens/chat_room_screen.dart'; // 채팅방 화면 import 필요

class DmListScreen extends StatelessWidget {
  const DmListScreen({super.key});

  // [수정] 인스타 블루 색상 정의
  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Row(
          children: const [
            Text(
              'ta_junhyuk', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            // [수정] 아이콘 변경 (종이 위 펜)
            icon: const Icon(Icons.edit_square, size: 28.0),
            onPressed: () {},
          ),
        ],
      ),
      
      // [수정] 하단 카메라 FAB 추가 (영상 01:00)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 카메라 기능 (구현 생략)
        },
        backgroundColor: _instaBlue,
        elevation: 4,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      
      body: ListView(
        children: [
          // 1. 검색창
          _buildSearchBar(),
          
          // 2. 'Your note' 섹션 (가로 스크롤)
          SizedBox(
            height: 110, // 높이 제한
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16.0, top: 12.0),
              children: [
                _buildYourNote(),
                // 다른 유저들의 노트가 있다면 여기에 추가
              ],
            ),
          ),

          // 3. 메시지 헤더
          _buildMessageRequestsRow(),

          // 4. 대화 목록
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

          // 5. 친구 찾기 섹션
          _buildFindFriendsSection(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFEFEFEF), // 조금 더 밝은 회색
          // [수정] 높이 조절
          isDense: true,
          contentPadding: const EdgeInsets.all(10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildYourNote() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0), // 아이템 간격
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 36, // 크기 키움
                backgroundImage: NetworkImage('https://picsum.photos/seed/junhyuk/100/100'),
              ),
              // 말풍선
              Positioned(
                top: -10,
                left: 10,
                right: 10,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey[300]!, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "What's on your playlist",
                    style: TextStyle(color: Colors.grey[600], fontSize: 11.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // 플러스 버튼
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_circle, color: Colors.grey, size: 24),
                ),
              )
            ],
          ),
          const SizedBox(height: 4.0),
          const Text(
            'Your note',
            style: TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRequestsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Messages',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Text(
            'Requests',
            style: TextStyle(
              color: Color(0xFF3797EF), // 인스타 블루
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required BuildContext context,
    required String username,
    required String status,
    required String avatarUrl,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Text(
        username,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        status,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 28),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(username: username),
          ),
        );
      },
    );
  }

  Widget _buildFindFriendsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find friends to follow and message',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          
          // 1. Connect contacts
          _buildFriendTile(
            icon: Icons.contact_page_outlined,
            title: 'Connect contacts',
            subtitle: 'Follow people you know.',
            buttonText: 'Connect',
            onPressed: () {},
          ),
          
          const SizedBox(height: 12.0),
          
          // 2. Search for friends
          _buildFriendTile(
            icon: Icons.search,
            title: 'Search for friends',
            subtitle: "Find your friends' accounts.",
            buttonText: 'Search',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // [수정] 친구 찾기 타일 (버튼 모양 수정)
  Widget _buildFriendTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFEFEFEF),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13.0)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _instaBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              // [수정] 둥근 사각형 모양
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              minimumSize: const Size(0, 32), // 높이 줄임
            ),
            child: Text(buttonText, style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12.0),
          const Icon(Icons.close, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}