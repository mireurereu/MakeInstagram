import 'dart:typed_data';
import 'dart:io';
import 'package:instagram/screens/edit_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/new_post_screen.dart';

class EditPostScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final File? imageFile;
  final String? assetPath;

  const EditPostScreen({super.key, this.imageBytes, this.imageFile, this.assetPath});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final List<Map<String, String>> _songs = [
    {'title': 'Magnetic', 'artist': 'Illit', 'art': 'assets/images/post1.jpg'},
    {'title': 'Supernova', 'artist': 'aespa', 'art': 'assets/images/post2.jpg'},
    {'title': 'Dreamscape', 'artist': 'Luna', 'art': 'assets/images/post3.jpg'},
    {'title': 'Midnight', 'artist': 'Noah', 'art': 'assets/images/post4.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = widget.imageBytes != null
        ? Image.memory(widget.imageBytes!, width: double.infinity, fit: BoxFit.cover)
        : (widget.assetPath != null)
            ? Image.asset(widget.assetPath!, width: double.infinity, fit: BoxFit.cover)
            : widget.imageFile != null
                ? Image.file(widget.imageFile!, width: double.infinity, fit: BoxFit.cover)
                : Container(color: Colors.grey[300], width: double.infinity, height: 300, child: const Center(child: Text('No image')));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [
          // [수정] 체크 아이콘 대신 'Next' 텍스트 버튼으로 변경
          TextButton(
            onPressed: () {
              // 노래 선택 후 필터 화면으로 이동 (또는 바로 NewPostScreen으로 이동 가능)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>NewPostScreen(
                    imagePath: widget.assetPath,
                    imageFile: widget.imageFile,
                    imageBytes: widget.imageBytes,
                  ),
                ),
              );
            },
            child: const Text('Next', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
        title: const Text('', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // Top image area
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(child: imageWidget),

                // right-side vertical icon column
                Positioned(
                  top: 40,
                  right: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFloatingIcon(Icons.music_note, 'Music'),
                      const SizedBox(height: 12),
                      _buildFloatingIcon(Icons.text_fields, 'Aa'),
                      const SizedBox(height: 12),
                      _buildFloatingIcon(Icons.emoji_emotions_outlined, 'Sticker'),
                      const SizedBox(height: 12),
                      _buildFloatingIcon(Icons.auto_awesome, 'Sparkle'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom songs list
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text('For you', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      itemCount: _songs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _songs[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: _loadAlbumArt(item['art']!),
                            ),
                          ),
                          title: Text(item['title'] ?? ''),
                          subtitle: Text(item['artist'] ?? ''),
                          onTap: () {
                            // TODO: preview/play the song
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, String tooltip) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
        onPressed: () {},
      ),
    );
  }

  Widget _loadAlbumArt(String path) {
    // try to load asset; if missing, show placeholder
    try {
      return Image.asset(path, fit: BoxFit.cover);
    } catch (_) {
      return Container(color: Colors.grey[300], child: const Icon(Icons.music_note));
    }
  }
}