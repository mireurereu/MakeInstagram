import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/widgets/comments_modal_content.dart';
import 'package:intl/intl.dart';

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
  bool _showHeartAnimation = false; // 더블 탭 하트 애니메이션 상태

  late int _currentLikeCount;

  // 인스타 블루
  final Color _instaBlue = const Color(0xFF3797EF);

  // 댓글 데이터 (로컬 상태 관리)
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

  void initState() {
    super.initState();
    _currentLikeCount = int.tryParse(widget.likeCount.replaceAll(',', '')) ?? 0;
  }


  // 댓글창 띄우기
  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 전체 화면 높이 사용 가능하게
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentsModalContent(
          comments: _comments,
          postOwnerName: widget.username,
          onCommentPosted: (text) {
            setState(() {
              _comments.add(Comment(
                username: 'ta_junhyuk', // 내 아이디
                avatarUrl: 'instagram/assets/images/profile3.jpg',
                text: text,
              ));
            });
          },
          onCommentLiked: (comment) {
            setState(() {
              comment.isLiked = !comment.isLiked;
              if (comment.isLiked) {
                comment.likeCount++;
              } else {
                comment.likeCount--;
              }
            });
          },
        );
      },
    );
  }

  // 더블 탭 좋아요 로직
  void _handleDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _currentLikeCount++; // 숫자 증가
        _showHeartAnimation = true;
      });
    } else {
      // 이미 좋아요 상태라도 하트 애니메이션은 보여줌 (인스타 방식)
      setState(() {
        _showHeartAnimation = true;
      });
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeartAnimation = false);
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _currentLikeCount++;
      } else {
        _currentLikeCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedLikes = NumberFormat.decimalPattern('en_US').format(_currentLikeCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 헤더 (프로필)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.userAvatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    if (widget.isSponsored)
                      const Text(
                        'Sponsored',
                        style: TextStyle(fontSize: 11, color: Colors.black),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.black),
            ],
          ),
        ),

        // 2. 이미지 슬라이더 (더블 탭 애니메이션 포함)
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
                    // 로딩 처리
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                      );
                    },
                    // 에러 처리
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[300]),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 400, // 정사각형 비율에 가깝게
                  viewportFraction: 1.0, // 화면 꽉 채움
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                ),
              ),
              
              // 비디오 아이콘 (영상인 경우)
              if (widget.isVideo)
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),

              // 더블 탭 하트 애니메이션
              if (_showHeartAnimation)
                const Icon(Icons.favorite, color: Colors.white, size: 100),

              // 인덱스 표시 (여러 장일 때 우측 상단 1/3)
              if (widget.postImageUrls.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentCarouselIndex + 1}/${widget.postImageUrls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 3. 액션 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Stack(
            alignment: Alignment.center, // 스택의 자식들을 중앙 정렬
            children: [
              // Layer 1: 좌우 아이콘 (Row)
              Row(
                children: [
                  // 왼쪽 아이콘 그룹
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.black,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _showCommentsModal,
                    child: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.send_outlined, color: Colors.black, size: 28),
                  
                  const Spacer(), // 남은 공간을 모두 밀어내어 북마크를 끝으로 보냄
                  
                  // 오른쪽 아이콘
                  const Icon(Icons.bookmark_border, color: Colors.black, size: 28),
                ],
              ),

              // Layer 2: 페이지 인디케이터 (중앙 고정)
              if (widget.postImageUrls.length > 1)
                Positioned(
                  // 터치 이벤트를 가리지 않도록 설정 (IgnorePointer는 선택사항이나 안전함)
                  child: IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.postImageUrls.asMap().entries.map((entry) {
                        return Container(
                          width: 6.0,
                          height: 6.0,
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // 선택된 점 파랑, 나머지 회색
                            color: _currentCarouselIndex == entry.key
                                ? _instaBlue
                                : Colors.grey[300],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),


        // 4. 정보 및 캡션
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 좋아요 수 (포맷 적용)
              Text(
                '$formattedLikes likes',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 6),
              // 캡션 (아이디 + 내용)
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: '${widget.username} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.caption),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // 댓글 보기 링크
              GestureDetector(
                onTap: _showCommentsModal,
                child: const Text(
                  'View all comments',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              // 시간
              Text(
                widget.timestamp,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}