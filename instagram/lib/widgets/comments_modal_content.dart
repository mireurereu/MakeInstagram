// lib/widgets/comments_modal_content.dart

import 'package:flutter/material.dart';
import 'package:instagram/widgets/comment_model.dart';

class CommentsModalContent extends StatefulWidget {
  // PostCard에서 전달받은 캡션(첫 번째 댓글) 정보
  final String caption;
  final String username;
  final String avatarUrl;

  const CommentsModalContent({
    super.key,
    required this.caption,
    required this.username,
    required this.avatarUrl,
  });

  @override
  State<CommentsModalContent> createState() => _CommentsModalContentState();
}

class _CommentsModalContentState extends State<CommentsModalContent> {
  // 댓글 입력창을 제어할 컨트롤러
  final TextEditingController _commentController = TextEditingController();

  // 댓글 목록을 저장하고 관리할 리스트 (State)
  late List<Comment> _comments;

  @override
  void initState() {
    super.initState();
    // 댓글 목록을 초기화합니다.
    _comments = [
      // 1. 첫 번째 아이템은 항상 게시물의 '캡션'입니다.
      Comment(
        username: widget.username,
        avatarUrl: widget.avatarUrl,
        text: widget.caption,
      ),
      // 2. 영상의 더미 데이터
      Comment(
        username: 'haetbaaan',
        avatarUrl: 'https://picsum.photos/seed/haetbaaan/100/100',
        text: 'so cute!! 🥹🥹',
        isLiked: true, // (좋아요가 눌린 상태로 시작)
      ),
      Comment(
        username: 'junehxuk',
        avatarUrl: 'https://picsum.photos/seed/junehxuk/100/100',
        text: 'I love puang',
      ),
    ];
  }

  // --- (신규) 댓글 게시 기능 ---
  void _postComment() {
    final String text = _commentController.text;
    if (text.isEmpty) return; // 빈 댓글은 게시하지 않음

    // setState를 호출하여 UI를 즉시 업데이트합니다.
    setState(() {
      // 새 댓글 객체 생성 (사용자 정보는 임시로 'my_profile' 사용)
      _comments.add(Comment(
        username: 'ta_junhyuk', // 내 유저 이름 (하드코딩)
        avatarUrl: 'https://picsum.photos/seed/my_profile/100/100',
        text: text,
      ));
      _commentController.clear(); // 입력창 비우기
      FocusManager.instance.primaryFocus?.unfocus(); // 키보드 내리기
    });
    // TODO: 이곳에서 Firebase 등 백엔드에 댓글 데이터 전송
  }

  // --- (신규) 댓글 '좋아요' 토글 기능 ---
  void _toggleCommentLike(Comment comment) {
    // 캡션(첫 번째 댓글)은 '좋아요' 대상에서 제외
    if (_comments.indexOf(comment) == 0) return; 

    setState(() {
      comment.isLiked = !comment.isLiked;
    });
    // TODO: 이곳에서 Firebase 등 백엔드에 '좋아요' 상태 전송
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
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                final isCaption = (index == 0); // 첫 번째 아이템은 캡션
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