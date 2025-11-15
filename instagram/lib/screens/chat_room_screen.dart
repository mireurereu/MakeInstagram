import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:instagram/constants.dart';
import 'package:intl/intl.dart'; // 1. (신규) 날짜/시간 포맷용

// 2. (수정) Message 모델에 'timestamp' 추가
class Message {
  final String text;
  final bool isSender;
  final DateTime timestamp; // 메시지 전송 시간

  Message({
    required this.text,
    required this.isSender,
    required this.timestamp,
  });
}

// (ApiMessage 클래스는 기존과 동일)
class ApiMessage {
  final String role;
  final String content;

  ApiMessage({required this.role, required this.content});
  
  Map<String, String> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class ChatRoomScreen extends StatefulWidget {
  final String username;
  const ChatRoomScreen({super.key, required this.username});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<Message> _messages = [];
  final List<ApiMessage> _messageHistory = [];
  
  // (임시) 상대방 아바타 URL
  final String opponentAvatarUrl = 'https://picsum.photos/seed/junhyuk/100/100';

  @override
  void initState() {
    super.initState();
    _messageHistory.add(ApiMessage(
      role: 'system',
      content: 'You are a helpful and friendly assistant.'
    ));
    
    // (임시) 스크린샷과 유사한 테스트 데이터
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    
    _messages.addAll([
      Message(text: 'Layout', isSender: true, timestamp: yesterday.subtract(Duration(hours: 1))),
      Message(text: 'Hi', isSender: true, timestamp: yesterday),
      Message(text: "I'm ai assistan.... Can not reply...", isSender: false, timestamp: yesterday.add(Duration(seconds: 10))),
      Message(text: "Hi!!!!!", isSender: false, timestamp: yesterday.add(Duration(seconds: 20))),
    ]);

    // 텍스트 컨트롤러 리스너 추가 (Send 버튼 표시 여부 제어)
    _textController.addListener(() {
      setState(() {
        // 텍스트가 변경될 때마다 UI 갱신
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 3. (수정) 메시지 전송 함수 (timestamp 추가)
  Future<void> _sendMessage() async {
    final String text = _textController.text;
    if (text.isEmpty) return;

    _textController.clear();
    final DateTime messageTime = DateTime.now(); // 현재 시간 기록

    setState(() {
      _messages.add(Message(
        text: text,
        isSender: true,
        timestamp: messageTime, // 3-1. timestamp 추가
      ));
      _isLoading = true;
    });
    _scrollToBottom();
    
    _messageHistory.add(ApiMessage(role: 'user', content: text));

    try {
      final response = await http.post(
        Uri.parse(OPENROUTER_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $OPENROUTER_API_KEY',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'model': 'nvidia/nemotron-nano-12b-v2-vl:free',
          'messages': _messageHistory.map((msg) => msg.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final String responseText =
            responseBody['choices'][0]['message']['content'];

        setState(() {
          _messages.add(Message(
            text: responseText,
            isSender: false,
            timestamp: DateTime.now(), // 3-2. AI 응답에도 timestamp 추가
          ));
        });
        
        _messageHistory.add(ApiMessage(role: 'assistant', content: responseText));
        
      } else {
        final errorBody = jsonDecode(response.body);
        _handleError(
            'API Error ${response.statusCode}: ${errorBody['error']['message']}');
      }
    } catch (e) {
      _handleError('Error: ${e.toString()}');
      print("LLM Error: $e");
    } finally {
      setState(() {
        _isLoading = false; 
      });
      _scrollToBottom();
    }
  }

  void _handleError(String errorMessage) {
    setState(() {
      _messages.add(Message(
        text: errorMessage,
        isSender: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo( // animateTo 대신 jumpTo
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }
  
  // 4. (신규) 타임스탬프 표시 여부 결정
  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true; // 첫 번째 메시지는 무조건 표시
    
    final DateTime current = _messages[index].timestamp;
    final DateTime previous = _messages[index - 1].timestamp;
    
    // 날짜가 다르면 표시 (혹은 1시간 이상 차이나면 표시)
    if (current.day != previous.day ||
        current.month != previous.month ||
        current.year != previous.year) {
      return true;
    }
    
    // 1시간 이상 차이날 때도 표시
    if (current.difference(previous).inHours >= 1) {
      return true;
    }

    return false;
  }
  
  // 5. (신규) 타임스탬프 위젯
  Widget _buildTimestampMarker(DateTime timestamp) {
    String formattedDate;
    final now = DateTime.now();
    
    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      // 오늘
      formattedDate = 'Today ${DateFormat.jm().format(timestamp)}'; // "Today 5:18 PM"
    } else if (timestamp.year == now.year) {
      // 올해 (다른 날짜)
      formattedDate = DateFormat('MMM d, h:mm a').format(timestamp); // "Sep 18, 11:20 AM"
    } else {
      // 다른 연도
      formattedDate = DateFormat('MMM d, y, h:mm a').format(timestamp);
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          formattedDate,
          style: TextStyle(color: Colors.grey, fontSize: 12.0),
        ),
      ),
    );
  }

  // 6. (신규) '...' 응답 대기 위젯
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(opponentAvatarUrl),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18.0),
            ),
            // TODO: 실제 애니메이션 GIF나 위젯으로 교체
            child: Text('...', style: TextStyle(color: Colors.white, letterSpacing: 2.0)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black,
        title: Row( // 1. Row를 다시 추가합니다.
          children: [
            // 2. CircleAvatar (프로필 사진)를 다시 넣습니다.
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(opponentAvatarUrl),
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 첫 번째 줄: 이름 (최준혁)
                Text(
                  widget.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
            // 두 번째 줄: ID (junehxuk >)
                Row(
                  children: [
                    Text(
                      'junehxuk', // (임시) 스크린샷의 ID
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      size: 16.0,
                      color: Colors.grey[700],
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        // --- 👆 ---
        // --- 👇 2. actions 수정 ---
        actions: [
          IconButton(
            icon: Icon(Icons.call_outlined, size: 28.0), // 전화
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam_outlined, size: 28.0), // 영상통화
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 7. (수정) 메시지 목록 (ListView.builder 수정)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              // (수정) 로딩 중일 때 +1
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // (수정) 로딩 인디케이터 표시
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                
                final message = _messages[index];
                final bool showTimestamp = _shouldShowTimestamp(index);

                return Column(
                  children: [
                    // (수정) 타임스탬프 표시
                    if (showTimestamp)
                      _buildTimestampMarker(message.timestamp),
                    // (수정) 인덱스 전달
                    _buildMessageBubble(message, index),
                  ],
                );
              },
            ),
          ),
          
          // (수정) 하단 로딩바 제거
          
          // 8. (수정) 키보드 입력창 (스크린샷 UI 반영)
          _buildTextInputArea(),
        ],
      ),
    );
  }

  // 9. (수정) 메시지 버블 (그라데이션, Seen, React 텍스트 추가)
  Widget _buildMessageBubble(Message message, int index) {
    final bool isSender = message.isSender;
    
    // (수정) 마지막 메시지 & 보낸 사람 & 로딩중 아님
    final bool isLastMessage = index == _messages.length - 1;
    final bool showSeen = isSender && isLastMessage && !_isLoading;
    final bool showReactHint = !isSender && isLastMessage;

    return Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 메시지 버블
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              // (수정) 그라데이션 제거, 단색 보라색
              color: isSender ? Colors.deepPurple : Colors.grey[200], // 1. (수정)
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Text(
              message.text,
              // (수정) 상대방 텍스트 검은색
              style: TextStyle(
                color: isSender ? Colors.white : Colors.black, // 2. (수정)
                fontSize: 16.0,
              ),
            ),
          ),
          
          // (수정) 하단 추가 텍스트
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // (수정) "Tap and hold to react"
                if (showReactHint) // 마지막 AI 응답에만 표시
                  Text(
                    'Tap and hold to react',
                    style: TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
                // (수정) "Seen just now"
                if (showSeen) // 내 마지막 메시지에만 표시
                  Text(
                    'Seen just now',
                    style: TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 10. (수정) 하단 텍스트 입력창 (스크린샷 UI 반영)
  // 10. (수정) 하단 텍스트 입력창 (최종 UI 반영)
  Widget _buildTextInputArea() {
    // 👇 [해결] 이 라인이 누락되었을 수 있습니다.
    final bool hasText = _textController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // 라이트 모드 배경
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          // 보라색 카메라 아이콘
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt, color: Colors.white, size: 20.0),
          ),
          const SizedBox(width: 10.0),
          
          Expanded(
            child: TextField(
              controller: _textController,
              style: TextStyle(color: Colors.black), // 글자 색 검은색
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (text) => _sendMessage(),
            ),
          ),
          
          if (hasText)
            // 텍스트가 있으면 '전송' 버튼
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white, size: 20.0),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            )
          else
            // 텍스트가 없으면 '아이콘 3개'
            Row(
              children: [
                Icon(Icons.mic_none, color: Colors.black, size: 28.0),
                const SizedBox(width: 8.0),
                Icon(Icons.image_outlined, color: Colors.black, size: 28.0),
                const SizedBox(width: 8.0),
                Icon(Icons.add_circle_outline, color: Colors.black, size: 28.0),
              ],
            ),
        ],
      ),
    );
  }
}