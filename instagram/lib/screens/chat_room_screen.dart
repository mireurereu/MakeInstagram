import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // [필수] 애니메이션 타이머용
import 'package:intl/intl.dart';
import 'package:instagram/constants.dart';

// --- 모델 클래스 ---
class Message {
  final String text;
  final bool isSender;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isSender,
    required this.timestamp,
  });
}

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
  bool _hasText = false;

  final List<Message> _messages = [];
  final List<ApiMessage> _messageHistory = [];
  
  final String opponentAvatarUrl = 'https://picsum.photos/seed/junhyuk/100/100';
  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  void initState() {
    super.initState();
    _messageHistory.add(ApiMessage(
      role: 'system',
      content: 'You are a helpful and friendly assistant.'
    ));
    
    final now = DateTime.now();
    _messages.addAll([
      Message(text: 'Layout', isSender: true, timestamp: now.subtract(const Duration(hours: 2))),
      Message(text: 'Hi', isSender: true, timestamp: now.subtract(const Duration(hours: 1))),
      Message(text: "I'm ai assistan.... Can not reply...", isSender: false, timestamp: now.subtract(const Duration(minutes: 30))),
      Message(text: "Hi!!!!!", isSender: false, timestamp: now.subtract(const Duration(minutes: 29))),
    ]);

    _textController.addListener(() {
      setState(() {
        _hasText = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _textController.text;
    if (text.isEmpty) return;

    _textController.clear();
    setState(() => _hasText = false);

    final DateTime messageTime = DateTime.now();

    setState(() {
      _messages.add(Message(text: text, isSender: true, timestamp: messageTime));
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
        final String responseText = responseBody['choices'][0]['message']['content'];

        if (!mounted) return;
        setState(() {
          _messages.add(Message(text: responseText, isSender: false, timestamp: DateTime.now()));
        });
        _messageHistory.add(ApiMessage(role: 'assistant', content: responseText));
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }
  
  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;
    final DateTime current = _messages[index].timestamp;
    final DateTime previous = _messages[index - 1].timestamp;
    if (current.difference(previous).inHours >= 1) return true;
    return false;
  }
  
  Widget _buildTimestampMarker(DateTime timestamp) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          DateFormat('MMM d, h:mm a').format(timestamp),
          style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
        ),
      ),
    );
  }

  // [수정] 실제 애니메이션 위젯 사용
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(22.0),
            ),
            // 여기에 애니메이션 위젯 배치
            child: const _TypingAnimationWidget(), 
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
        elevation: 0,
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(opponentAvatarUrl),
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                Text(
                  'Active now',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined, size: 28.0), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_outlined, size: 28.0), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                
                final message = _messages[index];
                final bool showTimestamp = _shouldShowTimestamp(index);

                return Column(
                  children: [
                    if (showTimestamp) _buildTimestampMarker(message.timestamp),
                    _buildMessageBubble(message, index),
                  ],
                );
              },
            ),
          ),
          _buildTextInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, int index) {
    final bool isSender = message.isSender;
    return Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSender ? _instaBlue : const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(22.0),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isSender ? Colors.white : Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: _instaBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20.0),
          ),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  if (!_hasText) ...[
                    const Icon(Icons.mic_none, color: Colors.black, size: 24.0),
                    const SizedBox(width: 12.0),
                    const Icon(Icons.image_outlined, color: Colors.black, size: 24.0),
                    const SizedBox(width: 12.0),
                    const Icon(Icons.sticky_note_2_outlined, color: Colors.black, size: 24.0),
                  ],
                ],
              ),
            ),
          ),
          if (_hasText)
             TextButton(
               onPressed: _isLoading ? null : _sendMessage,
               child: Text('Send', style: TextStyle(color: _instaBlue, fontSize: 16.0, fontWeight: FontWeight.bold)),
             ),
        ],
      ),
    );
  }
}

// [신규] 점 3개가 깜빡이는 애니메이션 위젯
class _TypingAnimationWidget extends StatefulWidget {
  const _TypingAnimationWidget();

  @override
  State<_TypingAnimationWidget> createState() => _TypingAnimationWidgetState();
}

class _TypingAnimationWidgetState extends State<_TypingAnimationWidget> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 300ms마다 점의 불투명도를 변경하여 움직이는 듯한 효과
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % 4; // 0, 1, 2, 3 (3은 쉬는 타임)
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 7, // 점 크기
          height: 7,
          decoration: BoxDecoration(
            // 순서대로 진한 회색이 되었다가 연해짐
            color: index == _currentIndex % 3 
                ? Colors.grey[600] 
                : Colors.grey[400], 
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}