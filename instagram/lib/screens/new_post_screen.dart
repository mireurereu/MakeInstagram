import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:instagram/screens/feed_screen.dart'; // 홈 피드 갱신용
import 'package:instagram/screens/profile_screen.dart'; // 프로필 그리드 갱신용
import 'package:instagram/screens/main_navigation_screen.dart'; // 탭 전환용

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

  void _onSharePressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  // show the pause sheet after the share sheet is dismissed
                  Future.delayed(const Duration(milliseconds: 200), () => _showPauseSheet());
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
              TextButton(onPressed: () {
                Navigator.pop(c);
                Future.delayed(const Duration(milliseconds: 200), () => _startShareProcess());
              }, child: const Text('No thanks', style: TextStyle(color: Colors.blue))),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startShareProcess() async {
    setState(() => _isSharing = true);
    await Future.delayed(const Duration(seconds: 2));

    // Add to profile grid
    final currentMyPosts = ProfileScreen.myPostsNotifier.value;
    final String addedPath = widget.imagePath ?? widget.imageFile?.path ?? '';
    ProfileScreen.myPostsNotifier.value = [addedPath, ...currentMyPosts];

    // Add to home feed
    final newPostData = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'username': 'ta_junhyuk',
      'userAvatarUrl': 'https://picsum.photos/seed/junhyuk/100/100',
      'postImageUrls': [addedPath],
      'likeCount': '0',
      'caption': _captionController.text,
      'timestamp': 'Just now',
      'isVideo': false,
    };
    final currentFeed = FeedScreen.feedNotifier.value;
    FeedScreen.feedNotifier.value = [newPostData, ...currentFeed];

    if (!mounted) return;
    mainNavKey.currentState?.changeTab(0);
    Navigator.of(context).popUntil((route) => route.isFirst);
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
        title: const Text('New Post', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isSharing ? null : _onSharePressed,
            child: Text('Share', style: TextStyle(color: _isSharing ? Colors.grey : _instaBlue, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[100],
                            child: Image(image: imageProvider, fit: BoxFit.contain),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _captionController,
                        decoration: const InputDecoration(
                          hintText: 'Add a caption...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        maxLines: null,
                        minLines: 1,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.poll_outlined, size: 16), label: const Text('Poll')), 
                          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.lightbulb_outline, size: 16), label: const Text('Prompt')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Tag people'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Add location'),
                      subtitle: const Text('People you share this content with can see the location you tag and view this content on the map.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),

                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.visibility_outlined),
                      title: const Text('Audience'),
                      trailing: Text('Everyone', style: TextStyle(color: Colors.grey[700])),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Also share on...'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: const [Text('Off', style: TextStyle(color: Colors.grey)), SizedBox(width: 8), Icon(Icons.new_releases, color: Colors.blue, size: 18)]),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.more_horiz),
                      title: const Text('More options'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            if (_isSharing) Container(color: Colors.black54, height: 4),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSharing ? null : _onSharePressed,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3797EF)),
              child: const Text('Share', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        _onSharePressed();
      }
    });
  }
}