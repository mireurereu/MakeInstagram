// lib/widgets/post_card_widget.dart

import 'package:flutter/material.dart';

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
  })  : postImageUrls = postImageUrls ??
            ["https://picsum.photos/seed/karina/600/600"], // 기본값은 단일 이미지
        isCarousel = (postImageUrls != null && postImageUrls.length > 1);

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  // 캐러셀의 현재 페이지 인덱스
  int _currentCarouselIndex = 0;

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
  Widget _buildContent(BuildContext context) {
    // PageView를 사용하여 좌우 스와이프 구현
    return AspectRatio(
      aspectRatio: 1.0, // 1:1 정사각형 비율
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.postImageUrls.length,
            // 페이지가 변경될 때마다 _currentCarouselIndex 업데이트
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

          // 캐러셀 인디케이터 (이미지가 여러 장일 때만 표시)
          if (widget.isCarousel)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '${_currentCarouselIndex + 1} / ${widget.postImageUrls.length}',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ),
            ),
          
          // 캐러셀 하단 인디케이터 (점)
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
                          ? Colors.blue // 활성
                          : Colors.white.withOpacity(0.5), // 비활성
                    ),
                  );
                }),
              ),
            ),
        ],
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
                icon: Icon(Icons.favorite_border, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
                onPressed: () {},
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
              child: Text('Install now'), // 영상에서는 'Shop now' 등
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼색
                foregroundColor: Colors.white, // 글자색
              ),
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
}