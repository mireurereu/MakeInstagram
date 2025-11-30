import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:instagram/constants.dart';
import 'dart:io';

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
  final String? avatarUrl;
  const ChatRoomScreen({super.key, required this.username, this.avatarUrl});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasText = false;
  bool _showSendIcon = false;
  bool _showPreviewTooltip = false;

  final List<Message> _messages = [];
  final List<Timer> _activeTimers = [];
  final List<ApiMessage> _messageHistory = [];
  Timer? _fallbackTimer;
  Timer? _tooltipTimer;

  final Color _instaBlue = const Color(0xFF3797EF);
  final Color _senderPurple = const Color(0xFF7C3AED);
  // assets list for picker
  final List<String> _assetImages = [
    'assets/images/post1.jpg',
    'assets/images/post2.jpg',
    'assets/images/post3.jpg',
    'assets/images/post4.jpg',
    'assets/images/post5.jpg',
    'assets/images/post6.jpg',
    'assets/images/post7.jpg',
    'assets/images/post8.jpg',
  ];
  String? _selectedImage;
  // (single image selection for DM)
  // ensure typing/loading is shown for at least this duration
  final Duration _minTypingDuration = const Duration(milliseconds: 1500);
  DateTime? _loadingStartTime;


  ImageProvider _getAvatarProvider() {
    final url = widget.avatarUrl;
    if (url == null || url.isEmpty) {
      // 기본 이미지
      return const NetworkImage('https://picsum.photos/seed/junhyuk/100/100');
    }
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return AssetImage(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _messageHistory.add(ApiMessage(role: 'system', content: 'You are a helpful assistant. Please answer concisely in 1 line or less.'));

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
    _tooltipTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _textController.text;
    if (text.isEmpty && _selectedImage == null) return;

    // Show send icon briefly
    setState(() => _showSendIcon = true);
    
    // Hide send icon after 200ms
    Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _showSendIcon = false);
    });

    _textController.clear();
    setState(() => _hasText = false);

    final DateTime messageTime = DateTime.now();
    final int sentIndex = _messages.length;

    setState(() {
      _messages.add(Message(text: text, isSender: true, timestamp: messageTime, imageAsset: _selectedImage));
    });
    _scrollToBottom();

    // 0.5s: show Seen
    final t1 = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        if (sentIndex < _messages.length) _messages[sentIndex].seen = true;
      });
      _scrollToBottom();
    });
    _activeTimers.add(t1);

    // 1s: hide Seen and show typing
    final t2 = Timer(const Duration(seconds: 1), () {
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
    // _fallbackTimer = Timer(const Duration(seconds: 5), () {
    //   if (!mounted) return;
    //   // Cancel any outstanding timers and clear loading state before inserting fallback reply
    //   for (final t in _activeTimers) {
    //     try {
    //       t.cancel();
    //     } catch (_) {}
    //   }
    //   _activeTimers.clear();
    //   setState(() {
    //     _isLoading = false;
    //     _messages.add(Message(text: 'Hi', isSender: false, timestamp: DateTime.now(), footer: 'Tap and hold to react'));
    //   });
    //   _scrollToBottom();
      
    //   // Hide footer after 5 seconds
    //   final messageIndex = _messages.length - 1;
    //   Timer(const Duration(seconds: 5), () {
    //     if (!mounted || messageIndex >= _messages.length) return;
    //     setState(() {
    //       _messages[messageIndex].footer = null;
    //     });
    //   });
    // });
    // if (_fallbackTimer != null) _activeTimers.add(_fallbackTimer!);

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
          CircleAvatar(radius: 14, backgroundImage: _getAvatarProvider()),
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
            CircleAvatar(radius: 16, backgroundImage: _getAvatarProvider()),
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
      ]),
    );
  }

  Widget _buildMessageBubble(Message message, int index) {
    final isSender = message.isSender;
    final isLastMessage = index == _messages.length - 1;
    final showSendIconForThisMessage = isSender && isLastMessage && _showSendIcon;
    
    return Container(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            CircleAvatar(
              radius: 16, 
              backgroundImage: _getAvatarProvider(),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible( // [수정] ConstrainedBox 대신 Flexible 사용 (자연스러운 크기 조절)
            child: Column(
              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
              if (message.imageAsset != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.black, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
                      child: Image.asset(message.imageAsset!, fit: BoxFit.contain),
                    ),
                  ],
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
          if (showSendIconForThisMessage) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8.0), // 말풍선과 높이 맞춤
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.send, color: Colors.grey[600], size: 16.0),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      child: Row(children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(22.0)),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: _hasText ? Colors.white : _senderPurple, shape: BoxShape.circle),
                child: Icon(
                  _hasText ? Icons.search : Icons.camera_alt,
                  color: _hasText ? _senderPurple : Colors.white,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(hintText: 'Message...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              // Show action icons when there's no text and no selected image
              if (!_hasText && _selectedImage == null) ...[
                IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none, color: Colors.black, size: 24.0)),
                IconButton(onPressed: _openImagePickerSheet, icon: const Icon(Icons.image_outlined, color: Colors.black, size: 24.0)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.black, size: 24.0)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 24.0)),
              ],
              // If there is text or a selected image, show Send icon inside the gray background
              if (_hasText || _selectedImage != null)
                GestureDetector(
                  onTap: _isLoading ? null : _sendMessage,
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: _senderPurple,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 18.0),
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
  }

  Future<void> _openImagePickerSheet() async {
    String? tempSelectedImage = _selectedImage;
    bool showTooltip = false;
    bool showBottomBar = _selectedImage != null;
    Timer? tooltipTimer;
    
    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Recents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey[800]),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _assetImages.length,
                    itemBuilder: (context, idx) {
                      final asset = _assetImages[idx];
                      return GestureDetector(
                        onTap: () {
                          tooltipTimer?.cancel();
                          setModalState(() {
                            tempSelectedImage = asset;
                            showTooltip = true;
                            showBottomBar = true;
                          });
                          
                          // Show tooltip for 3 seconds
                          tooltipTimer = Timer(const Duration(seconds: 3), () {
                            if (context.mounted) {
                              setModalState(() {
                                showTooltip = false;
                              });
                            }
                          });
                        },
                        child: Stack(children: [
                          Image.asset(asset, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          if (tempSelectedImage == asset)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _instaBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Center(
                                  child: Text('1', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                        ]),
                      );
                    },
                  ),
                ),
                // Bottom bar with selected image and send button with slide animation
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: showBottomBar && tempSelectedImage != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      tempSelectedImage!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (showTooltip)
                                    Positioned(
                                      bottom: 58,
                                      left: -8,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Text(
                                              'Tap to preview and edit',
                                              style: TextStyle(color: Colors.black, fontSize: 12),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 16),
                                            child: CustomPaint(
                                              size: const Size(12, 8),
                                              painter: _TooltipTrianglePainter(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                  setState(() => _selectedImage = tempSelectedImage);
                                  await _sendMessage();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _senderPurple,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ]),
            );
          },
        );
      },
    );

    tooltipTimer?.cancel();
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

// Custom painter for tooltip triangle
class _TooltipTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 2, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}