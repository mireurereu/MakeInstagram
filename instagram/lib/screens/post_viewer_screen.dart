import 'package:flutter/material.dart';
import 'package:instagram/widgets/post_card_widget.dart';

class PostViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> posts; // list of post data maps compatible with PostCardWidget
  final int initialIndex;

  const PostViewerScreen({super.key, required this.posts, this.initialIndex = 0});

  @override
  State<PostViewerScreen> createState() => _PostViewerScreenState();
}

class _PostViewerScreenState extends State<PostViewerScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          final p = widget.posts[index];
          return SingleChildScrollView(
            child: PostCardWidget(
              username: p['username'] as String? ?? 'user',
              userAvatarUrl: p['userAvatarUrl'] as String? ?? '',
              postImageUrls: List<String>.from(p['postImageUrls'] ?? [p['image'] ?? '']),
              likeCount: p['likeCount']?.toString() ?? '0',
              caption: p['caption']?.toString() ?? '',
              timestamp: p['timestamp']?.toString() ?? '',
              isVideo: p['isVideo'] ?? false,
              initialComments: p['comments'] != null ? List.from(p['comments']) : null,
            ),
          );
        },
      ),
    );
  }
}
