import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/data/user_state.dart';
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/widgets/comments_modal_content.dart';
import 'package:instagram/screens/notifications_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart'; // 제스처 인식을 위해 필요
import 'package:video_player/video_player.dart';

class PostCardWidget extends StatefulWidget {
  final String username;
  final String userAvatarUrl;
  final List<String> postImageUrls;
  final String likeCount;
  final String caption;
  final String timestamp;
  final bool isVideo;
  final bool isSponsored;
  final bool isVerified; // 인증 배지
  // [추가] 초기 댓글 리스트를 받을 수 있게 변경
  final List<Comment>? initialComments;
  // Callbacks to persist changes upstream
  final void Function(String postId, int likeCount, bool isLiked)? onLikeChanged;
  final void Function(String postId, List<Comment> comments)? onCommentsChanged;
  // initial liked state (persisted)
  final bool? isLiked;

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
    this.isVerified = false,
    // [추가] 생성자에서 받음 (기본값 null)
    this.initialComments,
    this.onLikeChanged,
    this.onCommentsChanged,
    this.isLiked,
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
  late bool _isFollowing;
  
  // 비디오 플레이어 컨트롤러
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

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
    
    // 3. 비디오 초기화
    if (widget.isVideo && widget.postImageUrls.isNotEmpty) {
      _initializeVideo(widget.postImageUrls[0]);
    }

