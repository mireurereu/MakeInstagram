import 'package:flutter/material.dart';
import 'package:instagram/screens/chat_room_screen.dart';

class DmListScreen extends StatelessWidget {
  const DmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // (라이트 모드) 전역 테마(Colors.white) 사용
      appBar: AppBar(
        // (라이트 모드) 전역 테마 사용
        title: Row(
          children: [
            Text(
              'ta_junhyuk', // 스크린샷의 유저 이름
              // 전역 테마의 titleTextStyle을 따름
            ),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            // (수정) 스크린샷의 '새 메시지' 아이콘
            icon: Icon(Icons.edit_note_outlined, size: 30.0),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView( // 스크롤이 필요하므로 Column 대신 ListView
        children: [
          // (동일) 검색창
          _buildSearchBar(),
          
          // (신규) 'Your note' 섹션
          _buildYourNote(),

          // (동일) 메시지 / 요청
          _buildMessageRequestsRow(),

          // (동일) 대화 목록
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

          // (신규) 'Find friends' 섹션
          _buildFindFriendsSection(),
        ],
      ),
    );
  }

  // (수정) 라이트 모드 검색창 위젯
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
        ),
      ),
    );
  }

  // (신규) 'Your note' 위젯
  Widget _buildYourNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Stack(
        clipBehavior: Clip.none, // 스택 바깥으로 나가는 버블 허용
        children: [
          // 프로필 아바타
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage('https://picsum.photos/seed/my_note/100/100'),
          ),
          // 'What's on...' 말풍선
          Positioned(
            top: -10,
            left: 45,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[300]!, width: 1.0),
              ),
              child: Text(
                'What\'s on your playlist?',
                style: TextStyle(color: Colors.grey[700], fontSize: 12.0),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 25,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_circle, color: Colors.blue, size: 20),
            ),
          )
        ],
      ),
    );
  }

  // (동일) 'Messages'와 'Requests' 텍스트가 있는 행
  Widget _buildMessageRequestsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Messages',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Text(
            'Requests (1)',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  // (수정) 라이트 모드 개별 채팅 목록 아이템
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
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        status,
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Icon(Icons.camera_alt_outlined, color: Colors.grey),
      onTap: () {
        // 채팅방으로 이동 (LLM 채팅방)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(username: username),
          ),
        );
      },
    );
  }

  // (신규) 'Find friends' 섹션
  Widget _buildFindFriendsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find friends to follow and message',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          // 1. Connect contacts
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.contact_page_outlined, color: Colors.black),
            ),
            title: Text('Connect contacts',
                style: TextStyle(color: Colors.black)),
            subtitle: Text('Follow people you know.',
                style: TextStyle(color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: Text('Connect'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                Icon(Icons.close, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          // 2. Search for friends
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.search, color: Colors.black),
            ),
            title: Text('Search for friends',
                style: TextStyle(color: Colors.black)),
            subtitle: Text('Find your friends\' accounts.',
                style: TextStyle(color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: Text('Search'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                Icon(Icons.close, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}