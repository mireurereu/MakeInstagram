import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/name_edit_screen.dart';
import 'package:instagram/screens/bio_edit_screen.dart';
import 'package:instagram/data/user_state.dart';

class EditProfileScreen extends StatefulWidget {
  // 1. ProfileScreen으로부터 초기 데이터를 받음
  final String initialName;
  final String initialBio;
  final String initialAvatarUrl;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialBio,
    required this.initialAvatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  // 2. 상태 변수들을 부모로부터 받은 'widget' 값으로 초기화
  late String _name;
  late String _bio;
  late String _avatarUrl;
  String? _newAvatarFile; // 새로 선택한 로컬 파일 경로
  String _gender = 'Prefer not to say';
  bool _hasChangedProfilePicture = false; // 프로필 사진 변경 여부 추적
  int _selectedAvatarIndex = 0; // 0: 프로필 사진, 1: 아바타

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _bio = widget.initialBio;
    _avatarUrl = widget.initialAvatarUrl;
    
    // UserState에서 프로필 사진 변경 여부 가져오기
    _hasChangedProfilePicture = UserState.hasChangedProfilePicture();

    // 3. (핵심) 화면이 그려진 직후 '아바타 만들기' 팝업을 띄웁니다.
    // (임시로 주석 처리 - avatar.jpg 파일이 없으면 오류 발생)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showAvatarDialog(context);
    // });
  }

  // 4. (신규) '아바타 만들기' 팝업 함수
  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 밖을 탭해도 닫히지 않음
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          insetPadding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 120.0), // 다이얼로그 폭 더 좁게, 세로 길게
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // (임시) 스크린샷의 아바타 그룹 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/avatar.jpg',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Create your avatar',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0),
                Text(
                  'Get your own personalized stickers to share in stories and chats.',
                  style: TextStyle(fontSize: 13.0, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                Divider(color: Colors.grey[300], height: 1), // 위쪽 선
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // 팝업 닫기
                    },
                    child: Text('Create avatar', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
                  ),
                ),
                Divider(color: Colors.grey[300], height: 1), // 아래쪽 선
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // 팝업 닫기
                    },
                    child: Text('Not now', style: TextStyle(fontSize: 16.0)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 5. 'Done' 버튼 클릭 시, 변경된 데이터를 Map 형태로 부모(ProfileScreen)에게 반환
  void _onDonePressed() {
    // TODO: 이곳에서 Firebase/서버에 변경된 _name, _bio, _newAvatarFile을 업로드합니다.
    final String returnAvatarUrl =
        _newAvatarFile != null ? File(_newAvatarFile!).path : _avatarUrl;

    Navigator.pop(context, {
      'name': _name,
      'bio': _bio,
      'avatarUrl': returnAvatarUrl,
      'gender': _gender,
    });
  }
  
  ImageProvider _getImageProvider() {
    if (_newAvatarFile != null) {
      return FileImage(File(_newAvatarFile!));
    } else if (_avatarUrl.startsWith('http')) {
      return NetworkImage(_avatarUrl);
    } else if (_avatarUrl.startsWith('assets/')) {
      return AssetImage(_avatarUrl);
    } else {
      return FileImage(File(_avatarUrl));
    }
  }

  // 6. 갤러리/카메라 관련 함수들
  Future<void> _pickImageFromGallery() async {
    // 1. 갤러리 선택 화면으로 이동
    final selectedImage = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => _GalleryPickerScreen(),
      ),
    );
    
    if (selectedImage != null) {
      // 2. 갤러리 화면 닫힘 (이미 자동으로 닫힘)
      
      // 3. 잠시 대기
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (!mounted) return;
      
      // 4. "Loading..." 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                ),
                SizedBox(width: 12),
                Text('Loading...', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
      
      // Loading 표시 시간
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (!mounted) return;
      
      // Loading 다이얼로그 닫기
      Navigator.pop(context);
      
      // 6. Edit Profile 화면 닫힘 & 프로필 사진 업데이트 & Profile 화면으로 복귀
      final String returnAvatarUrl = selectedImage;
      
      Navigator.pop(context, {
        'name': _name,
        'bio': _bio,
        'avatarUrl': returnAvatarUrl,
        'gender': _gender,
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _newAvatarFile = pickedFile.path;
        _hasChangedProfilePicture = true;
      });
    }
  }

  // 7. (스크린샷 반영) 프로필 사진 변경 모달
  void _showPictureModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarIndex = 0;
                      });
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: _getImageProvider(),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarIndex = 1;
                      });
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person_outline,
                          color: Colors.black, size: 24.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // 슬라이드 인디케이터 바와 구분선을 겹치게 배치
              Stack(
                children: [
                  // 하단 구분선
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  // 인디케이터 바들 - 프로필 사진 아래 위치
                  Positioned(
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 2,
                          decoration: BoxDecoration(
                            color: _selectedAvatarIndex == 0 ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Container(
                          width: 48,
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.image_outlined, color: Colors.black),
                title: Text('Choose from library',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.facebook, color: Colors.black),
                title: Text('Import from Facebook',
                    style: TextStyle(color: Colors.black)),
                onTap: () { /* TODO */ },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.camera_alt_outlined, color: Colors.black),
                title:
                    Text('Take photo', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    _newAvatarFile = null;
                    _avatarUrl = 'assets/images/profile3.jpg'; // 기본 이미지로
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                    children: [
                      TextSpan(
                          text:
                              'Your profile picture and avatar are visible to everyone on and off Instagram. '),
                      TextSpan(
                        text: '\nLearn more',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 8. 'Name' / 'Bio' 수정 화면으로 이동하는 함수들
  void _navigateToNameEdit() async {
    final newName = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NameEditScreen(initialName: _name),
      ),
    );
    if (newName != null && newName != _name) {
      setState(() {
        _name = newName;
      });
    }
  }

  void _navigateToBioEdit() async {
    final newBio = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BioEditScreen(initialBio: _bio),
      ),
    );
    if (newBio != null && newBio != _bio) {
      setState(() {
        _bio = newBio;
      });
    }
  }

  void _navigateToGenderEdit() async {
    // TODO: 'GenderEditScreen'을 새로 만드신 후, 아래 주석을 해제하세요.
    // Name/Bio와 동일한 패턴으로 값을 받아오면 됩니다.
    
    // final newGender = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => GenderEditScreen(initialGender: _gender),
    //   ),
    // );
    // if (newGender != null && newGender != _gender) {
    //   setState(() {
    //     _gender = newGender;
    //   });
    // }
    
    // (임시) 탭 기능만 확인
    print('Navigate to Gender Edit Screen');
  }

  // 9. (핵심) 실제 UI를 그리는 build 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 라이트 모드 배경
      
      // 1. (수정) AppBar (화살표 아이콘)
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 'X' -> '←'
          onPressed: _onDonePressed,
        ),
        title: Text('Edit profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [],
      ),
      
      // 2. (수정) Body (Padding 구조 및 필드 UI)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아바타, 텍스트 필드 등을 별도 Padding으로 묶기
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  // (상단 아바타 섹션)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showPictureModal(context),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundImage: _getImageProvider(),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      GestureDetector(
                        onTap: () { /* TODO: 아바타 설정 */ },
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.shield_outlined,
                              color: Colors.black, size: 40.0),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => _showPictureModal(context),
                      child: Text('Change profile picture',
                          style: TextStyle(color: Colors.blue, fontSize: 14.0)),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // (수정된 필드 호출)
                  _buildTextRow('Name', _name, onTap: _navigateToNameEdit),
                  _buildTextRow('Username', 'ta_junhyuk'),
                  _buildTextRow('Pronouns', ''),
                  _buildTextRow('Bio', _bio, onTap: _navigateToBioEdit),
                  
                  _buildSimpleRow('Add link', showDivider: false),
                  _buildSimpleRow('Add banners', showDivider: false),

                  _buildTextRow(
                    'Gender',
                    _gender,
                    onTap: _navigateToGenderEdit,
                    showArrow: true, // 화살표 표시
                    // showDivider: true (기본값)
                  ),
                  
                  _buildNavigationRow('Music', 'Add music to your profile'),

                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            
            // (수정) LinkButton들을 Padding 밖으로 이동 (구분선이 꽉 차도록)
            _buildLinkButton('Switch to professional account'),
            _buildLinkButton('Personal information settings'),
            if (_hasChangedProfilePicture)
              _buildLinkButton('Show your profile is verified'),
            
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  // 10. (헬퍼 함수들 - 라이트 모드 적용)
  Widget _buildTextRow(
    String label,
    String value, {
    VoidCallback? onTap,
    bool showDivider = true, // 1. 구분선 표시 여부
    bool showArrow = false,  // 2. 화살표 표시 여부 (Gender용)
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row로 텍스트와 화살표를 묶음
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Column으로 레이블과 값을 묶음
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12.0)),
                      const SizedBox(height: 4.0),
                      Text(
                        value.isEmpty ? ' ' : value,
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // (신규) 화살표가 true일 때만 아이콘 표시
                if (showArrow)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.chevron_right, color: Colors.grey[600], size: 20.0),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            // (신규) 구분선이 true일 때만 표시
            if (showDivider)
              Divider(color: Colors.grey[300], height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleRow(String title, {bool showDivider = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: TextStyle(color: Colors.black, fontSize: 16.0)),
          onTap: () { /* TODO */ },
        ),
        if (showDivider) // (수정)
          Divider(color: Colors.grey[300], height: 1),
      ],
    );
  }

  Widget _buildNavigationRow(String title, String trailingText, {bool showDivider = true}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title,
              style: TextStyle(color: Colors.black, fontSize: 16.0)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(trailingText,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16.0)), // (수정) 항상 회색
              const SizedBox(width: 8.0),
              Icon(Icons.chevron_right, color: Colors.grey[600], size: 20.0), // (수정)
            ],
          ),
          onTap: () { /* TODO */ },
        ),
        if (showDivider)
          Divider(color: Colors.grey[300], height: 1),
      ],
    );
  }

  Widget _buildLinkButton(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey[300], height: 1),
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // 좌우 패딩 추가
          title: Text(
            title,
            style: TextStyle(color: Colors.blue, fontSize: 16.0),
          ),
          onTap: () { /* TODO */ },
        ),
        // (수정) 마지막 버튼 뒤에만 구분선 추가
        if (title == 'Personal information settings')
           Divider(color: Colors.grey[300], height: 1),
      ],
    );
  }
}

// 갤러리 선택 화면
class _GalleryPickerScreen extends StatefulWidget {
  const _GalleryPickerScreen({Key? key}) : super(key: key);

  @override
  State<_GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<_GalleryPickerScreen> {
  final List<String> _images = List.generate(8, (index) => 'assets/images/post${index + 1}.jpg');
  String? _selectedImage;
  late PageController _previewPageController;
  bool _isProcessing = false;

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

  Future<void> _onDonePressed() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Processing 효과를 위한 딜레이
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.pop(context, _selectedImage);
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
            onPressed: _selectedImage != null ? _onDonePressed : null,
            child: const Text('Done', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 선택된 이미지 프리뷰 (정사각형)
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: PageView.builder(
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
                        fit: _isProcessing ? BoxFit.contain : BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                      );
                    },
                  ),
                ),
              ),
              // 그리드
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final imagePath = _images[index];
                    final bool isSelected = _selectedImage == imagePath;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = imagePath;
                        });
                        _previewPageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                          ),
                          if (isSelected) Container(color: Colors.white.withOpacity(0.35)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Processing 오버레이
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Processing...', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}