    // initialize liked state from incoming prop (persisted in feed model)
    _isLiked = widget.isLiked ?? false;
    // initialize following state for header (so Follow button can reflect current state)
    _isFollowing = UserState.amIFollowing(widget.username);
  }
  
  void _initializeVideo(String videoUrl) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
          isMyPost: widget.username == UserState.myId, // 내 게시물 여부 전달
          onCommentPosted: (text, replyToUsername) {
            setState(() {
              final commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';
              _comments.add(Comment(
                id: commentId,
                username: 'ta_junhyuk', // 내 아이디
                avatarUrl: UserState.getMyAvatarUrl(), // UserState에서 프로필 사진 가져오기
                text: text,
                replyToUsername: replyToUsername,
              ));
              // propagate comment changes upstream if handler provided
              final keyId = widget.key is ValueKey ? (widget.key as ValueKey).value : null;
              if (keyId is String) widget.onCommentsChanged?.call(keyId, _comments);

              // 알림 조건:
              // 1. 내 게시물에 댓글이 달린 경우 (게시물 주인이 나)
              // 2. 누군가 내 댓글에 대댓글을 남긴 경우 (replyToUsername이 나)
              final isMyPost = widget.username == UserState.myId;
              final isReplyToMe = replyToUsername == UserState.myId;
              
              if (isMyPost || isReplyToMe) {
                final currentNotifs = NotificationsScreen.notificationsNotifier.value;
                final notifId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
                
                String notifContent;
                if (isReplyToMe) {
                  notifContent = 'replied: $text';
                } else {
                  notifContent = 'commented: $text';
                }
                
                NotificationsScreen.notificationsNotifier.value = [
                  {
                    'type': NotificationType.comment,
                    'username': UserState.myId,
                    'content': notifContent,
                    'time': 'Just now',
                    'avatarUrl': UserState.getMyAvatarUrl(),
                    'postUrl': widget.postImageUrls.isNotEmpty ? widget.postImageUrls.first : null,
                    'showReplyButton': false,
                    'notificationId': notifId,
                    'postId': widget.key is ValueKey ? (widget.key as ValueKey).value : null,
                    'commentId': commentId,
                  },
                  ...currentNotifs,
                ];
                
                // Set unread badge to true
                NotificationsScreen.hasUnreadNotifications.value = true;
                
                // 댓글 알림 시 말풍선 표시 (3초 후 사라짐)
                NotificationsScreen.showCommentBubble.value = true;
                Future.delayed(const Duration(seconds: 3), () {
                  NotificationsScreen.showCommentBubble.value = false;
                });
              }
            });
          },
          onCommentLiked: (comment) {
            setState(() {
              final wasLiked = comment.isLiked;
              comment.isLiked = !comment.isLiked;
              if (comment.isLiked) comment.likeCount++; else comment.likeCount--;
              
              // 내 댓글에 좋아요가 눌렸을 때 알림
              if (!wasLiked && comment.isLiked && comment.username == UserState.myId) {
                final currentNotifs = NotificationsScreen.notificationsNotifier.value;
                final notifId = 'notif_comment_like_${DateTime.now().millisecondsSinceEpoch}';
                NotificationsScreen.notificationsNotifier.value = [
                  {
                    'type': NotificationType.like,
                    'username': UserState.myId,
                    'content': 'liked your comment.',
                    'time': 'Just now',
                    'avatarUrl': UserState.getMyAvatarUrl(),
                    'postUrl': widget.postImageUrls.isNotEmpty ? widget.postImageUrls.first : null,
                    'showReplyButton': false,
                    'notificationId': notifId,
                    'postId': widget.key is ValueKey ? (widget.key as ValueKey).value : null,
                    'commentId': comment.id,
                  },
                  ...currentNotifs,
                ];
                NotificationsScreen.hasUnreadNotifications.value = true;
              }
              
              final keyId = widget.key is ValueKey ? (widget.key as ValueKey).value : null;
              if (keyId is String) widget.onCommentsChanged?.call(keyId, _comments);
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
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) _currentLikeCount++; else _currentLikeCount--;
    });
    
    // 내 게시물에 좋아요가 눌렸을 때 알림
    if (!wasLiked && _isLiked && widget.username == UserState.myId) {
      final currentNotifs = NotificationsScreen.notificationsNotifier.value;
      final notifId = 'notif_like_${DateTime.now().millisecondsSinceEpoch}';
      NotificationsScreen.notificationsNotifier.value = [
        {
          'type': NotificationType.like,
          'username': UserState.myId,
          'content': 'liked your photo.',
          'time': 'Just now',
          'avatarUrl': UserState.getMyAvatarUrl(),
          'postUrl': widget.postImageUrls.isNotEmpty ? widget.postImageUrls.first : null,
          'showReplyButton': false,
          'notificationId': notifId,
          'postId': widget.key is ValueKey ? (widget.key as ValueKey).value : null,
        },
        ...currentNotifs,
      ];
      NotificationsScreen.hasUnreadNotifications.value = true;
    }
    
    // propagate change upstream if caller provided a handler and this widget has a ValueKey id
    final keyId = widget.key is ValueKey ? (widget.key as ValueKey).value : null;
    if (keyId is String) widget.onLikeChanged?.call(keyId, _currentLikeCount, _isLiked);
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
    final bool hasAuthorComment = _comments.any((cm) => cm.username == widget.username);
    
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          if (widget.isVerified) ...const [
                            SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              color: Color(0xFF3897F0),
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // If this is seed3 user and current user isn't following them,
                    // show "Suggested for you" under the username.
                    if ((widget.username == 'beom_jun__k' || widget.username == 'akmu_suhyun') && !_isFollowing)
                      const Text('Suggested for you', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    if (widget.isSponsored)
                      const Text('Sponsored', style: TextStyle(fontSize: 11, color: Colors.black)),
                  ],
                ),
              ),
              // If special case (seed3 and not following) show Follow button then menu icon
              if (widget.username == 'beom_jun__k' && !_isFollowing)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          UserState.toggleFollow(widget.username);
                          _isFollowing = UserState.amIFollowing(widget.username);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(18)),
                        child: const Text('Follow', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.more_horiz, color: Colors.black),
                  ],
                )
              else
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
              // 비디오일 경우 VideoPlayer, 아니면 CarouselSlider
              widget.isVideo && _isVideoInitialized
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : CarouselSlider(
                      items: widget.postImageUrls.map((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            // URL이 http로 시작하면 네트워크 이미지, 아니면 로컬 에셋 (새 게시물은 로컬 경로일 수 있음)
                            return url.startsWith('http') || url.startsWith('https')
                                ? Image.network(
                                    url,
                                    fit: BoxFit.fitWidth,
                                    width: double.infinity,
                                    errorBuilder: (c, o, s) => Container(color: Colors.grey[300]),
                                  )
                                : Image.asset(
                                    url, // 로컬 파일 경로 또는 에셋 경로
                                    fit: BoxFit.fitWidth,
                                    width: double.infinity,
                                    errorBuilder: (c, o, s) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
                                  );
                          },
                        );
                      }).toList(),
                      options: CarouselOptions(
                        aspectRatio: 1.0,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) => setState(() => _currentCarouselIndex = index),
                      ),
                    ),
              // 비디오가 아직 초기화 중일 때 또는 일시정지 상태일 때 플레이 아이콘 표시
              if (widget.isVideo && (!_isVideoInitialized || !_videoController!.value.isPlaying))
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
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
                  const SizedBox(width: 12),
                  GestureDetector(onTap: _showCommentsModal, child: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 28)),
                  const SizedBox(width: 12),
                  // extra action icon (share)
                  GestureDetector(onTap: () {}, child: const Icon(Icons.ios_share, color: Colors.black, size: 26)),
                  const SizedBox(width: 12),
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
              // 좋아요 수: 0이면 숨기고, 1이면 '1 like' 단수로 표시
              if (_currentLikeCount > 0)
                Text('$formattedLikes ${_currentLikeCount == 1 ? 'like' : 'likes'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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

              // If the post author left comments, show them inline with a small heart on the right
              for (final c in _comments.where((cm) => cm.username == widget.username))
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: '${c.username} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: c.text),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            c.isLiked = !c.isLiked;
                            if (c.isLiked) c.likeCount++; else c.likeCount--;
                            final keyId = widget.key is ValueKey ? (widget.key as ValueKey).value : null;
                            if (keyId is String) widget.onCommentsChanged?.call(keyId, _comments);
                          });
                        },
                        child: Column(
                          children: [
                            Icon(c.isLiked ? Icons.favorite : Icons.favorite_border, color: c.isLiked ? Colors.red : Colors.grey, size: 18),
                            if (c.likeCount > 0) Text('${c.likeCount}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // 댓글 미리보기 문구 (댓글 있으면 전체 보기로 이동)
              // If the post author has commented, hide the "View all" line and show "Just now" as timestamp.
              if (_comments.isNotEmpty && !hasAuthorComment)
                GestureDetector(
                  onTap: _showCommentsModal,
                  child: Text('View all ${_comments.length} comments', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ),

              const SizedBox(height: 4),
              Text(hasAuthorComment ? 'Just now' : widget.timestamp, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}