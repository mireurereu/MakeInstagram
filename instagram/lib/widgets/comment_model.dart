// 댓글 하나를 정의하는 데이터 클래스
class Comment {
  final String username;
  final String avatarUrl;
  final String text;
  bool isLiked; // '좋아요' 상태 (변경 가능해야 하므로 final이 아님)
  int likeCount;

  Comment({
    required this.username,
    required this.avatarUrl,
    required this.text,
    this.isLiked = false,
    this.likeCount = 0,
  });
}