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
import 'dart:io';
import 'dart:async';

class PostCardWidget extends StatefulWidget {
  final String username;
  final String userAvatarUrl;
  final List<String> postImageUrls;
  final String likeCount;
  final String caption;
  final String timestamp;
  final DateTime? timestampDate;
  final bool isVideo;
  final bool isSponsored;
  final String? sponsoredText; // 광고 문구
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
    this.timestampDate,
    this.isVideo = false,
    this.isSponsored = false,
    this.sponsoredText,
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
  double _imageAspectRatio = 1.0;
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

  Timer? _timer;
  String _timeAgoDisplay = '';

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
    
    if (widget.isVideo && widget.postImageUrls.isNotEmpty) {
      _calculateImageAspectRatio();
    }
    // 3. 비디오 초기화
    if (widget.isVideo && widget.postImageUrls.isNotEmpty) {
      _initializeVideo(widget.postImageUrls[0]);
    }

    // initialize liked state from incoming prop (persisted in feed model)
    _isLiked = widget.isLiked ?? false;
    // initialize following state for header (so Follow button can reflect current state)
    _isFollowing = UserState.amIFollowing(widget.username);
    if (widget.timestampDate != null) {
      _updateTimeAgo(); // 초기값 설정
      final difference = DateTime.now().difference(widget.timestampDate!);
      if (difference.inMinutes < 1) {
        // 1초마다 갱신 (1분이 넘어가면 멈춤)
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            _updateTimeAgo();
          }
        });
      }
    }
  }

  void _calculateImageAspectRatio() {
    final String firstImageUrl = widget.postImageUrls[0];
    ImageProvider imageProvider;
    
    if (firstImageUrl.startsWith('http')) {
      imageProvider = NetworkImage(firstImageUrl);
    } else if (firstImageUrl.startsWith('assets/')) {
      imageProvider = AssetImage(firstImageUrl);
    } else {
      imageProvider = FileImage(File(firstImageUrl));
    }

    // 이미지 스트림을 통해 크기 확인
    final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
    
    stream.addListener(ImageStreamListener(
      (ImageInfo info, bool _) {
        if (mounted) {
          setState(() {
            // 너비 / 높이 = 비율 (예: 400/500 = 0.8)
            double ratio = info.image.width.toDouble() / info.image.height.toDouble();
            // 비율이 유효하지 않으면 1.0으로 설정
            if (ratio <= 0 || ratio.isNaN) ratio = 1.0;
            _imageAspectRatio = ratio;
          });
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        print('이미지 비율 계산 실패: $exception');
      },
    ));
  }
  
  void _initializeVideo(String videoUrl) async {
    try {
      // 로컬 asset인지 네트워크 URL인지 구분
      if (videoUrl.startsWith('assets/')) {
        _videoController = VideoPlayerController.asset(videoUrl);
      } else if (videoUrl.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      }
      
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      print('video reset fail: $e');
      print('video URL: $videoUrl');
    }
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _updateTimeAgo() {
    if (widget.timestampDate == null) return;

    final difference = DateTime.now().difference(widget.timestampDate!);
    
    setState(() {
      if (difference.inSeconds < 60) {
        // 1분 미만일 때는 "초" 단위 표시 (예: 5s)
        _timeAgoDisplay = '${difference.inSeconds}s';
      } else {
        // 1분이 넘어가면 타이머 정지하고 기존 timestamp 사용하거나 분 단위 표시
        _timer?.cancel();
        _timeAgoDisplay = widget.timestamp; 
      }
    });
  }

  void _showCommentsModal() async {
    // 1. 모달이 떠있는 동안 발생한 알림을 모아둘 리스트 생성
    final List<Map<String, dynamic>> pendingNotifications = [];

    // 2. 모달 표시 (await로 닫힐 때까지 대기)
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentsModalContent(
          comments: _comments,
          postOwnerName: widget.username,
          isMyPost: widget.username == UserState.myId,
          // [댓글 작성 콜백]
          onCommentPosted: (text, replyToUsername) {
            setState(() {
              final commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';
              _comments.add(Comment(
                id: commentId,
                username: 'kkuma',
                avatarUrl: UserState.getMyAvatarUrl(),
                text: text,
                replyToUsername: replyToUsername,
                timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
              ));
              
              final keyId = widget.key is ValueKey ? (widget.key as ValueKey).value : null;
              if (keyId is String) widget.onCommentsChanged?.call(keyId, _comments);

              // 알림 조건 체크
              final isMyPost = widget.username == UserState.myId;
              final isReplyToMe = replyToUsername == UserState.myId;
              
              if (isMyPost || isReplyToMe) {
                final notifId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
                String notifContent = isReplyToMe ? 'replied: $text' : 'commented: $text';
                
                // [수정] 즉시 실행하지 않고 리스트에 '추가'만 함
                pendingNotifications.add({
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
                });
              }
            });
          },
          // [댓글 좋아요 콜백]
          onCommentLiked: (comment) {
            setState(() {
              // 댓글 창에서 이미 상태가 변경되어 넘어오므로, 여기서는 조건만 확인
              if (comment.isLiked && comment.username == UserState.myId) {
                final notifId = 'notif_comment_like_${DateTime.now().millisecondsSinceEpoch}';
                
                // [수정] 즉시 실행하지 않고 리스트에 '추가'만 함
                pendingNotifications.add({
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
                });
              }
              
              final keyId = widget.key is ValueKey ? (widget.key as ValueKey).value : null;
              if (keyId is String) widget.onCommentsChanged?.call(keyId, _comments);
            });
          },
        );
      },
    );

    // 3. 모달이 닫힌 후(await 이후), 모아둔 알림이 있다면 한꺼번에 실행
    if (pendingNotifications.isNotEmpty) {
      final currentNotifs = NotificationsScreen.notificationsNotifier.value;
      
      // 최신 알림이 위로 오도록 역순으로 합치기
      NotificationsScreen.notificationsNotifier.value = [
        ...pendingNotifications.reversed,
        ...currentNotifs,
      ];
      
      // 배지 및 말풍선 표시
      NotificationsScreen.hasUnreadNotifications.value = true;
      NotificationsScreen.showCommentBubble.value = true;
      
      // 3초 뒤 말풍선 숨김
      Future.delayed(const Duration(seconds: 3), () {
        NotificationsScreen.showCommentBubble.value = false;
      });
    }
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


  // [추가] 헤더(프로필, 이름, 더보기)를 만드는 재사용 메서드
  Widget _buildHeader({bool isOverlay = false}) {
    // 오버레이(영상 위)일 때는 글자/아이콘을 흰색으로, 아닐 때는 검은색으로 설정
    final Color contentColor = isOverlay ? Colors.white : Colors.black;
    final Color subTextColor = isOverlay ? Colors.white70 : Colors.grey;

    return Container(
      // 오버레이일 경우 가독성을 위해 상단에 살짝 어두운 그라데이션 추가 (선택 사항)
      decoration: isOverlay
          ? const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black45, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            )
          : null,
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: contentColor, // [수정] 색상 동적 적용
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
                if ((widget.username == 'iamai') && !_isFollowing)
                  Text('Suggested for you', style: TextStyle(fontSize: 12, color: subTextColor)),
                if (widget.isSponsored)
                  Text('Sponsored', style: TextStyle(fontSize: 11, color: contentColor)),
              ],
            ),
          ),
          if ((widget.username == 'iamai') && !_isFollowing)
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
                    decoration: BoxDecoration(
                      color: isOverlay ? Colors.white24 : Colors.grey[200], // [수정] 배경색 동적 적용
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text('Follow', style: TextStyle(color: contentColor, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.more_vert, color: contentColor),
              ],
            )
          else
            Icon(Icons.more_vert, color: contentColor), // [수정] 아이콘 색상 동적 적용
        ],
      ),
    );
  }


  // [추가] 인스타그램 스타일 페이지 인디케이터 빌더
  Widget _buildPageIndicator() {
    final int count = widget.postImageUrls.length;
    if (count <= 1) return const SizedBox.shrink();

    // 6개 이하는 기존 방식 (모두 같은 크기 고정)
    if (count <= 7) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return Container(
            width: 6.0,
            height: 6.0,
            margin: const EdgeInsets.symmetric(horizontal: 3.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentCarouselIndex == index ? _instaBlue : Colors.grey[300],
            ),
          );
        }),
      );
    }

    // 6개 초과 시: 인스타그램 스타일 (슬라이딩 윈도우 + 크기 애니메이션)
    const int windowSize = 7; // 화면에 보일 점의 개수
    
    // 윈도우 시작 위치 계산 (현재 인덱스가 가운데 오도록 설정)
    int start = _currentCarouselIndex - 5;
    
    // 범위가 리스트를 벗어나지 않도록 보정 (Clamp)
    if (start < 0) start = 0;
    if (start > count - windowSize) start = count - windowSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        double size = 0.0;
        
        // 현재 윈도우(보이는 범위) 안에 있는 점들만 크기 부여
        if (index >= start && index < start + windowSize) {
          size = 6.0; // 기본 크기 (중간)
          
          if (index == _currentCarouselIndex) {
            size = 8.0; // 현재 선택된 점 (가장 큼)
          } 
          // 윈도우의 양 끝 점이면서, 실제 리스트의 끝이 아닐 경우 작게 표시 (작아지는 효과)
          else if (index == start && start > 0) {
            size = 4.0;
          } 
          else if (index == start + windowSize - 1 && start + windowSize < count) {
            size = 4.0;
          }
        }

        // AnimatedContainer를 사용하여 크기가 부드럽게 변하도록 함
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          // size가 0이면(숨겨진 점) margin도 0으로 설정하여 공간 차지 안 하게 함
          margin: EdgeInsets.symmetric(horizontal: size > 0 ? 3.0 : 0.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentCarouselIndex == index ? _instaBlue : Colors.grey[300],
          ),
        );
      }),
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
        if (!widget.isVideo) 
          _buildHeader(isOverlay: false),

        // 2. 미디어 (이미지 슬라이더)
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 비디오일 경우 VideoPlayer, 아니면 CarouselSlider
              widget.isVideo
                  ? GestureDetector(
                      onTap: () {
                        if (_isVideoInitialized) {
                          setState(() {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          });
                        }
                      },
                      child: Container(
                        color: Colors.black,
                        width: double.infinity, // 가로는 꽉 채움
                        child: _isVideoInitialized
                            ? AspectRatio(
                                // 영상의 실제 비율 사용
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              )
                            : const AspectRatio(
                                // 로딩 중일 때는 임시로 1:1 정사각형 유지 (혹은 16:9 등 원하는 비율)
                                aspectRatio: 1.0,
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              ),
                      ),
                    )
                  : CarouselSlider(
                      key: ValueKey(_imageAspectRatio),
                      items: widget.postImageUrls.map((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            // 이미지 타입에 따라 적절한 위젯 반환 (로컬 파일 지원 추가)
                            if (url.startsWith('http') || url.startsWith('https')) {
                              return Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (c, o, s) => Container(color: Colors.grey[300]),
                              );
                            } else if (url.startsWith('assets/')) {
                              return Image.asset(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (c, o, s) => Container(color: Colors.grey[300]),
                              );
                            } else {
                              // 로컬 파일 처리
                              return Image.file(
                                File(url),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (c, o, s) => Container(color: Colors.grey[300]),
                              );
                            }
                          },
                        );
                      }).toList(),
                      options: CarouselOptions(
                        // [핵심] 계산된 비율 적용 (사진 크기에 맞춰 게시물 틀이 늘어남)
                        aspectRatio: _imageAspectRatio, 
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) => setState(() => _currentCarouselIndex = index),
                      ),
                    ),

              if (widget.isVideo)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(isOverlay: true),
                ),
              // 비디오가 아직 초기화 중일 때 또는 일시정지 상태일 때 플레이 아이콘 표시
              if (widget.isVideo && (!_isVideoInitialized || !_videoController!.value.isPlaying))
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
              if (_showHeartAnimation) const Icon(Icons.favorite, color: Colors.white, size: 100),
              // 우측 상단 페이지 번호 (예: 1/3)
              if (widget.postImageUrls.length > 1)
                Positioned(
                  top: 12, 
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7), // 반투명 검은 배경
                      borderRadius: BorderRadius.circular(14), // 둥근 모서리
                    ),
                    child: Text(
                      '${_currentCarouselIndex + 1}/${widget.postImageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 광고 버튼 (이미지 바로 아래)
        if (widget.isSponsored && widget.sponsoredText != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: widget.sponsoredText == 'Install now' 
                ? const Color(0xFF4CAF50) // 초록색
                : const Color(0xFF3797EF), // 파란색 (Book now)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.sponsoredText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
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
                  // 광고가 아닐 때만 repost 아이콘 표시
                  if (!widget.isSponsored) ...[
                    // extra action icon (share)
                    GestureDetector(onTap: () {}, child: const Icon(Icons.ios_share, color: Colors.black, size: 26)),
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.send_outlined, color: Colors.black, size: 28),
                  const Spacer(),
                  const Icon(Icons.bookmark_border, color: Colors.black, size: 28),
                ],
              ),
              if (widget.postImageUrls.length > 1)
                IgnorePointer(
                  child: _buildPageIndicator(),
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
                      if (c.isLiked)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              c.isLiked = !c.isLiked; // 누르면 좋아요 취소 -> 하트 사라짐
                              if (c.isLiked) c.likeCount++; else c.likeCount--;
                              final keyId = widget.key is ValueKey ? (widget.key as ValueKey).value : null;
                              if (keyId is String) widget.onCommentsChanged?.call(keyId, _comments);
                            });
                          },
                        child: Column(
                            children: [
                              // [수정] "색이 채워지지 않은 상태"가 눌린 상태이므로 favorite_border 사용
                              const Icon(Icons.favorite_border, color: Colors.grey, size: 14),
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
              // 조건문을 없애고 무조건 widget.timestamp를 사용
              Text(
                // 1. 타이머가 돌고 있는(1분 미만) 상태면 초 단위(_timeAgoDisplay) 표시
                // 2. 아니면 기존 방식(widget.timestamp) 표시
                (_timer != null && _timer!.isActive) ? _timeAgoDisplay : widget.timestamp,
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