import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. (신규) rootBundle 사용을 위해 추가
import 'package:instagram/screens/edit_filter_screen.dart';
// import 'package:photo_manager/photo_manager.dart'; // (삭제) 갤러리 패키지 미사용

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  
  // 2. (수정) AssetEntity 대신 String(이미지 경로) 리스트 사용
  // TODO: 실제 assets/images 폴더에 있는 파일명으로 수정해주세요!
  final List<String> _assetImages = [
    'assets/images/sample1.jpg',
    'assets/images/sample2.jpg',
    'assets/images/sample3.jpg',
    'assets/images/sample4.jpg',
    // 필요한 만큼 추가...
  ];

  String? _selectedAssetPath; // 선택된 이미지 경로
  bool _isLoading = false; // 에셋은 바로 로드되므로 로딩 불필요

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 초기값: 첫 번째 이미지 선택
    if (_assetImages.isNotEmpty) {
      _selectedAssetPath = _assetImages.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 3. (수정) 'Next' 버튼 클릭 시 (Asset 경로 -> Byte 변환)
  void _goToEditScreen() async {
    if (_selectedAssetPath == null) return;

    try {
      // 3-1. rootBundle을 사용해 에셋 파일을 ByteData로 로드
      final ByteData byteData = await rootBundle.load(_selectedAssetPath!);
      final Uint8List imageBytes = byteData.buffer.asUint8List();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          // 3-2. 변환된 bytes를 다음 화면으로 전달
          builder: (context) => EditFilterScreen(imageBytes: imageBytes),
        ),
      );
    } catch (e) {
      debugPrint('Error loading asset image: $e');
    }
  }

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
        title: Row(
          children: [
            Text('Gallery', style: TextStyle(fontWeight: FontWeight.bold)), // Recents -> Gallery
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _selectedAssetPath != null ? _goToEditScreen : null,
            child: Text(
              'Next',
              style: TextStyle(
                color: _selectedAssetPath != null ? Colors.blue : Colors.grey,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 4. 상단 미리보기 영역
          _buildPreviewArea(),

          // 5. 하단 탭 및 그리드
          _buildGalleryTabs(),
        ],
      ),
    );
  }

  // 상단 미리보기 (Image.asset 사용)
  Widget _buildPreviewArea() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width, // 1:1 비율
      color: Colors.grey[900],
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          _selectedAssetPath == null
              ? Center(child: Text('No image selected', style: TextStyle(color: Colors.white)))
              : Center(
                  // (수정) AssetEntityImage -> Image.asset
                  child: Image.asset(
                    _selectedAssetPath!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.copy, color: Colors.white, size: 16.0),
                  SizedBox(width: 4.0),
                  Text(
                    'SELECT MULTIPLE',
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.zoom_out_map, color: Colors.white, size: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTabs() {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 1.0,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'GALLERY'),
              Tab(text: 'PHOTO'),
              Tab(text: 'VIDEO'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // GALLERY 탭: 로컬 에셋 그리드
                _buildGalleryGrid(),

                Center(child: Icon(Icons.camera_alt, color: Colors.white, size: 60)),
                Center(child: Icon(Icons.videocam, color: Colors.white, size: 60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 그리드 (Image.asset 사용)
  Widget _buildGalleryGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _assetImages.length,
      itemBuilder: (context, index) {
        final String assetPath = _assetImages[index];
        final bool isSelected = _selectedAssetPath == assetPath;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAssetPath = assetPath;
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // (수정) AssetEntityImage -> Image.asset
              Image.asset(
                assetPath,
                fit: BoxFit.cover,
              ),
              
              // 선택 효과
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    border: Border.all(color: Colors.blue, width: 3.0),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}