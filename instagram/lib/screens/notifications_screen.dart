import 'package:flutter/material.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/screens/post_viewer_screen.dart';
import 'dart:io';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  // Global notifications notifier (list of notification items)
  static final ValueNotifier<List<Map<String, dynamic>>> notificationsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  
  // Global notifier for unread notifications badge
  static final ValueNotifier<bool> hasUnreadNotifications = ValueNotifier<bool>(false);
  
  // 말풍선 표시용 notifier (댓글 알림 시 잠시 표시)
  static final ValueNotifier<bool> showCommentBubble = ValueNotifier<bool>(false);
  
  // 하이라이팅된 알림 ID
  static final ValueNotifier<String?> highlightedNotificationId = ValueNotifier<String?>(null);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  final Color _instaBlue = const Color(0xFF3797EF);

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

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
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: NotificationsScreen.notificationsNotifier,
        builder: (context, notifications, _) {
          
          // [추가 1] 가장 최신 댓글 알림 찾기 (리스트의 앞쪽이 최신이라고 가정)
          String? latestCommentId;
          try {
            final latestComment = notifications.firstWhere(
              (n) => n['type'] == NotificationType.comment,
            );
            latestCommentId = latestComment['notificationId'];
          } catch (_) {
            // 댓글 알림이 없으면 pass
          }

          return ListView(
            children: [
              // 1. Today 섹션
              _buildSectionHeader('Today'),
              
              // Dynamic notifications from notifier (most recent first)
              ...notifications.map((notif) {
                // [추가 2] 현재 아이템이 가장 최신 댓글인지 확인
                final bool isLatest = notif['notificationId'] == latestCommentId;

                return _buildNotificationItem(
                  type: notif['type'] as NotificationType,
                  username: notif['username'] as String,
                  content: notif['content'] as String,
                  time: notif['time'] as String,
                  avatarUrl: notif['avatarUrl'] as String,
                  postUrl: notif['postUrl'] as String?,
                  showReplyButton: notif['showReplyButton'] as bool? ?? false,
                  notificationId: notif['notificationId'] as String?,
                  postId: notif['postId'] as String?,
                  commentId: notif['commentId'] as String?,
                  // [추가 3] 플래그 전달
                  isLatest: isLatest,
                );
              }),

              // 댓글 알림 (pompom) - 하드코딩 예시
              _buildNotificationItem(
                type: NotificationType.comment,
                username: 'pompom',
                content: 'commented: so cute!!',
                time: '6s',
                avatarUrl: 'assets/images/profiles/pompom.jpg',
                postUrl: 'assets/images/rilakkuma/r7.jpg',
                showReplyButton: true,
                notificationId: 'notif_pompom_comment',
                postId: 'post_dragon',
                // 하드코딩된 아이템은 강조하지 않음 (필요하면 true로 변경)
                isLatest: false, 
              ),

              // 2. Last 30 days 섹션
              _buildSectionHeader('Last 30 days'),
              
              // 좋아요 알림 (pompom)
              _buildNotificationItem(
                type: NotificationType.like,
                username: 'pompom',
                content: 'liked your photo.',
                time: '2w',
                avatarUrl: 'assets/images/profiles/pompom.jpg',
                postUrl: 'assets/images/rilakkuma/r1.jpg',
              ),

              // 팔로우 알림 (pompom - 이미 팔로잉 중)
              _buildNotificationItem(
                type: NotificationType.follow,
                username: 'pompom',
                content: 'started following you.',
                time: '2w',
                avatarUrl: 'assets/images/profiles/pompom.jpg',
                isFollowing: true, // Following 버튼 (회색)
              ),

              // 팔로우 알림 (yonghyeon5670 - 이미 팔로잉 중)
              _buildNotificationItem(
                type: NotificationType.follow,
                username: 'keroppi',
                content: 'started following you.',
                time: '2w',
                avatarUrl: 'assets/images/profiles/keroppi.jpg',
                isFollowing: true,
              ),

              // 팔로우 알림 (mymelody - 팔로우 안 함)
              _buildNotificationItem(
                type: NotificationType.follow,
                username: 'mymelody',
                content: 'started following you.',
                time: '2w',
                avatarUrl: 'assets/images/profiles/mymelody.jpg',
                isFollowing: true, // 영상에선 Following 상태
              ),

              // 정보성 알림
              _buildInfoItem(
                text: 'You have 2 new accounts in your Accounts Center.',
                time: '2w',
              ),
            ],
          );
        },
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
    String? notificationId,
    String? postId,
    String? commentId,
    // [추가 4] 최신 알림 여부 파라미터
    bool isLatest = false,
  }) {
    return ValueListenableBuilder<String?>(
      valueListenable: NotificationsScreen.highlightedNotificationId,
      builder: (ctx, highlightedId, _) {
        // [수정] 클릭해서 하이라이트된 상태 OR 최신 알림인 상태면 파란색
        final bool isHighlighted = (notificationId != null && highlightedId == notificationId) || isLatest;
        
        return GestureDetector(
          onTap: () async {
            if (type == NotificationType.comment && postId != null && notificationId != null) {
              // 알림 하이라이트 설정 (잠깐 보이도록)
              NotificationsScreen.highlightedNotificationId.value = notificationId;
              
              // 하이라이트를 잠깐 보여주기 위해 딜레이
              await Future.delayed(const Duration(milliseconds: 200));
              
              // NotificationsScreen 닫기
              if (!context.mounted) return;
              Navigator.pop(context);
              
              // 피드에서 해당 게시물 찾기
              final feed = FeedScreen.feedNotifier.value;
              final postIndex = feed.indexWhere((p) => p['id'] == postId);
              
              if (postIndex == -1) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시물을 찾을 수 없습니다')),
                );
                return;
              }
              
              // PostViewerScreen으로 이동하면서 자동으로 댓글 모달 열기
              if (!context.mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostViewerScreen(
                    posts: feed,
                    initialIndex: postIndex,
                    autoOpenComments: true,
                    highlightedCommentId: commentId,
                    fromNotification: true,
                  ),
                ),
              );
              
              // 돌아오면 하이라이트 해제
              NotificationsScreen.highlightedNotificationId.value = null;
            }
          },
          child: Container(
            // [결과] 조건에 따라 배경색 변경
            color: isHighlighted ? const Color(0xFFE3F2FD) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 아바타 (+ 배지 아이콘)
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: _getImageProvider(avatarUrl),
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
                              color: Colors.red,
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
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: _getImageProvider(postUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
            child: const Icon(Icons.facebook, size: 28), // 여기서는 facebook 아이콘을 placeholder로 사용중이네요
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