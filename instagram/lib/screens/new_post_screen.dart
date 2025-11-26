import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:instagram/screens/feed_screen.dart'; // 홈 피드 갱신용
import 'package:instagram/screens/profile_screen.dart'; // 프로필 그리드 갱신용
import 'package:instagram/screens/main_navigation_screen.dart'; // 탭 전환용
import 'package:instagram/data/user_state.dart';

class NewPostScreen extends StatefulWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  final File? imageFile;
  final bool autoShowShareSheet;

  const NewPostScreen({Key? key, this.imagePath, this.imageBytes, this.imageFile, this.autoShowShareSheet = false}) : super(key: key);

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  bool _isSharing = false;
  bool _didAutoShow = false;
  final TextEditingController _captionController = TextEditingController();
  final Color _instaBlue = const Color(0xFF3797EF);

  void _showSharingInfoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const Text('Sharing posts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
              const SizedBox(height: 16),

              // Info rows with icons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.public, size: 24),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your account is public, so anyone can discover your posts and follow you.', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.add_photo_alternate_outlined, size: 24),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Anyone can reuse all or part of your post in features like remixes, sequences, templates and stickers, and download your post as part of their reel or post.', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.block_outlined, size: 24),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You can turn off reuse for each post or change the default in your settings.', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // OK button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(c);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to settings
                  },
                  child: const Text('Manage settings', style: TextStyle(color: Color(0xFF0095F6), fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Open help center
                  },
                  child: const Text('Learn more in the Help Center.', style: TextStyle(color: Colors.black87, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _onSharePressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 4),
              const Text('Always share posts to Facebook?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // three descriptive rows
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [Icon(Icons.facebook, size: 22), SizedBox(width: 12), Expanded(child: Text('Let your friends see your posts, no matter which app they\'re on.'))]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [Icon(Icons.lock_outline, size: 22), SizedBox(width: 12), Expanded(child: Text('You will share as 최준혁. Your audience for posts on Facebook is Only me.'))]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [Icon(Icons.settings_outlined, size: 22), SizedBox(width: 12), Expanded(child: Text('You can change your sharing settings in Accounts Center and each time you share.'))]),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(c);
                    // proceed to actual share
                    _startShareProcess();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5BFF)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Share posts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  // Navigate to profile and then show pause sheet
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  mainNavKey.currentState?.changeTab(4);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      _showPauseSheet();
                    }
                  });
                },
                child: const Text('Not now', style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 4),
              const Text('Pause these messages?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('You\'ll stop seeing messages about sharing to Facebook for 90 days. You can turn on crossposting when you share a story, post or reel.'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(c);
                    // implement pause action if needed (currently just closes)
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Pause', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () async {
                Navigator.pop(c);
                // Wait 1 second then navigate to feed and share
                await Future.delayed(const Duration(milliseconds:1000));
                await _addPostToFeed();
                mainNavKey.currentState?.changeTab(0);
              }, child: const Text('No thanks', style: TextStyle(color: Colors.blue))),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startShareProcess() async {
    if (!mounted) return;
    setState(() => _isSharing = true);
    await Future.delayed(const Duration(seconds: 2));

    await _addPostToFeed();

    if (!mounted) return;
    mainNavKey.currentState?.changeTab(0);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _addPostToFeed() async {
    // Add to profile grid
    final currentMyPosts = ProfileScreen.myPostsNotifier.value;
    final String addedPath = widget.imagePath ?? widget.imageFile?.path ?? '';
    ProfileScreen.myPostsNotifier.value = [addedPath, ...currentMyPosts];

    // Add to home feed
    final newPostData = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'username': 'ta_junhyuk',
      'userAvatarUrl': UserState.getMyAvatarUrl(),
      'postImageUrls': [addedPath],
      'likeCount': '0',
      'caption': _captionController.text,
      'timestamp': 'Just now',
      'isVideo': false,
    };
    final currentFeed = FeedScreen.feedNotifier.value;
    FeedScreen.feedNotifier.value = [newPostData, ...currentFeed];

    // Show the transient "Posted" banner in the feed with a thumbnail.
    FeedScreen.postedBannerNotifier.value = {'image': addedPath, 'message': 'Posted! Way to go.'};
    // Auto-clear the banner after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (FeedScreen.postedBannerNotifier.value != null && FeedScreen.postedBannerNotifier.value!['image'] == addedPath) {
        FeedScreen.postedBannerNotifier.value = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider = widget.imageBytes != null
        ? MemoryImage(widget.imageBytes!)
        : widget.imageFile != null
            ? FileImage(widget.imageFile!)
            : (widget.imagePath != null ? AssetImage(widget.imagePath!) : const AssetImage('assets/placeholder.png')) as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New post', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 이미지 미리보기
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Caption 입력
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _captionController,
                  decoration: const InputDecoration(
                    hintText: 'Add a caption...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  maxLines: null,
                  minLines: 1,
                  style: const TextStyle(fontSize: 15),
                ),
              ),

              const SizedBox(height: 16),
              // Poll / Prompt 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.poll_outlined, size: 16, color: Colors.black),
                      label: const Text('Poll', style: TextStyle(color: Colors.black, fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFEFEF),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.auto_awesome_outlined, size: 16, color: Colors.black),
                      label: const Text('Prompt', style: TextStyle(color: Colors.black, fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFEFEF),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, thickness: 1, color: Color(0xFFDBDBDB)),
              
              // Tag people
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const Icon(Icons.person_outline, color: Colors.black),
                title: const Text('Tag people', style: TextStyle(fontSize: 15)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {},
              ),
              
              // Add location (선 없이 바로 이어짐)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const Icon(Icons.location_on_outlined, color: Colors.black),
                title: const Text('Add location', style: TextStyle(fontSize: 15)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {},
              ),
              // Add location의 서브타이틀을 별도로 배치
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16), // 아이콘과 정확히 맞추기
                    Expanded(
                      child: Text(
                        'People you share this content with can see the location you tag and view this content on the map.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 8, color: Color(0xFFF0F0F0)),

              // Audience
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const Icon(Icons.visibility_outlined, color: Colors.black),
                title: const Text('Audience', style: TextStyle(fontSize: 15)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Everyone', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: () {},
              ),
              
              // Also share on...
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const Icon(Icons.share_outlined, color: Colors.black),
                title: const Text('Also share on...', style: TextStyle(fontSize: 15)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Off', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _instaBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 8, color: Color(0xFFF0F0F0)),
              
              // More options
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const Icon(Icons.more_horiz, color: Colors.black),
                title: const Text('More options', style: TextStyle(fontSize: 15)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFDBDBDB)),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSharing ? null : _onSharePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSharing ? Colors.grey : const Color(0xFF3797EF),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isSharing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Share', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoShowShareSheet && !_didAutoShow) {
        _didAutoShow = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          _showSharingInfoSheet();
        });
      }
    });
  }
}