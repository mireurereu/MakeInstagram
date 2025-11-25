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

  const CommentsModalContent({
    super.key,
    required this.comments,
    required this.postOwnerName,
    required this.onCommentPosted,
    required this.onCommentLiked,
    this.highlightedCommentId,
  });

  @override
  State<CommentsModalContent> createState() => _CommentsModalContentState();
}

class _CommentsModalContentState extends State<CommentsModalContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  
  // 인스타 블루
  final Color _instaBlue = const Color(0xFF3797EF);

  bool _showLikeHint = false;
  // 툴팁을 띈울 대상 댓글 (방금 내가 쓴 댓글)
  Comment? _hintTargetComment;
  
  // 대댓글 관련 상태
  String? _replyingToUsername;
  
  // 하이라이트된 댓글 ID (ValueNotifier로 관리)
  late final ValueNotifier<String?> _highlightedCommentIdNotifier;
  
  // 이모지 리스트
  final List<String> _emojis = ['❤️', '🙌', '🔥', '👏', '😢', '😍', '😮', '😂'];
  
  @override
  void initState() {
    super.initState();
    _highlightedCommentIdNotifier = ValueNotifier<String?>(widget.highlightedCommentId);
  }
  
  @override
  void dispose() {
    _highlightedCommentIdNotifier.dispose();
    super.dispose();
  }

  void _toggleCommentLike(Comment comment) {
    setState(() {
      widget.onCommentLiked(comment);

      // [로직] 댓글이 1개뿐이고, 내가 좋아요를 눌렀을 때 힌트 표시
      if (widget.comments.length == 1 && comment.isLiked) {
        _showLikeHint = true;
        _hintTargetComment = comment;
        
        // 3초 뒤에 툴팁 사라짐
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

    // 1단계: Posting... 상태로 임시 댓글 추가
    final tempComment = Comment(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      username: 'ta_junhyuk',
      avatarUrl: UserState.myAvatarUrlNotifier.value,
      text: text,
      replyToUsername: _replyingToUsername,
      isPosting: true, // Posting 상태
    );
    
    setState(() {
      widget.comments.add(tempComment);
    });

    _commentController.clear();
    
    // 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // 2단계: 2초 대기 후 실제 등록
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        // 임시 댓글 제거
        widget.comments.remove(tempComment);
        
        // 실제 댓글 추가 (대댓글 정보 포함)
        widget.onCommentPosted(text, _replyingToUsername);
        
        // 3단계: 대댓글 상태 초기화
        _replyingToUsername = null;
      });
      
      FocusManager.instance.primaryFocus?.unfocus();
      
      // 다시 스크롤
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
    // 키보드 포커스
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
        color: Colors.white, // [수정] 배경 흰색
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
              color: Colors.grey[300], // [수정] 핸들바 색상 (연한 회색)
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          
          // 타이틀 (Comments - 중앙)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                'Comments',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFDBDBDB)),
          
          // For you (선 밑)
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
                ? _buildNoCommentsView() // 댓글 없을 때 화면
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
    bool isAuthor = comment.username == widget.postOwnerName; // 작성자 확인
    bool isReply = comment.replyToUsername != null; // 대댓글 여부
    
    // 이 댓글에 대한 대댓글이 있는지 확인 (Posting 상태가 아닌 것만)
    bool hasReplies = widget.comments.any((c) => c.replyToUsername == comment.username && !c.isPosting);

    return ValueListenableBuilder<String?>(
      valueListenable: _highlightedCommentIdNotifier,
      builder: (ctx, highlightedId, _) {
        final bool isHighlighted = highlightedId == comment.id;
        
        return GestureDetector(
          onTap: () {
            // 어느 댓글이라도 클릭하면 하이라이트 해제
            _highlightedCommentIdNotifier.value = null;
          },
          child: Container(
            color: isHighlighted ? const Color(0xFFE3F2FD) : Colors.transparent,
            child: Padding(
      padding: EdgeInsets.only(
        left: isReply ? 52.0 : 16.0, // 대댓글은 들여쓰기
        right: 16.0,
        top: 12.0,
        bottom: 12.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 아바타 (대댓글은 더 작게)
          CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundImage: _resolveImageProvider(comment.avatarUrl),
          ),
          const SizedBox(width: 12.0),
          
          // 2. 내용 (유저네임 + 뱃지 + 내용 + 답글버튼)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첫 번째 줄: 유저네임 + 하트/프로필 (좋아요 누른 경우) + 시간 + (Author)
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                    ),
                    // 내가 좋아요 누른 댓글에 하트와 프로필 사진 표시
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
                    const Text(
                      '1s', // 시간은 임시 고정 (모델에 timestamp 추가 시 연동 가능)
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
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
                
                // 두 번째 줄: 댓글 내용
                Text(
                  comment.text,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
                
                // Posting 상태일 때 "Posting..." 표시
                if (comment.isPosting) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Posting...',
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ] else ...[
                  // Reply/Hide 버튼들
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      // Reply 버튼
                      GestureDetector(
                        onTap: () => _startReplyTo(comment.username),
                        child: const Text(
                          'Reply',
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      
                      // 모든 댓글에 하트를 눌렀을 때 "Reply with a reel" 표시
                      if (comment.isLiked) ...[
                        const SizedBox(width: 12),
                        const Text(
                          'Reply with a reel',
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                      
                      // 다른 사람의 댓글이면 Hide 버튼 표시
                      if (comment.username != 'ta_junhyuk') ...[
                        const SizedBox(width: 12),
                        const Text(
                          'Hide',
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                  
                  // 대댓글이 아니고, 대댓글이 달리지 않은 일반 댓글에만 "Reply to username" 표시
                  if (comment.replyToUsername == null && !hasReplies) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _startReplyTo(comment.username),
                      child: Row(
                        children: [
                          // 내 프로필 사진 작게
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

          // 3. 좋아요 하트 + 숫자 (수직 배치) - Posting 상태가 아닐 때만 표시
          if (!comment.isPosting)
            Stack(
              alignment: Alignment.center, // 툴팁 위치 잡기 위함
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _toggleCommentLike(comment),
                      child: Icon(
                        comment.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18.0, // 아이콘 크기 조정
                        color: comment.isLiked ? Colors.red : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // [수정] 좋아요 숫자: 하트 밑에 표시 (0이면 숨김)
                    if (comment.likeCount > 0)
                      Text(
                        '${comment.likeCount}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                
                // [신규] 툴팁 표시 (조건부 렌더링)
                if (_showLikeHint && _hintTargetComment == comment)
                  Positioned(
                    right: 24, // 하트 왼쪽으로 배치
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
        color: Colors.black.withOpacity(0.9), // 툴팁 색상
        borderRadius: BorderRadius.circular(8),
      ),
      width: 200, // 너비 고정
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
          // Replying to 표시 (대댓글 모드일 때만)
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
          
          // 이모지 바
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _emojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    // 이모지를 댓글로 바로 포스트
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
          
          // 입력창
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
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _postComment(),
                    onChanged: (_) => setState(() {}), // 텍스트 변경 감지
                  ),
                ),
                // 텍스트가 있으면 Post 버튼, 없으면 Stickers 아이콘
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
        ],
      ),
    );
  }
}