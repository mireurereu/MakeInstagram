import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:instagram/constants.dart';

class Message {
  String text;
  bool isSender;
  DateTime timestamp;
  bool seen;
  String? footer;
  String? imageAsset;

  Message({
    required this.text,
    required this.isSender,
    required this.timestamp,
    this.seen = false,
    this.footer,
    this.imageAsset,
  });
}

class ApiMessage {
  final String role;
  final String content;

  ApiMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};
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
  final List<Timer> _activeTimers = [];
  final List<ApiMessage> _messageHistory = [];
  Timer? _fallbackTimer;

  final String opponentAvatarUrl = 'https://picsum.photos/seed/junhyuk/100/100';
  final Color _instaBlue = const Color(0xFF3797EF);
  final Color _senderPurple = const Color(0xFF7C3AED);
  // assets list for picker
  final List<String> _assetImages = [
    'assets/images/post1.jpg',
    'assets/images/post2.jpg',
    'assets/images/post3.jpg',
    'assets/images/post4.jpg',
  ];
  String? _selectedImage;
  // (single image selection for DM)
  bool _isImageSheetOpen = false;
  // ensure typing/loading is shown for at least this duration
  final Duration _minTypingDuration = const Duration(milliseconds: 1500);
  DateTime? _loadingStartTime;

  @override
  void initState() {
    super.initState();
    _messageHistory.add(ApiMessage(role: 'system', content: 'You are a helpful assistant.'));

    final now = DateTime.now();
    _messages.addAll([
      Message(text: 'Hi!', isSender: true, timestamp: now.subtract(const Duration(hours: 2))),
      Message(text: 'Nice to meet you!', isSender: true, timestamp: now.subtract(const Duration(hours: 2))),
    ]);

    _textController.addListener(() => setState(() => _hasText = _textController.text.isNotEmpty));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    for (final t in _activeTimers) t.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _textController.text;
    if (text.isEmpty && _selectedImage == null) return;

    // If the image picker sheet is currently open, close it first so the UI flows
    if (_isImageSheetOpen) {
      Navigator.of(context).pop();
      // small delay to let the sheet visually close
      await Future.delayed(const Duration(milliseconds: 200));
      _isImageSheetOpen = false;
    }

    _textController.clear();
    setState(() => _hasText = false);

    final DateTime messageTime = DateTime.now();
    final int sentIndex = _messages.length;

    setState(() {
      _messages.add(Message(text: text, isSender: true, timestamp: messageTime, imageAsset: _selectedImage));
    });
    _scrollToBottom();

    // 1s: show Seen
    final t1 = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (sentIndex < _messages.length) _messages[sentIndex].seen = true;
      });
      _scrollToBottom();
    });
    _activeTimers.add(t1);

    // 2s: hide Seen and show typing
    final t2 = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        if (sentIndex < _messages.length) _messages[sentIndex].seen = false;
        _isLoading = true;
        _loadingStartTime = DateTime.now();
      });
      _scrollToBottom();
    });
    _activeTimers.add(t2);

    // fallback after 5s
    _fallbackTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      // Cancel any outstanding timers and clear loading state before inserting fallback reply
      for (final t in _activeTimers) {
        try {
          t.cancel();
        } catch (_) {}
      }
      _activeTimers.clear();
      setState(() {
        _isLoading = false;
        _messages.add(Message(text: 'Hi', isSender: false, timestamp: DateTime.now(), footer: 'Tap and hold to react'));
      });
      _scrollToBottom();
      
      // Hide footer after 5 seconds
      final messageIndex = _messages.length - 1;
      Timer(const Duration(seconds: 5), () {
        if (!mounted || messageIndex >= _messages.length) return;
        setState(() {
          _messages[messageIndex].footer = null;
        });
      });
    });
    if (_fallbackTimer != null) _activeTimers.add(_fallbackTimer!);

    // network request
    final String apiContent = text.isNotEmpty ? text : (_selectedImage != null ? '[image]' : '');
    _messageHistory.add(ApiMessage(role: 'user', content: apiContent));
    try {
      final response = await http
          .post(
        Uri.parse(OPENROUTER_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $OPENROUTER_API_KEY',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'model': 'nvidia/nemotron-nano-12b-v2-vl:free',
          'messages': _messageHistory.map((m) => m.toJson()).toList(),
          'max_tokens': 60,
        }),
      )
          .timeout(const Duration(seconds: 15));

      debugPrint('OpenRouter response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        String responseText = '';
        try {
          final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
          try {
            responseText = responseBody['choices'][0]['message']['content'];
          } catch (_) {
            responseText = responseBody['choices'][0]['text'] ?? jsonEncode(responseBody);
          }
        } catch (e) {
          responseText = 'Assistant response parsing error: $e';
        }

        if (!mounted) return;
        // Cancel fallback and any other timers related to this send sequence
        if (_fallbackTimer != null && _fallbackTimer!.isActive) {
          _fallbackTimer!.cancel();
          _activeTimers.remove(_fallbackTimer);
          _fallbackTimer = null;
        }
        for (final t in _activeTimers) {
          try {
            t.cancel();
          } catch (_) {}
        }
        _activeTimers.clear();
        // ensure minimum typing duration
        if (_loadingStartTime != null) {
          final elapsed = DateTime.now().difference(_loadingStartTime!);
          if (elapsed < _minTypingDuration) {
            final wait = _minTypingDuration - elapsed;
            await Future.delayed(wait);
            if (!mounted) return;
          }
        }
        setState(() {
          _isLoading = false;
          _loadingStartTime = null;
          _messages.add(Message(text: responseText, isSender: false, timestamp: DateTime.now(), footer: 'Tap and hold to react'));
        });
        _messageHistory.add(ApiMessage(role: 'assistant', content: responseText));
        _scrollToBottom();
        
        // Hide footer after 5 seconds
        final messageIndex = _messages.length - 1;
        Timer(const Duration(seconds: 5), () {
          if (!mounted || messageIndex >= _messages.length) return;
          setState(() {
            _messages[messageIndex].footer = null;
          });
        });
      } else {
        debugPrint('OpenRouter non-200: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OpenRouter error: $e');
      // fallback will show
    }
    // after sending, clear selected image
    if (_selectedImage != null) {
      setState(() => _selectedImage = null);
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14, backgroundImage: NetworkImage(opponentAvatarUrl)),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(22.0)),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 마지막 수신 메시지 찾기
            String lastMessage = 'Seen';
            if (_messages.isNotEmpty) {
              try {
                final lastReceivedMessage = _messages.reversed.firstWhere(
                  (msg) => !msg.isSender,
                  orElse: () => Message(text: 'Seen', isSender: false, timestamp: DateTime.now()),
                );
                lastMessage = lastReceivedMessage.text;
              } catch (e) {
                lastMessage = 'Seen';
              }
            }
            Navigator.pop(context, lastMessage);
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(opponentAvatarUrl)),
            const SizedBox(width: 10.0),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
              Text('Active now', style: TextStyle(fontSize: 12.0, color: Colors.grey[600])),
            ])
          ],
        ),
          actions: [
            IconButton(icon: const Icon(Icons.call_outlined, size: 28.0), onPressed: () {}),
            IconButton(icon: const Icon(Icons.videocam_outlined, size: 28.0), onPressed: () {}),
            const SizedBox(width: 8),
          ],
        ),
      body: Stack(children: [
        Column(children: [
          Expanded(
            child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) return _buildTypingIndicator();
              final message = _messages[index];
              final showTimestamp = _shouldShowTimestamp(index);
              return Column(children: [if (showTimestamp) _buildTimestampMarker(message.timestamp), _buildMessageBubble(message, index)]);
            },
          ),
        ),
          _buildTextInputArea(),
        ]),

        // Selected image preview overlay (bottom-left)
        if (_selectedImage != null)
          Positioned(
            left: 12,
            bottom: 88,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset(_selectedImage!, width: 36, height: 36, fit: BoxFit.cover)),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                child: const Text('Tap to preview and edit', style: TextStyle(color: Colors.black87)),
              ),
            ]),
          ),
      ]),
    );
  }

  Widget _buildMessageBubble(Message message, int index) {
    final isSender = message.isSender;
    return Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Column(crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          // If message contains image, show image first
          if (message.imageAsset != null)
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(color: isSender ? _senderPurple : const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(12.0)),
              child: Image.asset(message.imageAsset!, fit: BoxFit.cover, width: MediaQuery.of(context).size.width * 0.6, height: 160),
            ),
          if (message.imageAsset != null && message.text.isNotEmpty) const SizedBox(height: 8.0),
          if (message.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(color: isSender ? _senderPurple : const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(22.0)),
              child: Text(message.text, style: TextStyle(color: isSender ? Colors.white : Colors.black, fontSize: 16.0)),
            ),
          const SizedBox(height: 6.0),
          if (message.seen && isSender) Padding(padding: const EdgeInsets.only(right: 4.0), child: Text('Seen just now', style: TextStyle(color: Colors.grey[600], fontSize: 12.0))),
          if (message.footer != null) Padding(padding: const EdgeInsets.only(left: 4.0), child: Text(message.footer!, style: TextStyle(color: Colors.grey[600], fontSize: 12.0))),
        ]),
      ),
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      child: Row(children: [
        Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(8.0), decoration: BoxDecoration(color: _senderPurple, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 20.0)),
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(22.0)),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(hintText: 'Message...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ]),
          ),
        ),
        // Show action icons when there's no text and no selected image
        if (!_hasText && _selectedImage == null) ...[
          const SizedBox(width: 8),
          IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none, color: Colors.black, size: 24.0)),
          IconButton(onPressed: _openImagePickerSheet, icon: const Icon(Icons.image_outlined, color: Colors.black, size: 24.0)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.black, size: 24.0)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 24.0)),
        ]
        // If there is text or a selected image, show Send
        else
          TextButton(onPressed: _isLoading ? null : _sendMessage, child: Text('Send', style: TextStyle(color: _senderPurple, fontSize: 16.0, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  Future<void> _openImagePickerSheet() async {
    _isImageSheetOpen = true;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) {
        return SizedBox(
          height: 240,
          child: Column(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Recents', style: TextStyle(fontWeight: FontWeight.bold)), TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))])),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.0),
                itemCount: _assetImages.length,
                itemBuilder: (context, idx) {
                  final asset = _assetImages[idx];
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, asset),
                    child: Stack(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(asset, fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
                      if (_selectedImage == asset)
                        Positioned(right: 4, top: 4, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: _instaBlue, shape: BoxShape.circle), child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 12)))),
                    ]),
                  );
                },
              ),
            ),
          ]),
        );
      },
    );

    if (result != null) {
      setState(() => _selectedImage = result);
    }
    _isImageSheetOpen = false;
  }
}

// Typing animation
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
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      setState(() => _currentIndex = (_currentIndex + 1) % 3);
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final isActive = i == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 7,
          height: 7,
          transform: Matrix4.translationValues(0, isActive ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}