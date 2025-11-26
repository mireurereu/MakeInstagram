import 'package:flutter/material.dart';
import 'package:instagram/screens/create_post_screen.dart';

class CreateBottomSheet extends StatelessWidget {
  const CreateBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Create',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey[200]),
          _buildOption(
            context,
            icon: Icons.movie_outlined,
            title: 'Reel',
            onTap: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(left: 56, right: 16),
            child: Divider(color: Colors.grey[200], height: 1),
          ),
          _buildOption(
            context,
            icon: Icons.grid_on,
            title: 'Post',
            onTap: () {
              Navigator.pop(context); // 시트 닫기
              // 이미지 선택 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 56, right: 16),
            child: Divider(color: Colors.grey[200], height: 1),
          ),
          _buildOption(
            context,
            icon: Icons.person_pin_outlined,
            title: 'Share only to profile',
            onTap: () {},
            showNew: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showNew = false,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
      trailing: showNew
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF3797EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            )
          : null,
      onTap: onTap,
    );
  }
}