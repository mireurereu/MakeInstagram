// lib/widgets/comments_modal_content.dart

import 'package:flutter/material.dart';
import 'package:instagram/widgets/comment_model.dart';

class CommentsModalContent extends StatefulWidget {
  // --- (신규) 부모로부터 받을 데이터와 함수들 ---
  final List<Comment> comments; // 1. 댓글 목록 (이제 부모가 소유)
  final Function(String) onCommentPosted; // 2. 댓글 게시 콜백
  final Function(Comment) onCommentLiked; // 3. 댓글 좋아요 콜백

  const CommentsModalContent({
    super.key,
    required this.comments,
    required this.onCommentPosted,
    required this.onCommentLiked,
  });

  @override
  State<CommentsModalContent> createState() => _CommentsModalContentState();
}

class _CommentsModalContentState extends State<CommentsModalContent> {
  // 댓글 입력창을 제어할 컨트롤러
  final TextEditingController _commentController = TextEditingController();


  // --- (신규) 댓글 게시 기능 ---
  void _postComment() {
    final String text = _commentController.text;
    if (text.isEmpty) return;

    // (수정) 로컬 state를 변경하는 대신, 부모에게 받은 콜백 함수를 호출합니다.
    widget.onCommentPosted(text);

    _commentController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // --- (신규) 댓글 '좋아요' 토글 기능 ---
  void _toggleCommentLike(Comment comment) {
    // (수정) 로컬 state를 변경하는 대신, 부모에게 받은 콜백 함수를 호출합니다.
    widget.onCommentLiked(comment);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // (이 코드는 PostCardWidget에서 가져옴)
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Comments',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          Divider(color: Colors.grey[700], height: 1),

          // 댓글 스크롤 영역
          Expanded(
            child: ListView.builder(
              // (수정) 로컬 _comments 대신 widget.comments 사용
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.comments[index];
                final isCaption = (index == 0);
                // _buildCommentTile 호출 (이제 _toggleCommentLike를 전달)
                return _buildCommentTile(comment, isCaption);
              },
            ),
          ),

          // 댓글 입력창
          _buildCommentInputArea(),
        ],
      ),
    );
  }

  // 댓글 입력창 위젯
  Widget _buildCommentInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://picsum.photos/seed/my_profile/100/100'),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: TextField(
              controller: _commentController, // 컨트롤러 연결
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: _postComment, // 'Post' 버튼에 기능 연결
            child: Text('Post', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // 댓글 타일 위젯 (수정됨 - Comment 모델 사용)
  Widget _buildCommentTile(Comment comment, bool isCaption) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(comment.avatarUrl)),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                    children: [
                      TextSpan(
                        text: '${comment.username} ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment.text),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),
                if (!isCaption)
                  Row(
                    children: [
                      Text('Reply', style: TextStyle(color: Colors.grey, fontSize: 12.0)),
                      const SizedBox(width: 16.0),
                      Text('See translation', style: TextStyle(color: Colors.grey, fontSize: 12.0)),
                    ],
                  ),
              ],
            ),
          ),
          // --- '좋아요' 기능 수정 ---
          if (!isCaption)
            IconButton(
              // 상태에 따라 아이콘 변경
              icon: comment.isLiked
                  ? Icon(Icons.favorite, size: 16.0, color: Colors.red)
                  : Icon(Icons.favorite_border, size: 16.0, color: Colors.grey),
              onPressed: () {
                // '좋아요' 토글 함수 호출
                _toggleCommentLike(comment);
              },
            ),
        ],
      ),
    );
  }
}