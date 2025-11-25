import 'package:flutter/material.dart';
import 'package:instagram/widgets/post_card_widget.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/widgets/comments_modal_content.dart';
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/data/user_state.dart';
import 'dart:io';

class PostViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> posts; // list of post data maps compatible with PostCardWidget
  final int initialIndex;
  final bool autoOpenComments; // 자동으로 댓글 열기
  final String? highlightedCommentId; // 하이라이트할 댓글 ID

  const PostViewerScreen({
    super.key,
    required this.posts,
    this.initialIndex = 0,
    this.autoOpenComments = false,
    this.highlightedCommentId,
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
    
    // 자동으로 댓글 모달 열기
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
    final post = widget.posts[currentIndex];
    final comments = (post['comments'] as List<Comment>?) ?? [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentsModalContent(
          comments: comments,
          postOwnerName: post['username'] as String? ?? '',
          highlightedCommentId: widget.highlightedCommentId,
          onCommentPosted: (text, replyToUsername) {
            // 댓글 추가 로직은 PostCardWidget에서 처리됨
          },
          onCommentLiked: (comment) {
            // 좋아요 로직은 PostCardWidget에서 처리됨
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                initialComments: p['comments'] != null ? List.from(p['comments']) : null,
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
            // 탭 클릭 시 PostViewerScreen 닫고 해당 탭으로 이동
            Navigator.pop(context);
            // MainNavigationScreen의 탭 변경은 pop 후 자동으로 원래 탭으로 돌아감
          },
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 28),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined, size: 28),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_outlined, size: 28),
              label: 'Reels',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined, size: 28),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
