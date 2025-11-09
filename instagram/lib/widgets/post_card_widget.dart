// lib/widgets/post_card_widget.dart

import 'package:flutter/material.dart';
import 'package:instagram/widgets/comment_model.dart';
import 'package:instagram/widgets/comments_modal_content.dart';

class PostCardWidget extends StatefulWidget {
  // 데이터 모델 (단순화를 위해 여전히 하드코딩된 값을 기본값으로 사용)
  final String username;
  final String userAvatarUrl;
  final List<String> postImageUrls; // 단일 이미지가 아닌 리스트로 변경
  final String caption;
  final String likeCount;
  final String commentCount;
  final String timestamp;
  final bool isSponsored; // 스폰서 게시물 여부
  final bool isCarousel; // 캐러셀 여부 (이미지 리스트 개수로 자동 감지)
  final bool isVideo;

  PostCardWidget({
    super.key,
    this.username = "aespa_official",
    this.userAvatarUrl = "https://picsum.photos/seed/aespa/100/100",
    List<String>? postImageUrls, // 외부에서 주입받을 수 있도록 변경
    this.caption = "Bee~ Gese Stay Alive 🐝",
    this.likeCount = "918,471",
    this.commentCount = "2,000",
    this.timestamp = "5 days ago",
    this.isSponsored = false, // 기본값은 스폰서 아님
    this.isVideo = false,
  })  : postImageUrls = postImageUrls ??
            ["https://picsum.photos/seed/karina/600/600"], // 기본값은 단일 이미지
        isCarousel = (postImageUrls != null && postImageUrls.length > 1);

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  // 캐러셀의 현재 페이지 인덱스
  int _currentCarouselIndex = 0;
  bool _isLiked = false;

  // --- (신규) 댓글 목록 상태를 부모(여기)로 끌어올림 ---
  late List<Comment> _comments;
  // --- (신규) 중앙 하트 애니메이션을 위한 상태 ---
  bool _showHeartAnimation = false;

  @override
  void initState() {
    super.initState();
    // 포스트 카드가 생성될 때 댓글 목록을 여기서 초기화합니다.
    _comments = [
      Comment(
        username: widget.username,
        avatarUrl: widget.userAvatarUrl,
        text: widget.caption,
      ),
      Comment(
        username: 'haetbaaan',
        avatarUrl: 'https://picsum.photos/seed/haetbaaan/100/100',
        text: 'so cute!! 🥹🥹',
        isLiked: true,
      ),
      Comment(
        username: 'junehxuk',
        avatarUrl: 'https://picsum.photos/seed/junehxuk/100/100',
        text: 'I love puang',
      ),
    ];
  }

  // --- (신규) 자식(모달)에서 호출할 댓글 추가 함수 ---
  void _handlePostComment(String text) {
    setState(() {
      _comments.add(Comment(
        username: 'ta_junhyuk', // (임시) 내 유저 이름
        avatarUrl: 'https://picsum.photos/seed/my_profile/100/100',
        text: text,
      ));
    });
    // TODO: 백엔드에 이 변경사항 전송
  }

