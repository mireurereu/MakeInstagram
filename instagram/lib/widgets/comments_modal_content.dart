import 'package:flutter/material.dart';
import 'package:instagram/widgets/comment_model.dart'; // 모델 경로 확인 필요 (lib/models/comment.dart)

class CommentsModalContent extends StatefulWidget {
  final List<Comment> comments;
  final String postOwnerName;
  final Function(String) onCommentPosted;
  final Function(Comment) onCommentLiked;

  const CommentsModalContent({
    super.key,
    required this.comments,
    required this.postOwnerName,
    required this.onCommentPosted,
    required this.onCommentLiked,
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
  // 툴팁을 띄울 대상 댓글 (방금 내가 쓴 댓글)
  Comment? _hintTargetComment;

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

  void _postComment() {
    final String text = _commentController.text;
    if (text.isEmpty) return;

    setState(() {
      widget.onCommentPosted(text);
    });

    _commentController.clear();
    FocusManager.instance.primaryFocus?.unfocus();

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
          
          // 타이틀
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: const Text(
              'Comments',
              style: TextStyle(
                color: Colors.black, // [수정] 검은색 텍스트
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFDBDBDB)),

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 아바타
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(comment.avatarUrl),
          ),
          const SizedBox(width: 12.0),
          
          // 2. 내용 (유저네임 + 뱃지 + 내용 + 답글버튼)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첫 번째 줄: 유저네임 + 시간 + (Author)
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                    ),
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
                
                const SizedBox(height: 8),
                
                // 세 번째 줄: Reply 버튼
                const Text(
                  'Reply',
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // 3. 좋아요 하트 + 숫자 (수직 배치)
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
    );
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), // 하단 여백 (아이폰 홈바 고려)
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFDBDBDB), width: 0.5)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            // 내 프로필 이미지 (하드코딩 or Provider)
            backgroundImage: NetworkImage('https://picsum.photos/seed/junhyuk/100/100'),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.black), // [수정] 입력 텍스트 검은색
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _postComment(),
            ),
          ),
          TextButton(
            onPressed: _postComment,
            child: Text(
              'Post',
              style: TextStyle(
                color: _instaBlue, // [수정] 파란색
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}