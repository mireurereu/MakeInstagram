import 'dart:typed_data';
import 'dart:io';
import 'package:instagram/screens/edit_filter_screen.dart';
import 'package:instagram/screens/create_post_screen.dart';
import 'package:instagram/screens/new_post_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
    {'title': 'Blue Moon', 'artist': 'Aurora', 'art': 'assets/images/music1.jpg'},
    {'title': 'Sunset Ride', 'artist': 'Kaito', 'art': 'assets/images/music2.jpg'},
    {'title': 'City Lights', 'artist': 'Nova', 'art': 'assets/images/music3.jpg'},
    {'title': 'Warm Breeze', 'artist': 'Maya', 'art': 'assets/images/music4.jpg'},
    {'title': 'Nightfall', 'artist': 'Rin', 'art': 'assets/images/music5.jpg'},
  ];
  int _selectedSongIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Responsive sizing using the actual device dimensions.
    // The user said the device is ~800 wide and 1260 tall — scale preview and thumbnails accordingly.
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    // Limit preview to a square that is at most the screen width and at most ~55% of screen height
    final previewHeight = math.min(screenW, screenH * 0.55);
    // Thumbnail size scales with width; make larger to match requested design
    final thumbSize = (screenW * 0.20).clamp(80.0, 200.0);
    // Scroller height sized to thumbnail + labels
    final scrollerHeight = thumbSize + 48.0;
    final Widget imageWidget = widget.imageBytes != null
        ? Image.memory(
            widget.imageBytes!,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (c, e, st) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
          )
        : (widget.assetPath != null)
            ? Image.asset(
                widget.assetPath!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, st) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
              )
            : widget.imageFile != null
                ? Image.file(
                    widget.imageFile!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, st) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
                  )
                : Container(color: Colors.grey[300], width: double.infinity, height: 300, child: const Center(child: Text('No image')));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.auto_awesome, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.brush, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.title, color: Colors.black)),
        ],
      ),
      body: Column(
        children: [
          // Top image area with bottom-left icon (square preview)
          SizedBox(
            height: previewHeight,
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(child: imageWidget),

                  // bottom-left icon on selected image
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.crop, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Horizontal music asset scroller with titles/artists
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  height: scrollerHeight,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: _songs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = _songs[index];
                      final selected = _selectedSongIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSongIndex = index;
                          });
                        },
                                        child: SizedBox(
                                          width: thumbSize,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Stack(
                                                  children: [
                                                    SizedBox(width: thumbSize, height: thumbSize, child: _loadAlbumArt(item['art']!)),
                                                    if (selected)
                                                      Positioned.fill(
                                                        child: Container(color: Colors.black26),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(item['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                              Text(item['artist'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.white,
        child: Row(
          children: [
            // Dark gray oval Edit button -> opens CreatePostScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Next -> open NewPostScreen with current image
                final imagePath = widget.assetPath ?? widget.imageFile?.path;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewPostScreen(
                      imagePath: imagePath,
                      imageBytes: widget.imageBytes,
                      imageFile: widget.imageFile,
                      autoShowShareSheet: true,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), backgroundColor: const Color(0xFF1677FF)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Next', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadAlbumArt(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.music_note, color: Colors.white70)),
      ),
    );
  }
}