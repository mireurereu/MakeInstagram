import 'package:flutter/material.dart';
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/widgets/comments_modal_content.dart';
import 'package:intl/intl.dart';

class PostCardWidget extends StatefulWidget {
  final String username;
  final String userAvatarUrl;
  final List<String> postImageUrls;
  final String caption;
  final String likeCount;
  final String commentCount;
  final String timestamp;
  final bool isSponsored;
  final bool isCarousel;
  final bool isVideo;

  PostCardWidget({
    super.key,
    this.username = "aespa_official",
    this.userAvatarUrl = "https://picsum.photos/seed/aespa/100/100",
    List<String>? postImageUrls,
    this.caption = "Bee~ Gese Stay Alive 🐝",
    this.likeCount = "918,471",
    this.commentCount = "2,000",
    this.timestamp = "5 days ago",
    this.isSponsored = false,
    this.isVideo = false,
  })  : postImageUrls = postImageUrls ??
            ["https://picsum.photos/seed/karina/600/600"],
        isCarousel = (postImageUrls != null && postImageUrls.length > 1);

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  int _currentCarouselIndex = 0;
  bool _isLiked = false;
  late List<Comment> _comments;
  bool _showHeartAnimation = false;
  late int _currentLikeCount;

  @override
  void initState() {
    super.initState();
    _currentLikeCount = int.tryParse(widget.likeCount.replaceAll(',', '')) ?? 0;
    _comments = [
      Comment(
        username: widget.username,
        avatarUrl: widget.userAvatarUrl,
        text: widget.caption,
        likeCount: 0,
      ),
      Comment(
        username: 'haetbaaan',
        avatarUrl: 'https://picsum.photos/seed/haetbaaan/100/100',
        text: 'so cute!! 🥹🥹',
        isLiked: true,
        likeCount: 1,
      ),
      Comment(
        username: 'junehxuk',
        avatarUrl: 'https://picsum.photos/seed/junehxuk/100/100',
        text: 'I love puang',
        likeCount: 0,
      ),
    ];
  }

  void _handlePostComment(String text) {
    setState(() {
      _comments.add(Comment(
        username: 'ta_junhyuk',
        avatarUrl: 'https://picsum.photos/seed/my_profile/100/100',
        text: text,
        likeCount: 0,
      ));
    });
  }

  void _handleToggleCommentLike(Comment comment) {
    if (_comments.indexOf(comment) == 0) return;
    setState(() {
      comment.isLiked = !comment.isLiked;
      if (comment.isLiked) {
        comment.likeCount++;
      } else {
        comment.likeCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white, // [수정] 배경색 흰색
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(context),
          _buildActionButtons(),
          _buildFooter(context),
        ],
      ),
    );
  }

  // 1. 헤더 (검정 텍스트)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(widget.userAvatarUrl),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: TextStyle(
                    color: Colors.black, // [수정] 검정색
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isSponsored)
                  Text(
                    'Sponsored',
                    style: TextStyle(color: Colors.black54, fontSize: 12.0), // [수정] 진한 회색
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black), // [수정] 검정색 아이콘
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // 2. 본문 (이미지 및 애니메이션)
  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              itemCount: widget.postImageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.postImageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200], // [수정] 로딩 배경 밝은 회색
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.0)),
                    );
                  },
                );
              },
            ),
            if (widget.isCarousel)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '${_currentCarouselIndex + 1} / ${widget.postImageUrls.length}',
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ),
              ),
            if (widget.isCarousel)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.postImageUrls.length, (index) {
                    return Container(
                      width: 6.0,
                      height: 6.0,
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // [수정] 인디케이터 색상 (파랑 / 밝은 회색)
                        color: _currentCarouselIndex == index
                            ? Colors.blue
                            : Colors.white.withOpacity(0.8),
                      ),
                    );
                  }),
                ),
              ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showHeartAnimation ? 1.0 : 0.0,
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 100.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. 액션 버튼 (검정 아이콘)
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: _isLiked
                    ? Icon(Icons.favorite, color: Colors.red, size: 28)
                    : Icon(Icons.favorite_border,
                        color: Colors.black, size: 28), // [수정] 검정색
                onPressed: _handleIconTap,
              ),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline,
                    color: Colors.black, size: 28), // [수정] 검정색
                onPressed: () {
                  _showCommentsModal(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.send_outlined,
                    color: Colors.black, size: 28), // [수정] 검정색
                onPressed: () {},
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border,
                color: Colors.black, size: 28), // [수정] 검정색
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // 4. 푸터 (검정 텍스트)
  Widget _buildFooter(BuildContext context) {
    if (widget.isSponsored) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.caption,
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold), // [수정] 검정색
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Install now'),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 좋아요 수
          Text(
            '${NumberFormat.decimalPattern('en_US').format(_currentLikeCount)} likes',
            style: TextStyle(
              color: Colors.black, // [수정] 검정색
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          // 캡션 (유저네임 + 내용)
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black), // [수정] 기본 검정색
              children: [
                TextSpan(
                  text: '${widget.username} ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: widget.caption),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          // 댓글 수
          Text(
            'View all ${widget.commentCount} comments',
            style: TextStyle(color: Colors.black54), // [수정] 진한 회색 (또는 Colors.grey)
          ),
          const SizedBox(height: 4.0),
          // 날짜
          Text(
            widget.timestamp,
            style: TextStyle(color: Colors.black54, fontSize: 12.0), // [수정] 진한 회색
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentsModalContent(
          comments: _comments,
          onCommentPosted: _handlePostComment,
          onCommentLiked: _handleToggleCommentLike,
        );
      },
    );
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _currentLikeCount++;
      });
    }
    if (!widget.isVideo) {
      setState(() {
        _showHeartAnimation = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _showHeartAnimation = false;
        });
      });
    }
  }

  void _handleIconTap() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _currentLikeCount++;
      } else {
        _currentLikeCount--;
      }
    });
  }
}