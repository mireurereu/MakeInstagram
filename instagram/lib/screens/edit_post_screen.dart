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
    {'title': 'Blue Moon', 'artist': 'Aurora', 'art': 'assets/images/musics/music1.jpg'},
    {'title': 'Sunset Ride', 'artist': 'Kaito', 'art': 'assets/images/musics/music2.jpg'},
    {'title': 'City Lights', 'artist': 'Nova', 'art': 'assets/images/musics/music3.jpg'},
    {'title': 'Warm Breeze', 'artist': 'Maya', 'art': 'assets/images/musics/music4.jpg'},
    {'title': 'Nightfall', 'artist': 'Rin', 'art': 'assets/images/musics/music5.jpg'},
  ];
  int _selectedSongIndex = -1;
  
  // [수정] 툴팁 단계를 관리하는 변수 (0: 없음, 1: 오디오 툴팁, 2: 필터 툴팁)
  int _tooltipStep = 0;

  @override
  void initState() {
    super.initState();
    // [수정] 툴팁 시퀀스 로직
    // 1초 후 오디오 툴팁 표시
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _tooltipStep = 1;
        });
        // 2초 후 오디오 툴팁 숨기고 필터 툴팁 표시
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _tooltipStep = 2;
            });
            // 2초 후 필터 툴팁 숨김
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                setState(() {
                  _tooltipStep = 0;
                });
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final previewHeight = math.min(screenW, screenH * 0.55);
    final thumbSize = (screenW * 0.20).clamp(80.0, 200.0);
    final scrollerHeight = thumbSize + 48.0;
    
    final Widget imageWidget = widget.imageBytes != null
        ? Image.memory(
            widget.imageBytes!,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (c, e, st) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
          )
        : (widget.assetPath != null)
            ? Image.asset(
                widget.assetPath!,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (c, e, st) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
              )
            : widget.imageFile != null
                ? Image.file(
                    widget.imageFile!,
                    width: double.infinity,
                    fit: BoxFit.contain,
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.brush, color: Colors.black)), // 2번째 아이콘
          IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.title, color: Colors.black)),
        ],
      ),
      // [수정] Stack으로 감싸서 앱바 아래 툴팁 표시 가능하게 함
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: previewHeight,
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      Positioned.fill(child: imageWidget),
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
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                      Text(item['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      Text(item['artist'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // [수정] 오디오 툴팁 (Step 1일 때만 표시)
                        if (_tooltipStep == 1)
                          Positioned(
                            top: -42,
                            left: 12 + (thumbSize + 12) * 1 + thumbSize / 2 - 80,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 2),
                                    ],
                                  ),
                                  child: const Text(
                                    'Add audio to your post',
                                    style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                  ),
                                ),
                                CustomPaint(
                                  size: const Size(16, 6),
                                  painter: _TooltipTrianglePainter(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // [추가] 필터 툴팁 (Step 2일 때 표시, 앱바 2번째 아이콘 아래)
          if (_tooltipStep == 2) ...[
             // 1. 위쪽을 가리키는 삼각형 (브러쉬 아이콘 중앙에 맞춤)
             // 오른쪽에서 128px 위치가 브러쉬 아이콘의 중앙과 대략 일치합니다.
            Positioned(
              top: 0,
              right: 128, 
              child: CustomPaint(
                size: const Size(16, 6),
                painter: _TooltipTrianglePainterUp(),
              ),
            ),
            // 2. 텍스트 컨테이너 (삼각형 아래에 위치하며, 아이콘을 기준으로 중앙 정렬)
            Positioned(
              top: 6, // 삼각형 높이(6)만큼 아래로 내림
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter, // 우선 화면 중앙에 배치
                child: Transform.translate(
                  // 화면 중앙에서 브러쉬 아이콘 위치(오른쪽에서 약 136px 지점)로 이동
                  // 수식: (화면너비 / 2) - 136
                  offset: Offset(screenW / 2 - 136, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 2),
                      ],
                    ),
                    child: const Text(
                      'Add a filter to your post',
                      style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.white,
        child: Row(
          children: [
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
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), backgroundColor: const Color.fromARGB(255, 40, 59, 204)),
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

// 기존 삼각형 (아래쪽을 가리킴)
class _TooltipTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height); 
    path.lineTo(0, 0); 
    path.lineTo(size.width, 0); 
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.25), 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// [추가] 위쪽을 가리키는 삼각형 Painter
class _TooltipTrianglePainterUp extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // 뾰족한 부분이 위쪽
    path.lineTo(0, size.height); 
    path.lineTo(size.width, size.height); 
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.25), 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}