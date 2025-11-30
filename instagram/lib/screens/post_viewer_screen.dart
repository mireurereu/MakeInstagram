import 'package:flutter/material.dart';
import 'package:instagram/widgets/post_card_widget.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/widgets/comments_modal_content.dart';
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/data/user_state.dart';
import 'package:instagram/screens/notifications_screen.dart'; // 알림 관련 처리를 위해 필요하다면 추가
import 'dart:io';

class PostViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> posts; 
  final int initialIndex;
  final bool autoOpenComments; 
  final String? highlightedCommentId; 
  final bool fromNotification;

  const PostViewerScreen({
    super.key,
    required this.posts,
    this.initialIndex = 0,
    this.autoOpenComments = false,
    this.highlightedCommentId,
    this.fromNotification = false,
  });

  @override
  State<PostViewerScreen> createState() => _PostViewerScreenState();
}

class _PostViewerScreenState extends State<PostViewerScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    
    if (widget.autoOpenComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openCommentsModal();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _openCommentsModal() {
    final currentIndex = _pageController.hasClients 
        ? _pageController.page?.round() ?? widget.initialIndex
        : widget.initialIndex;
    
    // [중요] widget.posts는 복사본일 수 있으므로 FeedNotifier에서 최신 데이터를 직접 참조하는 것이 안전합니다.
    final currentFeed = FeedScreen.feedNotifier.value;
    final postData = widget.posts[currentIndex];
    final realPostIndex = currentFeed.indexWhere((p) => p['id'] == postData['id']);
    
    // 만약 피드에서 찾을 수 없다면 기존 데이터 사용
    final targetPost = (realPostIndex != -1) ? currentFeed[realPostIndex] : postData;
    final comments = (targetPost['comments'] as List<Comment>?) ?? [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentsModalContent(
          comments: comments, // 연동된 최신 댓글 리스트 전달
          postOwnerName: targetPost['username'] as String? ?? '',
          highlightedCommentId: widget.highlightedCommentId,
          fromNotification: widget.fromNotification,
          
          // [수정 1] 댓글 작성 콜백 구현
          onCommentPosted: (text, replyToUsername) {
            final newComment = Comment(
              id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
              username: UserState.myId,
              avatarUrl: UserState.getMyAvatarUrl(),
              text: text,
              replyToUsername: replyToUsername,
              timestamp: DateTime.now(),
            );

            // 1. 현재 화면의 댓글 리스트에 추가 (즉각 반응용)
            comments.add(newComment);

            // 2. 전역 피드 데이터 업데이트 (FeedScreen 반영용)
            if (realPostIndex != -1) {
              final updatedFeed = List<Map<String, dynamic>>.from(FeedScreen.feedNotifier.value);
              updatedFeed[realPostIndex]['comments'] = comments; // 참조 업데이트
              FeedScreen.feedNotifier.value = updatedFeed; // 리스너 알림
            }
          },

          // [수정 2] 댓글 좋아요 콜백 구현
          onCommentLiked: (comment) {
            // CommentsModalContent 내부에서 이미 isLiked 상태가 변경되어 넘어옵니다.
            // 여기서는 변경된 상태를 전역 피드에 알리기만 하면 됩니다.
            
            if (realPostIndex != -1) {
              // 값의 변경을 알리기 위해 리스트를 새로 할당
              final updatedFeed = List<Map<String, dynamic>>.from(FeedScreen.feedNotifier.value);
              // (객체는 참조이므로 내용은 이미 바뀌어 있지만, Notifier를 트리거하기 위함)
              FeedScreen.feedNotifier.value = updatedFeed;
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 뷰어에서도 실시간 업데이트를 반영하기 위해 ValueListenableBuilder 사용 권장
    // 하지만 구조상 복잡해질 수 있으므로, 기존 로직 유지하되 데이터 갱신에 집중
    final p = widget.posts[widget.initialIndex];
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Photo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: PostCardWidget(
                key: p['id'] != null ? ValueKey(p['id'] as String) : null,
                username: p['username'] as String? ?? 'user',
                userAvatarUrl: p['userAvatarUrl'] as String? ?? '',
                postImageUrls: List<String>.from(p['postImageUrls'] ?? [p['image'] ?? '']),
                likeCount: p['likeCount']?.toString() ?? '0',
                caption: p['caption']?.toString() ?? '',
                timestamp: p['timestamp']?.toString() ?? '',
                isVideo: p['isVideo'] ?? false,
                // [중요] 댓글 리스트를 FeedNotifier의 최신 데이터로 연결하면 더 확실합니다.
                initialComments: p['comments'] != null ? List.from(p['comments']) : null,
                
                // 기존 콜백 유지 (PostCardWidget 내부에서 하트/댓글 발생 시)
                onLikeChanged: (postId, likeCount, isLiked) {
                  final current = FeedScreen.feedNotifier.value;
                  final idx = current.indexWhere((it) => it['id'] == postId);
                  if (idx != -1) {
                    current[idx]['likeCount'] = likeCount.toString();
                    current[idx]['isLiked'] = isLiked;
                    FeedScreen.feedNotifier.value = List<Map<String, dynamic>>.from(current);
                  }
                },
                onCommentsChanged: (postId, comments) {
                  final current = FeedScreen.feedNotifier.value;
                  final idx = current.indexWhere((it) => it['id'] == postId);
                  if (idx != -1) {
                    current[idx]['comments'] = comments;
                    FeedScreen.feedNotifier.value = List<Map<String, dynamic>>.from(current);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFDBDBDB), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            Navigator.pop(context);
          },
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search, size: 28), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined, size: 28), label: 'Create'),
            BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined, size: 28), label: 'Reels'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined, size: 28), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}