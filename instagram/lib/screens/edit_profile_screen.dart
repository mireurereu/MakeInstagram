import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/name_edit_screen.dart';
import 'package:instagram/screens/bio_edit_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _bio = widget.initialBio;
    _avatarUrl = widget.initialAvatarUrl;

    // 3. (핵심) 화면이 그려진 직후 '아바타 만들기' 팝업을 띄웁니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // (임시) 이 팝업을 한번만 띄우기 위한 로직(SharedPreferences 등)이
      // 필요하지만, 일단은 영상처럼 Edit profile에 진입할 때마다 띄웁니다.
      _showAvatarDialog(context);
    });
  }

  // 4. (신규) '아바타 만들기' 팝업 함수
  void _showAvatarDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 밖을 탭해도 닫히지 않음
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // (임시) 스크린샷의 아바타 그룹 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'https://placehold.co/250x120/EFEFEF/000000?text=Avatars',
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 24.0),
                Text(
                  'Create your avatar',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Get your own personalized stickers to share in stories and chats.',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),
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
                      Navigator.pop(context); // 팝업 닫기
                    },
                    child: Text('Create avatar'),
                  ),
                ),
                SizedBox(height: 8.0),
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

  // 5. 'Done' 버튼 클릭 시, 변경된 데이터를 Map 형태로 부모(ProfileScreen)에게 반환
  void _onDonePressed() {
    // TODO: 이곳에서 Firebase/서버에 변경된 _name, _bio, _newAvatarFile을 업로드합니다.
    final String returnAvatarUrl =
        _newAvatarFile != null ? File(_newAvatarFile!).path : _avatarUrl;

    Navigator.pop(context, {
      'name': _name,
      'bio': _bio,
      'avatarUrl': returnAvatarUrl,
    });
  }

  // 6. 갤러리/카메라 관련 함수들
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

  // 7. (스크린샷 반영) 프로필 사진 변경 모달
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
                title:
                    Text('Take photo', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    _newAvatarFile = null;
                    _avatarUrl =
                        'https://picsum.photos/seed/default/200/200'; // 기본 이미지로
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

  // 9. (핵심) 실제 UI를 그리는 build 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // 데이터 반환 없이 닫기
        ),
        title: Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: _onDonePressed, // 'Done' 누르면 데이터 반환
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
                      backgroundImage: _newAvatarFile != null
                          ? FileImage(File(_newAvatarFile!))
                          : NetworkImage(_avatarUrl) as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: () { /* TODO: 아바타 설정 화면 */ },
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.grey[200], // 라이트 모드
                      child: Icon(Icons.shield_outlined,
                          color: Colors.black, size: 40.0), // 라이트 모드
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showPictureModal(context),
                child: Text('Change profile picture',
                    style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 16.0),

              // Name, Bio 등이 탭 가능하도록 설정
              GestureDetector(
                onTap: _navigateToNameEdit,
                child: _buildTextRow('Name', _name),
              ),
              _buildTextRow('Username', 'ta_junhyuk'),
              _buildTextRow('Pronouns', ''),
              GestureDetector(
                onTap: _navigateToBioEdit,
                child: _buildTextRow('Bio', _bio),
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

  // 10. (헬퍼 함수들 - 라이트 모드 적용)
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