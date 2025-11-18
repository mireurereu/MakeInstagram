// 1. (수정) dart:io 삭제, dart:typed_data 추가
import 'dart:typed_data';
import 'package:flutter/material.dart';

class NewPostScreen extends StatefulWidget {
  // Support either bytes or a File for backward compatibility
  final Uint8List? imageBytes;
  final dynamic imageFile;

  const NewPostScreen({super.key, this.imageBytes, this.imageFile});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isSharing = false;

  Future<void> _sharePost() async {
    setState(() {
      _isSharing = true;
    });

    String caption = _captionController.text;

    // --- TODO: 이곳에서 imageBytes를 Firebase Storage에 업로드 ---
    // (지금은 2초 딜레이로 시뮬레이션)
    await Future.delayed(Duration(seconds: 2));
    debugPrint('Post Shared! Caption: $caption');
    // --- --- --- --- ---

    setState(() {
      _isSharing = false;
    });

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('New post'),
        actions: [
          TextButton(
            onPressed: _isSharing ? null : _sharePost,
            child: Text(
              'Share',
              style: TextStyle(
                color: _isSharing ? Colors.grey : Colors.blue,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3. Show image from bytes or File (backwards compatible)
                    if (widget.imageBytes != null)
                      Image.memory(
                        widget.imageBytes!,
                        width: 72.0,
                        height: 72.0,
                        fit: BoxFit.cover,
                      )
                    else if (widget.imageFile != null)
                      Image.file(
                        widget.imageFile,
                        width: 72.0,
                        height: 72.0,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        width: 72.0,
                        height: 72.0,
                        color: Colors.grey[800],
                      ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Write a caption...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[800]),
              ListTile(
                title: Text('Tag people', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.chevron_right, color: Colors.white),
              ),
              ListTile(
                title: Text('Add location', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
          
          if (_isSharing)
            Container(
              color: Color.fromRGBO(0, 0, 0, 0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Sharing...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}