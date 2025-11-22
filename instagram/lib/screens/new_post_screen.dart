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
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const Text('Sharing posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(children: const [Icon(Icons.info_outline), SizedBox(width: 8), Expanded(child: Text('Your account is public, so anyone can discover your posts and follow you.'))]),
              const SizedBox(height: 8),
              Row(children: const [Icon(Icons.repeat), SizedBox(width: 8), Expanded(child: Text('Anyone can reuse all or part of your post in features like remixes, sequences, templates and stickers, and download your post as part of their reel or post.'))]),
              const SizedBox(height: 8),
              Row(children: const [Icon(Icons.settings), SizedBox(width: 8), Expanded(child: Text('You can turn off reuse for each post or change the default in your settings.'))]),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(c);
                    _startShareProcess();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3797EF)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                    // Could navigate to settings or show a help URL
                  },
                  child: const Text('Manage settings', style: TextStyle(color: Colors.black54)),
                ),
              ),
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
        title: const Text('New post', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isSharing ? null : _onSharePressed,
            child: Text('Share', style: TextStyle(color: _isSharing ? Colors.grey : _instaBlue, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        decoration: const InputDecoration(hintText: 'Write a caption...', border: InputBorder.none),
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const ListTile(title: Text('Tag people'), trailing: Icon(Icons.chevron_right)),
              const ListTile(title: Text('Add location'), trailing: Icon(Icons.chevron_right)),
            ],
          ),
          if (_isSharing) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
        ],
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