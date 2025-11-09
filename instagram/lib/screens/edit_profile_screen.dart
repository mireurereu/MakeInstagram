import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/name_edit_screen.dart';
import 'package:instagram/screens/bio_edit_screen.dart';

class EditProfileScreen extends StatefulWidget {
  // (신규) 1. 부모(ProfileScreen)로부터 초기 데이터를 받음
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

  // (수정) 2. 상태 변수들을 부모로부터 받은 'widget' 값으로 초기화
  late String _name;
  late String _bio;
  late String _avatarUrl; // (신규) 아바타 URL도 상태로 관리
  String? _newAvatarFile; // (신규) 새로 선택한 로컬 파일 경로

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _bio = widget.initialBio;
    _avatarUrl = widget.initialAvatarUrl;
  }

  // (수정) 갤러리/카메라 선택 시, _profileImage(File) 대신 _newAvatarFile(String)에 저장
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newAvatarFile = pickedFile.path;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _newAvatarFile = pickedFile.path;
      });
    }
  }

  // (수정) 'Done' 버튼 클릭 시, 변경된 데이터를 Map 형태로 반환
  void _onDonePressed() {
    // TODO: 이곳에서 Firebase/서버에 변경된 _name, _bio, _newAvatarFile을 업로드합니다.
    // 업로드가 완료되면, ProfileScreen이 갱신할 수 있도록 데이터를 반환합니다.

    // (임시) 만약 새 이미지가 선택되었다면, 임시로 로컬 파일 경로를 사용합니다.
    // (실제 앱에서는 Firebase Storage URL이어야 함)
    final String returnAvatarUrl = _newAvatarFile != null
        ? File(_newAvatarFile!).path // (임시)
        : _avatarUrl;

    Navigator.pop(context, {
      'name': _name,
      'bio': _bio,
      'avatarUrl': returnAvatarUrl, // (신규) 아바타 URL 반환
    });
  }

  // ... (_showPictureModal 함수는 이전과 동일) ...
  void _showPictureModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: _newAvatarFile != null
                        ? FileImage(File(_newAvatarFile!))
                        : NetworkImage(_avatarUrl) as ImageProvider,
                  ),
                  const SizedBox(width: 16.0),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person_outline,
                        color: Colors.black, size: 24.0),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey[300]),
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
                onTap: () { /* TODO */ },
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
                  setState(() {
                    _newAvatarFile = null;
                    // (임시) 기본 아바타로 변경
                    _avatarUrl = 'https://picsum.photos/seed/profile/200/200';
                  });
                  Navigator.pop(context);
                 },
              ),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  children: [
                    TextSpan(
                      text:
                          'Your profile picture and avatar are visible to everyone on and off Instagram. ',
                    ),
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

  // (동일) 'Name' 수정 화면으로 이동하는 함수
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

  // (동일) 'Bio' 수정 화면으로 이동하는 함수
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // 그냥 닫기 (데이터 반환 X)
        ),
        title: Text('Edit profile'),
        actions: [
          // (수정) 'Done' 버튼이 _onDonePressed 함수를 호출
          TextButton(
            onPressed: _onDonePressed,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showPictureModal(context),
                    child: CircleAvatar(
                      radius: 44,
                      // (수정) 새로 선택한 로컬 파일(_newAvatarFile) 또는 기존 URL(_avatarUrl) 표시
                      backgroundImage: _newAvatarFile != null
                          ? FileImage(File(_newAvatarFile!))
                          : NetworkImage(_avatarUrl) as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: () { /* ... */ },
                    child: CircleAvatar( /* ... */ ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showPictureModal(context),
                child: Text('Change profile picture',
                    style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _navigateToNameEdit,
                child: _buildTextRow('Name', _name), // _name 상태 변수 사용
              ),
              _buildTextRow('Username', 'ta_junhyuk'),
              _buildTextRow('Pronouns', ''),
              GestureDetector(
                onTap: _navigateToBioEdit,
                child: _buildTextRow('Bio', _bio), // _bio 상태 변수 사용
              ),
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

  // --- (헬퍼 함수들 - 전체 코드) ---
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
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Divider(color: Colors.grey[300], height: 1),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(String title,
      [String trailing = '', bool showTrailingText = false]) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title,
              style: TextStyle(color: Colors.black, fontSize: 16.0)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTrailingText)
                Text(trailing,
                    style: TextStyle(color: Colors.grey, fontSize: 16.0)),
              if (!showTrailingText && trailing.isNotEmpty)
                Text(trailing,
                    style: TextStyle(color: Colors.black, fontSize: 16.0)),
              const SizedBox(width: 8.0),
              Icon(Icons.chevron_right, color: Colors.black),
            ],
          ),
          onTap: () { /* TODO */ },
        ),
        Divider(color: Colors.grey[300], height: 1),
      ],
    );
  }

  Widget _buildLinkButton(String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: TextStyle(color: Colors.blue, fontSize: 16.0),
          ),
          onTap: () { /* TODO */ },
        ),
        Divider(color: Colors.grey[300], height: 1),
      ],
    );
  }
}