import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        children: [
          // 1. Today 섹션
          _buildSectionHeader('Today'),
          
          // 댓글 알림 (haetbaaan)
          _buildNotificationItem(
            type: NotificationType.comment,
            username: 'haetbaaan',
            content: 'commented: so cute!!',
            time: '6s',
            avatarUrl: 'https://picsum.photos/seed/haetbaaan/100/100',
            postUrl: 'https://picsum.photos/seed/dragon/100/100',
            showReplyButton: true, // 답글 달기 버튼 표시
          ),

          // 2. Last 30 days 섹션
          _buildSectionHeader('Last 30 days'),
          
          // 좋아요 알림 (haetbaaan)
          _buildNotificationItem(
            type: NotificationType.like,
            username: 'haetbaaan',
            content: 'liked your photo.',
            time: '2w',
            avatarUrl: 'https://picsum.photos/seed/haetbaaan/100/100',
            postUrl: 'https://picsum.photos/seed/code/100/100',
          ),

          // 팔로우 알림 (haetbaaan - 이미 팔로잉 중)
          _buildNotificationItem(
            type: NotificationType.follow,
            username: 'haetbaaan',
            content: 'started following you.',
            time: '2w',
            avatarUrl: 'https://picsum.photos/seed/haetbaaan/100/100',
            isFollowing: true, // Following 버튼 (회색)
          ),

          // 팔로우 알림 (yonghyeon5670 - 이미 팔로잉 중)
          _buildNotificationItem(
            type: NotificationType.follow,
            username: 'yonghyeon5670',
            content: 'started following you.',
            time: '2w',
            avatarUrl: 'https://picsum.photos/seed/yonghyeon/100/100',
            isFollowing: true,
          ),

          // 팔로우 알림 (junehxuk - 팔로우 안 함)
          _buildNotificationItem(
            type: NotificationType.follow,
            username: 'junehxuk',
            content: 'started following you.',
            time: '2w',
            avatarUrl: 'https://picsum.photos/seed/junhyuk/100/100',
            isFollowing: true, // 영상에선 Following 상태
          ),

          // 정보성 알림
          _buildInfoItem(
            text: 'You have 2 new accounts in your Accounts Center.',
            time: '2w',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildNotificationItem({
    required NotificationType type,
    required String username,
    required String content,
    required String time,
    required String avatarUrl,
    String? postUrl,
    bool isFollowing = false,
    bool showReplyButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
        children: [
          // 아바타 (+ 배지 아이콘)
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              // 좋아요 알림일 때만 하트 아이콘 배지 표시 (디테일)
              if (type == NotificationType.like)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red, // 빨간 배경
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, size: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          
          // 텍스트 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.3),
                    children: [
                      TextSpan(
                        text: username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' $content',
                      ),
                      TextSpan(
                        text: ' $time',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                if (showReplyButton)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Reply',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),

          // 우측 액션 (게시물 썸네일 OR 팔로우 버튼)
          if (type == NotificationType.follow)
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? const Color(0xFFEFEFEF) : _instaBlue,
                  foregroundColor: isFollowing ? Colors.black : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            )
          else if (postUrl != null)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 0.5),
                borderRadius: BorderRadius.circular(4), // 약간 둥근 사각형
                image: DecorationImage(
                  image: NetworkImage(postUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required String text, required String time}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 인스타 로고 아이콘
          Container(
            width: 44, 
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Icon(Icons.facebook, size: 28), // Meta 아이콘 대체
          ),
          const SizedBox(width: 14),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.3),
                children: [
                  TextSpan(text: text),
                  TextSpan(
                    text: ' $time',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 알림 유형 열거형
enum NotificationType {
  like,
  comment,
  follow,
}