import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/name_edit_screen.dart';
import 'package:instagram/screens/bio_edit_screen.dart';

class EditProfileScreen extends StatefulWidget {
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
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  late String _name;
  late String _bio;
  late String _avatarUrl;
  String? _newAvatarFile;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _bio = widget.initialBio;
    _avatarUrl = widget.initialAvatarUrl;

    // --- (신규) 화면이 그려진 직후 '아바타 만들기' 팝업을 띄웁니다. ---
    // (임시) 이 팝업을 한번만 띄우기 위한 로직이 필요하지만,
    // 일단은 영상처럼 Edit profile에 진입할 때마다 띄웁니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAvatarDialog(context);
    });
    // --- --- ---
  }

  // --- (신규) '아바타 만들기' 팝업 함수 ---
  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 밖을 탭해도 닫히지 않음
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. (임시) 스크린샷의 아바타 그룹 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'https://placehold.co/250x120/EFEFEF/000000?text=Avatars',
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 24.0),
                // 2. 제목
                Text(
                  'Create your avatar',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                // 3. 설명
                Text(
                  'Get your own personalized stickers to share in stories and chats.',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),
                
                // 4. 'Create avatar' 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () {
                      // TODO: Navigate to avatar creation flow
                      Navigator.pop(context); // 팝업 닫기
                    },
                    child: Text('Create avatar'),
                  ),
                ),
                SizedBox(height: 8.0),
                
                // 5. 'Not now' 버튼
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 팝업 닫기
                  },
                  child: Text(
                    'Not now',
                    style: TextStyle(color: Colors.blue, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // --- --- ---

  // ... (이하 _pickImageFromGallery, _pickImageFromCamera, _showPictureModal,
  //      _navigateToNameEdit, _navigateToBioEdit 함수는 이전과 동일합니다.) ...

  @override
  Widget build(BuildContext context) {
    // ... (build 메서드는 이전과 동일합니다.) ...
    return Scaffold(
      appBar: AppBar( /* ... */ ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [ /* ... (이전과 동일한 UI 구성) ... */ ],
          ),
        ),
      ),
    );
  }

  // ... (이하 _buildTextRow, _buildNavigationRow, _buildLinkButton 헬퍼 함수들은
  //      이전과 동일합니다.) ...
}