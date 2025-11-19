import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screen.dart'; // [필수] 프로필 화면 import

class NewPostScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final dynamic imageFile;

  const NewPostScreen({super.key, this.imageBytes, this.imageFile});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  bool _isSharing = false;
  final Color _instaBlue = const Color(0xFF3797EF);
  final TextEditingController _captionController = TextEditingController();

  // 1. 공유 팝업
  void _onSharePressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text("Always share posts to Facebook?", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          content: const Text("You can change your sharing settings in Accounts Center and each time you share.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Column(children: [
              const Divider(height: 1, color: Colors.grey),
              SizedBox(width: double.infinity, height: 48, child: TextButton(onPressed: () { Navigator.pop(context); _startShareProcess(); }, child: Text("Share posts", style: TextStyle(color: _instaBlue, fontWeight: FontWeight.bold, fontSize: 16)))),
              const Divider(height: 1, color: Colors.grey),
              SizedBox(width: double.infinity, height: 48, child: TextButton(onPressed: () { Navigator.pop(context); _startShareProcess(); }, child: const Text("Not now", style: TextStyle(color: Colors.black, fontSize: 16)))),
            ]),
          ],
        );
      },
    );
  }

  // 2. [핵심] 실제 공유 및 프로필 데이터 업데이트
  void _startShareProcess() async {
    setState(() => _isSharing = true);

    // 업로드 딜레이 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    // [중요] 새 이미지 URL 생성 (실제로는 업로드된 URL)
    final String newImageUrl = 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/400';

    // [중요] 프로필 화면의 게시물 리스트 업데이트 (맨 앞에 추가)
    // 기존 리스트를 복사해서 새 리스트를 만들어야 ValueNotifier가 변경을 감지합니다.
    final currentPosts = ProfileScreen.myPostsNotifier.value;
    ProfileScreen.myPostsNotifier.value = [newImageUrl, ...currentPosts];

    if (!mounted) return;

    // 홈 화면(또는 프로필 화면)으로 돌아가기
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    // 탭을 프로필(index: 4)로 이동시키고 싶다면 MainNavigationScreen에서 제어해야 하지만,
    // 일단 홈화면으로 돌아가는 것이 일반적인 UX입니다.
    // (만약 프로필로 바로 가고 싶다면 메인 네비게이션에 이벤트를 전달해야 함)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('New post', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0)),
        actions: [
          TextButton(onPressed: _isSharing ? null : _onSharePressed, child: Text('Share', style: TextStyle(color: _isSharing ? Colors.grey : _instaBlue, fontSize: 16.0, fontWeight: FontWeight.bold))),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          image: widget.imageBytes != null
                              ? DecorationImage(image: MemoryImage(widget.imageBytes!), fit: BoxFit.cover)
                              : const DecorationImage(image: AssetImage('assets/images/post_1.jpg'), fit: BoxFit.cover),
                        ),
                      ), // 썸네일
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: _captionController, style: const TextStyle(color: Colors.black), decoration: const InputDecoration(hintText: 'Write a caption...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none), maxLines: 4)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildListTile('Tag people'), const Divider(height: 1),
                _buildListTile('Add location'), const Divider(height: 1),
                _buildListTile('Audience', trailingText: 'Everyone'), const Divider(height: 1),
                _buildListTile('Also share on'),
              ],
            ),
          ),
          if (_isSharing) Container(color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, {String? trailingText}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16.0, color: Colors.black)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (trailingText != null) Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 15)), if (trailingText != null) const SizedBox(width: 8), const Icon(Icons.chevron_right, color: Colors.grey)]),
      onTap: () {},
    );
  }
}