  // --- (신규) 자식(모달)에서 호출할 댓글 좋아요 토글 함수 ---
  void _handleToggleCommentLike(Comment comment) {
    // 캡션(첫 번째 댓글)은 '좋아요' 대상에서 제외
    if (_comments.indexOf(comment) == 0) return;

    setState(() {
      comment.isLiked = !comment.isLiked;
    });
    // TODO: 백엔드에 이 변경사항 전송
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더 (스폰서 여부에 따라 UI 분기)
          _buildHeader(),

          // 2. 본문 (캐러셀 또는 단일 이미지)
          _buildContent(context),

          // 3. 액션 버튼 (좋아요, 댓글, 공유, 북마크)
          _buildActionButtons(),

          // 4. 푸터 (스폰서 여부에 따라 'Shop now' 버튼 추가)
          _buildFooter(context),
        ],
      ),
    );
  }

  // 1. 헤더 위젯 (수정)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(widget.userAvatarUrl),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 스폰서 게시물일 경우 "Sponsored" 텍스트 표시
                if (widget.isSponsored)
                  Text(
                    'Sponsored',
                    style: TextStyle(color: Colors.white54, fontSize: 12.0),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // 2. 본문 위젯 (수정 - 캐러셀 구현)
  // lib/widgets/post_card_widget.dart (내부)

// 2. 본문 위젯 (수정됨 - GestureDetector, AnimatedOpacity 추가)
Widget _buildContent(BuildContext context) {
  return GestureDetector( // (신규) 더블 탭 감지를 위해 추가
    onDoubleTap: _handleDoubleTap, // 더블 탭 시 _handleDoubleTap 함수 호출
    child: AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        alignment: Alignment.center, // (신규) 하트 아이콘을 중앙에 배치하기 위해 추가
        children: [
          
          // 2-1. 기존 PageView (사진/영상 콘텐츠)
          PageView.builder(
            itemCount: widget.postImageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                widget.postImageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[900],
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                  );
                },
              );
            },
          ),

          // 2-2. 기존 캐러셀 인디케이터 (우측 상단 숫자)
          if (widget.isCarousel)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.7), // replaced withOpacity
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '${_currentCarouselIndex + 1} / ${widget.postImageUrls.length}',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ),
            ),
          
          // 2-3. 기존 캐러셀 인디케이터 (하단 점)
          if (widget.isCarousel)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.postImageUrls.length, (index) {
                  return Container(
                    width: 6.0,
                    height: 6.0,
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
            color: _currentCarouselIndex == index
              ? Colors.blue
              : Color.fromRGBO(255, 255, 255, 0.5), // replaced withOpacity
                    ),
                  );
                }),
              ),
            ),

          // 2-4. (신규) 중앙 하트 애니메이션
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200), // 0.2초
            opacity: _showHeartAnimation ? 1.0 : 0.0, // _showHeartAnimation 상태에 따라 투명도 조절
            child: Icon(
              Icons.favorite,
              color: Colors.white,
              size: 100.0, // 큰 하트
            ),
          ),
        ],
      ),
    ),
  );
}

  // 3. 액션 버튼 위젯 (변경 없음 - 이전과 동일)
  Widget _buildActionButtons() {
    // ... (이전 단계의 코드와 동일) ...
    // (IconButton 4개 포함된 Row)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: _isLiked
                    ? Icon(Icons.favorite, color: Colors.red, size: 28) // 좋아요 눌림
                    : Icon(Icons.favorite_border, color: Colors.white, size: 28),
                onPressed: _handleIconTap, // 기본
              ),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
                onPressed: () {
                  _showCommentsModal(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.send_outlined, color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // 4. 푸터 위젯 (수정 - 스폰서 버튼 추가)
  Widget _buildFooter(BuildContext context) {
    // 스폰서 게시물일 경우, UI가 완전히 달라짐 (영상 0:14초 참고)
    if (widget.isSponsored) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.caption, // 스폰서는 캡션을 바로 보여줌
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼색
                foregroundColor: Colors.white, // 글자색
              ),
                child: Text('Install now'), // 영상에서는 'Shop now' 등
            )
          ],
        ),
      );
    }

    // 일반 게시물 푸터 (이전과 동일)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.likeCount} likes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: '${widget.username} ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: widget.caption),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'View all ${widget.commentCount} comments',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 4.0),
          Text(
            widget.timestamp,
            style: TextStyle(color: Colors.white54, fontSize: 12.0),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }

void _showCommentsModal(BuildContext context) {
    // (영상 2:31)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드 높이만큼 올라오도록
      backgroundColor: Colors.transparent,
      builder: (context) {
        // 이제 복잡한 UI 대신, 별도로 분리한 StatefulWidget을 호출합니다.
        return CommentsModalContent(
          // 댓글 목록과 콜백을 전달하도록 수정
          comments: _comments,
          onCommentPosted: _handlePostComment,
          onCommentLiked: _handleToggleCommentLike,
        );
      },
    );
  }
void _handleDoubleTap() {
    // 1. '좋아요' 상태를 true로 변경 (더블 탭은 '좋아요' 취소 기능 없음)
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
      });
      // TODO: 백엔드에 '좋아요' 전송
    }

    // 2. 영상이 아닐(사진일) 경우에만 애니메이션 표시
    if (!widget.isVideo) {
      setState(() {
        _showHeartAnimation = true; // 하트 보이기
      });
      // 0.8초 후에 하트 숨기기
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _showHeartAnimation = false;
        });
      });
    }
  }
  void _handleIconTap() {
    setState(() {
      _isLiked = !_isLiked; // 아이콘 탭은 '토글'
    });
    // TODO: 백엔드에 '좋아요'/'좋아요 취소' 전송
  }
} 