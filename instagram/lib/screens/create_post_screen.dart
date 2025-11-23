import 'package:flutter/material.dart';
import 'package:instagram/screens/edit_filter_screen.dart';

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
  
  @override
  void initState() {
    super.initState();
    if (_images.isNotEmpty) _selectedImage = _images[0];
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
                onPressed: _selectedImage != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditFilterScreen(assetPath: _selectedImage!),
                          ),
                        );
                      }
                    : null,
                child: const Text('Next', style: TextStyle(color: Color(0xFF3797EF), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
        ],
      ),
      body: Column(
        children: [
          // 선택된 이미지 프리뷰
          Container(
            height: 375, // 정사각형 비율 
            width: double.infinity,
            color: Colors.grey[200],
            child: _selectedImage != null
                ? Image.asset(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48)),
                    ),
                  )
                : const Center(child: Text('Select an image')),
          ),
          // 그리드
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final imagePath = _images[index];
                final isSelected = _selectedImage == imagePath;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedImage = imagePath),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                      ),
                      if (isSelected) Container(color: Colors.white.withOpacity(0.5)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text('GALLERY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            Text('PHOTO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Text('VIDEO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}