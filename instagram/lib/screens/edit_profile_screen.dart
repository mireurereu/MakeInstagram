import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // 1. 갤러리에서 선택
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // 2. 카메라로 촬영
  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // 3. (스크린샷 기준) 하단 모달 시트를 띄우는 함수
  void _showPictureModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // (라이트 모드) 배경색을 밝게 (기본값)
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 콘텐츠 높이만큼만
            children: [
              // 1. 모달 상단 손잡이
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400], // (라이트 모드)
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(height: 16.0),

              // 2. 프로필/아바타 아이콘 Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : NetworkImage(
                                'https://picsum.photos/seed/profile/200/200')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16.0),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200], // (라이트 모드)
                    child: Icon(Icons.person_outline,
                        color: Colors.black, size: 24.0),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey[300]), // (라이트 모드)

              // 3. 옵션 리스트
              ListTile(
                leading: Icon(Icons.image_outlined, color: Colors.black),
                title: Text('Choose from library',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.facebook, color: Colors.black),
                title: Text('Import from Facebook',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  /* TODO */
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: Colors.black),
                title: Text('Take photo',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title:
                    Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  /* TODO */
                },
              ),

              Divider(color: Colors.grey[300]), // (라이트 모드)

              // 4. 하단 안내 문구
              const SizedBox(height: 8.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  children: [
                    TextSpan(
                        text:
                            'Your profile picture and avatar are visible to everyone on and off Instagram. '),
                    TextSpan(
                      text: 'Learn more',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- (신규) 요청하신 `build` 함수 ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // (라이트 모드) 전역 테마(Colors.white)가 적용되므로 backgroundColor 삭제
      appBar: AppBar(
        // (라이트 모드) 전역 테마가 적용되므로 스타일링 삭제
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 변경사항 저장 로직
              Navigator.pop(context);
            },
            child: Text('Done',
                style: TextStyle(color: Colors.blue, fontSize: 16.0)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              // --- 프로필 사진/아바타 Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // (요청사항) 1. 왼쪽 이미지 (GestureDetector로 감쌈)
                  GestureDetector(
                    onTap: () => _showPictureModal(context), // 모달 호출
                    child: CircleAvatar(
                      radius: 44,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : NetworkImage(
                                  'https://picsum.photos/seed/profile/200/200')
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // 2. 오른쪽 아바타
                  GestureDetector(
                    onTap: () {
                      /* TODO: 아바타 설정 화면 */
                    },
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.grey[200], // (라이트 모드)
                      child: Icon(Icons.shield_outlined,
                          color: Colors.black, size: 40.0), // (라이트 모드)
                    ),
                  ),
                ],
              ),
              // (요청사항) 2. 텍스트 버튼
              TextButton(
                onPressed: () => _showPictureModal(context), // 모달 호출
                child: Text('Change profile picture',
                    style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 16.0),

              // --- 이하 헬퍼 함수 호출 ---
              _buildTextRow('Name', 'puang'),
              _buildTextRow('Username', 'ta_junhyuk'),
              _buildTextRow('Pronouns', ''),
              _buildTextRow('Bio', 'I\'m gonna be the God of Flutter!'),
              _buildNavigationRow('Add link'),
              _buildNavigationRow('Add banners'),
              _buildNavigationRow('Gender', 'Prefer not to say'),
        _buildNavigationRow('Music', 'Add music to your profile', true),
              const SizedBox(height: 16.0),
              _buildLinkButton('Switch to professional account'),
              _buildLinkButton('Personal information settings'),
            ],
          ),
        ),
      ),
    );
  }

  // --- (헬퍼 함수) 'Name', 'Bio' 등을 위한 Row ---
  Widget _buildTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12.0)),
          const SizedBox(height: 4.0),
          Text(
            value.isEmpty ? '' : value,
            style: TextStyle(color: Colors.black, fontSize: 16.0), // (라이트 모드)
          ),
          const SizedBox(height: 8.0),
          Divider(color: Colors.grey[300], height: 1), // (라이트 모드)
        ],
      ),
    );
  }

  // --- (헬퍼 함수) 'Gender', 'Music' 등을 위한 Row ---
  Widget _buildNavigationRow(String title,
      [String trailing = '', bool showTrailingText = false]) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title,
              style: TextStyle(color: Colors.black, fontSize: 16.0)), // (라이트 모드)
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTrailingText)
                Text(trailing,
                    style: TextStyle(color: Colors.grey, fontSize: 16.0)),
              if (!showTrailingText && trailing.isNotEmpty)
                Text(trailing,
                    style: TextStyle(color: Colors.black, fontSize: 16.0)), // (라이트 모드)
              const SizedBox(width: 8.0),
              Icon(Icons.chevron_right, color: Colors.black), // (라이트 모드)
            ],
          ),
          onTap: () {
            // TODO
          },
        ),
        Divider(color: Colors.grey[300], height: 1), // (라이트 모드)
      ],
    );
  }

  // --- (헬퍼 함수) 하단 파란색 링크 버튼 ---
  Widget _buildLinkButton(String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: TextStyle(color: Colors.blue, fontSize: 16.0),
          ),
          onTap: () {
            // TODO
          },
        ),
        Divider(color: Colors.grey[300], height: 1), // (라이트 모드)
      ],
    );
  }
}