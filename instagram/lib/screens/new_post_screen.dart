import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:instagram/screens/home_screen.dart'; // 홈 피드 갱신용
import 'package:instagram/screens/profile_screen.dart'; // 프로필 그리드 갱신용
import 'package:instagram/screens/main_navigation_screen.dart'; // 탭 전환용

class NewPostScreen extends StatefulWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  final File? imageFile;

  const NewPostScreen({Key? key, this.imagePath, this.imageBytes, this.imageFile}) : super(key: key);

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  bool _isSharing = false;
  final TextEditingController _captionController = TextEditingController();
  final Color _instaBlue = const Color(0xFF3797EF);

  void _onSharePressed() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Share to Facebook?"),
        content: const Text("You can change this later."),
        actions: [
          TextButton(onPressed: () { Navigator.pop(c); _startShareProcess(); }, child: const Text("Share")),
          TextButton(onPressed: () { Navigator.pop(c); _startShareProcess(); }, child: const Text("Not now")),
        ],
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
      'username': 'ta_junhyuk',
      'userAvatarUrl': 'https://picsum.photos/seed/junhyuk/100/100',
      'postImageUrls': [addedPath],
      'likeCount': '0',
      'caption': _captionController.text,
      'timestamp': 'Just now',
      'isVideo': false,
    };
    final currentFeed = HomeScreen.feedNotifier.value;
    HomeScreen.feedNotifier.value = [newPostData, ...currentFeed];

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
}