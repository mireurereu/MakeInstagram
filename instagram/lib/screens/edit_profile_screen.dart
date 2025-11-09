// lib/screens/edit_profile_screen.dart

import 'dart.io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage; // (영상 3:39) 새로 선택된 프로필 이미지
  final ImagePicker _picker = ImagePicker();

  // (영상 3:39) 갤러리에서 프로필 사진 변경
  Future<void> _changeProfilePic() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // (영상 4:26) 완료 버튼
          TextButton(
            onPressed: () {
              // TODO: 변경사항 저장 로직
              Navigator.pop(context); // 프로필 화면으로 복귀
            },
            child: Text('Done', style: TextStyle(color: Colors.blue, fontSize: 16.0)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // (영상 3:34) 프로필 사진 변경
              CircleAvatar(
                radius: 44,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!) // 새로 선택한 이미지
                    : NetworkImage('https://picsum.photos/seed/profile/200/200') as ImageProvider,
              ),
              TextButton(
                onPressed: _changeProfilePic,
                child: Text('Change profile picture', style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 16.0),
              // (영상 3:55) Name
              _buildTextField('Name', 'puang!'),
              // (영상 4:09) Username
              _buildTextField('Username', 'ta_junhyuk'),
              // (영상 4:15) Bio
              _buildTextField('Bio', 'I\'m gonna be the God of Flutter!!!'),
            ],
          ),
        ),
      ),
    );
  }

  // 이름, 바이오 등을 수정하기 위한 텍스트 필드 위젯
  Widget _buildTextField(String label, String initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12.0)),
          TextFormField(
            initialValue: initialValue,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}