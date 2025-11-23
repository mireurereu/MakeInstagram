// Music & Sticker edit screen — receives image bytes or image file and shows preview
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'new_post_screen.dart';

class EditFilterScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final File? imageFile;
  final String? assetPath;

  const EditFilterScreen({super.key, this.imageBytes, this.imageFile, this.assetPath});

  @override
  State<EditFilterScreen> createState() => _EditFilterScreenState();
}

class _EditFilterScreenState extends State<EditFilterScreen> {
  final List<String> _thumbnails = List.generate(8, (i) => 'assets/images/post${(i % 4) + 1}.jpg');

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = widget.imageBytes != null
      ? Image.memory(widget.imageBytes!, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[300]))
      : (widget.assetPath != null)
        ? Image.asset(widget.assetPath!, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[300]))
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
          IconButton(icon: const Icon(Icons.crop_free_outlined, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.auto_awesome_motion_outlined, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.collections_outlined, color: Colors.black), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Top image area
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(child: imageWidget),

                // bottom-left circular icon (example)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                    child: const Icon(Icons.crop_free, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Bottom thumbnails and controls
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Column(
              children: [
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _thumbnails.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                                child: const Center(child: Icon(Icons.photo_library_outlined, size: 28)),
                              ),
                              const SizedBox(height: 6),
                              const SizedBox(width: 80, child: Text('Browse', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
                            ],
                          ),
                        );
                      }

                      final thumb = _thumbnails[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(thumb, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[200], width: 80, height: 80)),
                            ),
                            const SizedBox(height: 6),
                            const SizedBox(width: 80, child: Text(' ', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black),
                        child: const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: Text('Edit')),
                        onPressed: () {},
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3797EF)),
                        child: const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: Text('Next', style: TextStyle(color: Colors.white))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewPostScreen(
                                imagePath: widget.assetPath,
                                imageBytes: widget.imageBytes,
                                imageFile: widget.imageFile,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // helper methods removed; this screen only handles visual layout similar to the provided mock
}