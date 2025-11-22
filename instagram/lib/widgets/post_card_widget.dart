import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/widgets/comments_modal_content.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart'; // 제스처 인식을 위해 필요

class PostCardWidget extends StatefulWidget {
  final String username;
  final String userAvatarUrl;
  final List<String> postImageUrls;
  final String likeCount;
  final String caption;
  final String timestamp;
  final bool isVideo;
  final bool isSponsored;
  // [추가] 초기 댓글 리스트를 받을 수 있게 변경
  final List<Comment>? initialComments;

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
    // [추가] 생성자에서 받음 (기본값 null)
    this.initialComments,
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

  // 댓글 리스트 (late로 선언하여 initState에서 초기화)
  late List<Comment> _comments;

  @override
  void initState() {
    super.initState();
    
    // 1. 좋아요 수 파싱 (콤마 제거 후 정수 변환)
    _currentLikeCount = int.tryParse(widget.likeCount.replaceAll(',', '')) ?? 0;

    // 2. [핵심 수정] 댓글 초기화 로직 변경
    // 외부에서 댓글(initialComments)을 넘겨줬다면 그것을 사용하고,
    // 아예 안 넘겨줬다면(null) 기존처럼 더미 데이터를 사용 (피드 화면용),
    // 빈 리스트([])를 넘겨줬다면 댓글 0개로 시작 (새 게시물용).
    if (widget.initialComments != null) {
      _comments = List.from(widget.initialComments!);
    } else {
      _comments = []; // Initialize with an empty list instead of hardcoded comments
    }
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
                username: 'ta_junhyuk', // 내 아이디
                avatarUrl: 'assets/images/profile3.jpg', // 내 프사 경로 확인 필요
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
              GestureDetector(
                onTap: _navigateToProfile,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: widget.userAvatarUrl.startsWith('http') 
                      ? NetworkImage(widget.userAvatarUrl) 
                      : AssetImage(widget.userAvatarUrl) as ImageProvider, 
                      // 로컬/네트워크 이미지 모두 처리하도록 수정
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

        // 2. 미디어 (이미지 슬라이더)
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CarouselSlider(
                items: widget.postImageUrls.map((url) {
                  return Builder(
                    builder: (BuildContext context) {
                      // URL이 http로 시작하면 네트워크 이미지, 아니면 로컬 에셋 (새 게시물은 로컬 경로일 수 있음)
                      return url.startsWith('http') || url.startsWith('https')
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (c, o, s) => Container(color: Colors.grey[300]),
                            )
                          : Image.asset(
                              url, // 로컬 파일 경로 또는 에셋 경로
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (c, o, s) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
                            );
                    },
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
              // 좋아요 수 (0개면 표시 방식 변경 가능, 여기선 0 likes로 표시)
              Text('$formattedLikes likes', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: '${widget.username} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = _navigateToProfile,
                    ),
                    TextSpan(text: widget.caption),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              
              // 댓글 미리보기 문구 (댓글 없으면 숨김)
              if (_comments.isNotEmpty)
                GestureDetector(
                  onTap: _showCommentsModal,
                  child: Text(
                    'View all ${_comments.length} comments', 
                    style: const TextStyle(color: Colors.grey, fontSize: 14)
                  ),
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