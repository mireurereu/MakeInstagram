// 댓글 하나를 정의하는 데이터 클래스
class Comment {
  final String username;
  final String avatarUrl;
  final String text;
  bool isLiked; // '좋아요' 상태 (변경 가능해야 하므로 final이 아님)
  int likeCount;
  final String? replyToUsername; // 대댓글일 경우 대상 유저명
  final bool isPosting; // Posting... 상태 표시용

  Comment({
    required this.username,
    required this.avatarUrl,
    required this.text,
    this.isLiked = false,
    this.likeCount = 0,
    this.replyToUsername,
    this.isPosting = false,
  });
}