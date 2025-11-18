import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          // 1. Today 섹션
          _buildSectionHeader('Today'),
          _buildCommentNotification(
            username: 'haetbaaan',
            content: 'commented: so cute!!',
            time: '6s',
            postImageUrl: 'https://picsum.photos/seed/dragon/100/100', // (파란 용 사진)
            avatarUrl: 'https://picsum.photos/seed/haetbaaan/100/100',
            isNew: true, // 배경색 하이라이트
          ),

          // 2. Last 30 days 섹션
          _buildSectionHeader('Last 30 days'),
          _buildLikeNotification(
            username: 'haetbaaan',
            content: 'liked your photo.',
            time: '2w',
            postImageUrl: 'https://picsum.photos/seed/code/100/100', // (코드 사진)
            avatarUrl: 'https://picsum.photos/seed/haetbaaan/100/100',
          ),
          _buildFollowNotification(
            username: 'haetbaaan',
            time: '2w',
            avatarUrl: 'https://picsum.photos/seed/haetbaaan/100/100',
          ),
          _buildFollowNotification(
            username: 'yonghyeon5670',
            time: '2w',
            avatarUrl: 'https://picsum.photos/seed/yonghyeon/100/100',
          ),
          _buildFollowNotification(
            username: 'junehxuk',
            time: '2w',
            avatarUrl: 'https://picsum.photos/seed/junhyuk/100/100',
          ),
          _buildInfoNotification(
            text: 'You have 2 new accounts in your Accounts Center.',
            time: '2w',
          ),
        ],
      ),
    );
  }

  // 섹션 헤더 (Today, Last 30 days)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // 1. 댓글 알림 타일
  Widget _buildCommentNotification({
    required String username,
    required String content,
    required String time,
    required String postImageUrl,
    required String avatarUrl,
    bool isNew = false,
  }) {
    return Container(
      color: isNew ? Colors.blue.withOpacity(0.05) : Colors.transparent, // 새 알림 배경색
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                          text: username,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' $content '),
                      TextSpan(
                          text: time,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.favorite_border, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Reply', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(postImageUrl, width: 44, height: 44, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  // 2. 좋아요 알림 타일 (아바타에 하트 배지 포함)
  Widget _buildLikeNotification({
    required String username,
    required String content,
    required String time,
    required String postImageUrl,
    required String avatarUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.red, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                      text: username,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' $content '),
                  TextSpan(
                      text: time,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(postImageUrl, width: 44, height: 44, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  // 3. 팔로우 알림 타일 ('Following' 버튼 포함)
  Widget _buildFollowNotification({
    required String username,
    required String time,
    required String avatarUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                      text: username,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' started following you. '),
                  TextSpan(
                      text: time,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
            child: const Text('Following'),
          ),
        ],
      ),
    );
  }

  // 4. 정보 알림 타일 (아이콘 포함)
  Widget _buildInfoNotification({required String text, required String time}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.info_outline, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(text: '$text '),
                  TextSpan(
                      text: time,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}