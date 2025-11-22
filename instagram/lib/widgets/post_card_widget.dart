import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:instagram/screens/profile_screen.dart'; // 프로필 화면 이동용
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/widgets/comments_modal_content.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';

class PostCardWidget extends StatefulWidget {
  final String username;
  final String userAvatarUrl;
  final List<String> postImageUrls;
  final String likeCount;
  final String caption;
  final String timestamp;
  final bool isVideo;
  final bool isSponsored;

  const PostCardWidget({
    super.key,
    required this.username,
    required this.userAvatarUrl,
    required this.postImageUrls,
    required this.likeCount,
    required this.caption,
    required this.timestamp,
    this.isVideo = false,
    this.isSponsored = false,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  int _currentCarouselIndex = 0;
  bool _isLiked = false;
  bool _showHeartAnimation = false;
  late int _currentLikeCount;
  final Color _instaBlue = const Color(0xFF3797EF);

  final List<Comment> _comments = [
    Comment(
      username: 'haetbaaan',
      avatarUrl: 'instagram/assets/images/profile2.jpg',
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

  @override
  void initState() {
    super.initState();
    _currentLikeCount = int.tryParse(widget.likeCount.replaceAll(',', '')) ?? 0;
  }

  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentsModalContent(
          comments: _comments,
          postOwnerName: widget.username,
          onCommentPosted: (text) {
            setState(() {
              _comments.add(Comment(
                username: 'ta_junhyuk',
                avatarUrl: 'instagram/assets/images/profile3.jpg',
                text: text,
              ));
            });
          },
          onCommentLiked: (comment) {
            setState(() {
              comment.isLiked = !comment.isLiked;
              if (comment.isLiked) comment.likeCount++; else comment.likeCount--;
            });
          },
        );
      },
    );
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _currentLikeCount++;
        _showHeartAnimation = true;
      });
    } else {
      setState(() => _showHeartAnimation = true);
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeartAnimation = false);
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) _currentLikeCount++; else _currentLikeCount--;
    });
  }

  // [신규] 프로필로 이동하는 함수
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(username: widget.username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedLikes = NumberFormat.decimalPattern('en_US').format(_currentLikeCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            children: [
              // 프로필 사진 클릭 시 이동
              GestureDetector(
                onTap: _navigateToProfile,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.userAvatarUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름 클릭 시 이동
                    GestureDetector(
                      onTap: _navigateToProfile,
                      child: Text(
                        widget.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (widget.isSponsored)
                      const Text('Sponsored', style: TextStyle(fontSize: 11, color: Colors.black)),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.black),
            ],
          ),
        ),

        // 2. 미디어
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CarouselSlider(
                items: widget.postImageUrls.map((url) {
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image, color: Colors.grey)));
                    },
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 400, 
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) => setState(() => _currentCarouselIndex = index),
                ),
              ),
              if (widget.isVideo) const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
              if (_showHeartAnimation) const Icon(Icons.favorite, color: Colors.white, size: 100),
              if (widget.postImageUrls.length > 1)
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                    child: Text('${_currentCarouselIndex + 1}/${widget.postImageUrls.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),

        // 3. 액션바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.red : Colors.black, size: 28),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(onTap: _showCommentsModal, child: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 28)),
                  const SizedBox(width: 16),
                  const Icon(Icons.send_outlined, color: Colors.black, size: 28),
                  const Spacer(),
                  const Icon(Icons.bookmark_border, color: Colors.black, size: 28),
                ],
              ),
              if (widget.postImageUrls.length > 1)
                IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.postImageUrls.asMap().entries.map((entry) {
                      return Container(
                        width: 6.0, height: 6.0, margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: _currentCarouselIndex == entry.key ? _instaBlue : Colors.grey[300]),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),

        // 4. 캡션 및 정보
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$formattedLikes likes', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: '${widget.username} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      // [추가] 캡션의 아이디 클릭 시에도 이동
                      recognizer:  TapGestureRecognizer()..onTap = _navigateToProfile,
                    ),
                    TextSpan(text: widget.caption),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _showCommentsModal,
                child: const Text('View all comments', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
              const SizedBox(height: 4),
              Text(widget.timestamp, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

// RichText 내 제스처 인식을 위해 필요 (위로 이동됨)