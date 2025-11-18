// Edit filter screen — receives image bytes and shows preview
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:instagram/screens/new_post_screen.dart';

class EditFilterScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final dynamic imageFile;

  const EditFilterScreen({super.key, this.imageBytes, this.imageFile});

  @override
  State<EditFilterScreen> createState() => _EditFilterScreenState();
}

class _EditFilterScreenState extends State<EditFilterScreen> {
  final List<Map<String, String>> _audioSuggestions = [
    {'icon': 'music_note', 'title': 'Browse'},
    {'icon': 'piano', 'title': 'A day filled with...'},
    {'icon': 'album', 'title': '이웃집 토토로...'},
    {'icon': 'local_bar', 'title': 'If it\'s cute, that\'s it'},
    {'icon': 'book', 'title': '베짱이'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: Icon(Icons.edit_outlined), onPressed: () {}),
          IconButton(icon: Icon(Icons.audiotrack_outlined), onPressed: () {}),
          IconButton(icon: Icon(Icons.local_offer_outlined), onPressed: () {}),
          IconButton(icon: Icon(Icons.text_fields), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                  if (widget.imageBytes != null)
                    Image.memory(
                      widget.imageBytes!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    )
                  else if (widget.imageFile != null)
                    Image.file(
                      widget.imageFile,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    )
                  else
                    Center(child: Text('No image', style: TextStyle(color: Colors.white))),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.compare_arrows, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ),
                Positioned(
                  bottom: 16,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(Icons.music_note_outlined, size: 20),
                    label: Text('Add audio to your post'),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _audioSuggestions.length,
                    itemBuilder: (context, index) {
                      return _buildAudioTile(_audioSuggestions[index]);
                    },
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Edit'),
                        onPressed: () {},
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Next'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewPostScreen(
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

  Widget _buildAudioTile(Map<String, String> audio) {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            color: Colors.grey[800],
            child: Center(child: Icon(Icons.music_note, color: Colors.white)),
          ),
          const SizedBox(height: 4.0),
          Text(
            audio['title']!,
            style: TextStyle(color: Colors.white, fontSize: 12.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}