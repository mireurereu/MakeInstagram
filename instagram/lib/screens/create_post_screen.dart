import 'package:flutter/material.dart';
import 'package:instagram/screens/edit_post_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  // [설정] assets/images/ 폴더에 있는 파일명과 일치해야 함
  // 실제 프로젝트에는 post1..post8 까지 존재하므로 안전하게 8개만 생성합니다.
  final List<String> _images = List.generate(8, (index) => 'assets/images/post${index + 1}.jpg');
  
  String? _selectedImage;
  // multi-select support
  bool _selectMultipleMode = false;
  final List<String> _selectedImages = [];
  late PageController _previewPageController;
  bool _showingFullImage = false;
  
  @override
  void initState() {
    super.initState();
    if (_images.isNotEmpty) _selectedImage = _images[0];
    final initialIndex = _selectedImage != null ? _images.indexOf(_selectedImage!) : 0;
    _previewPageController = PageController(initialPage: initialIndex >= 0 ? initialIndex : 0);
  }

  @override
  void dispose() {
    _previewPageController.dispose();
    super.dispose();
  }

  Future<void> _onNextPressed() async {
    final toEdit = _selectedImages.isNotEmpty ? _selectedImages.last : _selectedImage!;
    
    setState(() {
      _showingFullImage = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(assetPath: toEdit),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _showingFullImage = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            Text('Recents', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
        actions: [
          TextButton(
            onPressed: (_selectedImage != null || _selectedImages.isNotEmpty)
                ? _onNextPressed
                : null,
            child: const Text('Next', style: TextStyle(color: Color.fromARGB(255, 110, 35, 142), fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 선택된 이미지 프리뷰
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Stack(children: [
                // Scrollable preview using PageView. Shows all images; when selection changes we jump to that page.
                PageView.builder(
                  controller: _previewPageController,
                  itemCount: _images.length,
                  onPageChanged: (i) {
                    setState(() {
                      _selectedImage = _images[i];
                    });
                  },
                  itemBuilder: (context, i) {
                    final imagePath = _images[i];
                    return Image.asset(
                      imagePath,
                      fit: _showingFullImage ? BoxFit.contain : BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                    );
                  },
                ),

                // left icon (crop/rotate placeholder)
                Positioned(left: 12, bottom: 12, child: Container(decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.all(8), child: const Icon(Icons.crop, color: Colors.white))),

                // Select Multiple toggle on preview (bottom-right dark pill)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectMultipleMode = !_selectMultipleMode;
                        if (!_selectMultipleMode && _selectedImages.isNotEmpty) {
                          // when turning off, keep only last selection
                          _selectedImage = _selectedImages.last;
                          _selectedImages.clear();
                          // jump preview to the remaining single image
                          final idx = _images.indexOf(_selectedImage!);
                          if (idx >= 0) _previewPageController.jumpToPage(idx);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectMultipleMode ? Colors.black87 : Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_box, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text('SELECT MULTIPLE', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          // 그리드
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                childAspectRatio: 1.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final imagePath = _images[index];
                final bool isSelectedSingle = _selectedImage == imagePath;
                final int multiIndex = _selectedImages.indexOf(imagePath);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectMultipleMode) {
                        if (_selectedImages.contains(imagePath)) {
                          _selectedImages.remove(imagePath);
                        } else {
                          _selectedImages.add(imagePath);
                        }
                      } else {
                        _selectedImage = imagePath;
                        _selectedImages.clear();
                      }
                    });

                    // animate preview to tapped image
                    try {
                      _previewPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } catch (_) {}
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                      ),
                      if (!_selectMultipleMode && isSelectedSingle) Container(color: Colors.white.withOpacity(0.35)),
                      if (_selectMultipleMode && multiIndex != -1)
                        Positioned(right: 6, top: 6, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF3797EF), shape: BoxShape.circle), child: Text('${multiIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.white,
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('GALLERY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  Text('PHOTO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text('VIDEO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              child: Container(
                height: 3,
                width: MediaQuery.of(context).size.width / 3,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}