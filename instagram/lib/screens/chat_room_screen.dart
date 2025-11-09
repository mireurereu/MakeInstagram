// lib/screens/chat_room_screen.dart

import 'package:flutter/material.dart';

// 메시지 데이터 모델 (간단화)
class Message {
  final String text;
  final bool isSender; // true면 나, false면 상대방

  Message({required this.text, required this.isSender});
}

class ChatRoomScreen extends StatefulWidget {
  final String username; // 이전 화면에서 받아올 유저 이름

  const ChatRoomScreen({super.key, required this.username});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  // 영상의 채팅 내역 (테스트 데이터)
  final List<Message> _messages = [
    Message(text: "Layout", isSender: true), // (1:03)
    Message(text: "Hi", isSender: true),     // (1:04)
    Message(text: "Hi!!!!!", isSender: false), // (1:07)
    Message(text: "Hi", isSender: true),     // (1:08)
    // (1:12 ~ 1:30) 스티커 전송 부분은 위젯으로 대체
    Message(text: "[Sticker]", isSender: true), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // (1:03) 채팅방 상단 바
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://picsum.photos/seed/junhyuk/100/100'),
            ),
            const SizedBox(width: 10.0),
            Text(
              widget.username, // '최준혁'
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: Colors.white, size: 28.0),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white, size: 28.0),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 목록
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // 하단 텍스트 입력창
          _buildTextInputArea(),
        ],
      ),
    );
  }

  // (1:03 ~ 1:30) 메시지 버블 위젯
  Widget _buildMessageBubble(Message message) {
    // 내가 보낸 메시지인지(오른쪽 정렬, 파란색)
    bool isSender = message.isSender; 
    
    return Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSender ? Colors.deepPurple : Colors.grey[900], // (영상 1:03)
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ),
    );
  }

  // (1:04) 하단 텍스트 입력창 위젯
  Widget _buildTextInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          // (1:04) 카메라 아이콘
          CircleAvatar(
            radius: 18.0,
            backgroundColor: Colors.blue,
            child: Icon(Icons.camera_alt, color: Colors.white, size: 20.0),
          ),
          const SizedBox(width: 10.0),
          // 텍스트 필드
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          // (1:04) 우측 아이콘들
          Icon(Icons.mic_none, color: Colors.grey, size: 28.0),
          const SizedBox(width: 8.0),
          Icon(Icons.image_outlined, color: Colors.grey, size: 28.0),
          const SizedBox(width: 8.0),
          Icon(Icons.sticky_note_2_outlined, color: Colors.grey, size: 28.0),
        ],
      ),
    );
  }
}