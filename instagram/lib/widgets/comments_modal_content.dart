import 'package:flutter/material.dart';
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/data/user_state.dart';
import 'dart:io';

class CommentsModalContent extends StatefulWidget {
  final List<Comment> comments;
  final String postOwnerName;
  final Function(String text, String? replyToUsername) onCommentPosted;
  final Function(Comment) onCommentLiked;
  final String? highlightedCommentId;
  final bool isMyPost;
  
  // [수정 1] 알림에서 진입했는지 확인하는 변수 추가
  final bool fromNotification;

  const CommentsModalContent({
    super.key,
    required this.comments,
    required this.postOwnerName,
    required this.onCommentPosted,
    required this.onCommentLiked,
    this.highlightedCommentId,
    this.isMyPost = false,
    this.fromNotification = false, // 기본값 false (평소에는 안 보임)
  });

  @override
  State<CommentsModalContent> createState() => _CommentsModalContentState();
}

class _CommentsModalContentState extends State<CommentsModalContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  
  final Color _instaBlue = const Color(0xFF3797EF);

  bool _showLikeHint = false;
  Comment? _hintTargetComment;
  
  String? _replyingToUsername;
  late final ValueNotifier<String?> _highlightedCommentIdNotifier;
  final List<String> _emojis = ['❤️', '🙌', '🔥', '👏', '😢', '😍', '😮', '😂'];
  bool _showInputTooltip = false;
  
  @override
  void initState() {
    super.initState();
    _highlightedCommentIdNotifier = ValueNotifier<String?>(widget.highlightedCommentId);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
      
      final shouldShowTooltip = widget.isMyPost && widget.comments.isEmpty;
      
      if (shouldShowTooltip) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _showInputTooltip = true;
            });
            
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showInputTooltip = false;
                });
              }
            });
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _highlightedCommentIdNotifier.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _toggleCommentLike(Comment comment) {
    setState(() {
      widget.onCommentLiked(comment);

      if (widget.comments.length == 1 && comment.isLiked) {
        _showLikeHint = true;
        _hintTargetComment = comment;
        
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showLikeHint = false;
              _hintTargetComment = null;
            });
          }
        });
      }
    });
  }

  void _postComment() async {
    final String text = _commentController.text;
    if (text.isEmpty) return;

    final tempComment = Comment(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      username: 'kkuma',
      avatarUrl: UserState.myAvatarUrlNotifier.value,
      text: text,
      replyToUsername: _replyingToUsername,
      isPosting: true,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      widget.comments.add(tempComment);
    });

    _commentController.clear();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        widget.comments.remove(tempComment);
        widget.onCommentPosted(text, _replyingToUsername);
        _replyingToUsername = null;
      });
      
      FocusManager.instance.primaryFocus?.unfocus();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  
  void _startReplyTo(String username) {
    setState(() {
      _replyingToUsername = username;
      _commentController.text = '@$username ';
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }
  
  void _cancelReply() {
    setState(() {
      _replyingToUsername = null;
      _commentController.clear();
    });
  }
  
  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        children: [
          // 상단 핸들바
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          
          // [수정 2] 타이틀 영역: Stack으로 변경하여 중앙 타이틀 + 우측 아이콘 배치
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. 전체 너비 잡기 (중앙 정렬을 위해)
                const SizedBox(width: double.infinity),
                
                // 2. 중앙 타이틀
                const Text(
                  'Comments',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                
                // 3. 우측 아이콘 (세로 점 3개)
                Positioned(
                  right: 8, // 우측 여백
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onPressed: () {
                      // 옵션 메뉴 동작 (필요시 구현)
                    },
                    constraints: const BoxConstraints(), // 패딩 최소화
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFDBDBDB)),
          
          // [수정 3] For you 섹션: fromNotification이 true일 때만 표시
          if (widget.fromNotification)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'For you',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                ],
              ),
            ),

          // 댓글 리스트
          Expanded(
            child: widget.comments.isEmpty
                ? _buildNoCommentsView()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: widget.comments.length,
                    itemBuilder: (context, index) {
                      final comment = widget.comments[index];
                      return _buildCommentRow(comment);
                    },
                  ),
          ),

          // 하단 입력창
          _buildCommentInputArea(),
        ],
      ),
    );
  }

  Widget _buildNoCommentsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No comments yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start the conversation.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentRow(Comment comment) {
    bool isAuthor = comment.username == widget.postOwnerName;
    bool isReply = comment.replyToUsername != null;
    bool hasReplies = widget.comments.any((c) => c.replyToUsername == comment.username && !c.isPosting);
    
    bool shouldShowReplyTo = comment.replyToUsername == null && 
                             !hasReplies && 
                             widget.postOwnerName == UserState.myId &&
                             UserState.amIFollowing(comment.username);

    return ValueListenableBuilder<String?>(
      valueListenable: _highlightedCommentIdNotifier,
      builder: (ctx, highlightedId, _) {
        final bool isHighlighted = highlightedId == comment.id;
        
        return GestureDetector(
          onTap: () {
            _highlightedCommentIdNotifier.value = null;
          },
          child: Container(
            color: isHighlighted ? const Color(0xFFE3F2FD) : Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(
                left: isReply ? 52.0 : 16.0,
                right: 16.0,
                top: 12.0,
                bottom: 12.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: isReply ? 14 : 18,
                    backgroundImage: _resolveImageProvider(comment.avatarUrl),
                  ),
                  const SizedBox(width: 12.0),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.username,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                            ),
                            if (comment.isLiked) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.favorite, size: 12, color: Colors.red),
                              const SizedBox(width: 4),
                              Container(
                                width: 14,
                                height: 14,
                                child: ValueListenableBuilder<String>(
                                  valueListenable: UserState.myAvatarUrlNotifier,
                                  builder: (context, avatarUrl, child) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: _getImageProvider(avatarUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            if (comment.timestamp != null) ..._buildTimestamp(comment.timestamp!),
                            if (isAuthor) ...[
                              const SizedBox(width: 6),
                              const Text(
                                '• Author',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        
                        Text(
                          comment.text,
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        
                        if (comment.isPosting) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'Posting...',
                            style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _startReplyTo(comment.username),
                                child: const Text(
                                  'Reply',
                                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              
                              if (comment.isLiked) ...[
                                const SizedBox(width: 12),
                                const Text(
                                  'Reply with a reel',
                                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                              
                              if (comment.username != 'kkuma') ...[
                                const SizedBox(width: 12),
                                const Text(
                                  'Hide',
                                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                          
                          if (shouldShowReplyTo) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _startReplyTo(comment.username),
                              child: Row(
                                children: [
                                  ValueListenableBuilder<String>(
                                    valueListenable: UserState.myAvatarUrlNotifier,
                                    builder: (context, avatarUrl, child) {
                                      return Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: _getImageProvider(avatarUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                                      children: [
                                        const TextSpan(text: 'Reply to '),
                                        TextSpan(
                                          text: comment.username,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),

                  if (!comment.isPosting)
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _toggleCommentLike(comment),
                              child: Icon(
                                comment.isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 18.0,
                                color: comment.isLiked ? Colors.red : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (comment.likeCount > 0)
                              Text(
                                '${comment.likeCount}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                        
                        if (_showLikeHint && _hintTargetComment == comment)
                          Positioned(
                            right: 24,
                            top: -10,
                            child: _buildLikeTooltip(),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  ImageProvider _resolveImageProvider(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return NetworkImage(url);
    final idx = url.indexOf('assets/');
    final path = idx >= 0 ? url.substring(idx) : url;
    return AssetImage(path);
  }

  Widget _buildLikeTooltip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      width: 200,
      child: const Text(
        'Now you can double tap a comment to like it.',
        style: TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCommentInputArea() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFDBDBDB), width: 0.5)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToUsername != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Text(
                    'Replying to $_replyingToUsername',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _emojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.onCommentPosted(emoji, null);
                      _replyingToUsername = null;
                    });
                  },
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                );
              }).toList(),
            ),
          ),
          
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Row(
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: UserState.myAvatarUrlNotifier,
                      builder: (context, avatarUrl, child) {
                        return CircleAvatar(
                          radius: 18,
                          backgroundImage: _getImageProvider(avatarUrl),
                        );
                      },
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _postComment(),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_commentController.text.isNotEmpty)
                      GestureDetector(
                        onTap: _postComment,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _instaBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.insert_emoticon_outlined,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
              if (_showInputTooltip)
                Positioned(
                  bottom: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 450,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Comments on public content can now be\nshared by others in their stories and reels.',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          bottom: -6,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: CustomPaint(
                              size: const Size(12, 7),
                              painter: _TooltipTailPainter(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TooltipTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on _CommentsModalContentState {
  List<Widget> _buildTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final seconds = difference.inSeconds;
    
    if (seconds >= 1 && seconds <= 59) {
      return [
        Text(
          '${seconds}s',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(width: 6),
      ];
    }
    
    return [];
  }
}