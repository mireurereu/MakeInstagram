// lib/screens/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:instagram/widgets/post_card_widget.dart';
import 'package:instagram/screens/dm_list_screen.dart'; // 곧 생성할 파일

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 앱 바
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // 2. 스크린샷처럼 그림자 추가
        title: const Text(
          'Instagram',
          style: TextStyle(
            color: Colors.black, // 3. 텍스트 색상 검은색
            fontFamily: 'Billabong', 
            fontSize: 32.0,
          ),
        ),
        actions: [
          // '좋아요' 아이콘 버튼
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              // 좋아요 관련 동작 추가
            },
          ),
          // 'DM' 아이콘 버튼
          IconButton(
            icon: const Icon(Icons.send_outlined, color: Colors.black),
            onPressed: () {
              // 'DM' 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DmListScreen()),
              );
            },
          ),
        ],
      ),
      // 메인 바디 (게시물 리스트)
      body: ListView.builder(
        itemCount: 10, // 10개의 게시물
        itemBuilder: (context, index) {
    // index를 사용하여 다양한 유형의 게시물 생성
          // 1. 캐러셀 게시물 (영상 0:16초의 'karinabluu')
          if (index == 1) {
            return PostCardWidget(
              username: 'karinabluu',
              userAvatarUrl: 'https://picsum.photos/seed/karina/100/100',
              // 3장의 이미지 리스트 전달
              postImageUrls: [
                'https://picsum.photos/seed/picsum1/600/600',
                'https://picsum.photos/seed/picsum2/600/600',
                'https://picsum.photos/seed/picsum3/600/600',
              ],
              caption: 'more',
              likeCount: '1,367,685',
              timestamp: '5 days ago',
              isVideo: false,
            );
          }

          // 2. 스폰서 광고 (영상 0:14초)
          if (index == 2) {
            return PostCardWidget(
              username: 'kingtitan.mobile',
              userAvatarUrl: 'https://picsum.photos/seed/sponsor/100/100',
              postImageUrls: ['https://picsum.photos/seed/ad/600/600'], // 광고 이미지
              caption: 'Get 50% off today!',
              isSponsored: true, // 스폰서 플래그 설정
            );
          }
          
          // 3. 캐러셀 게시물 2 (영상 0:31초의 'imwinter')
          if (index == 3) {
            return PostCardWidget(
              username: 'imwinter',
              userAvatarUrl: 'https://picsum.photos/seed/winter/100/100',
              // 4장의 이미지 리스트 전달
              postImageUrls: [
                'https://picsum.photos/seed/winter1/600/600',
                'https://picsum.photos/seed/winter2/600/600',
                'https://picsum.photos/seed/winter3/600/600',
                'https://picsum.photos/seed/winter4/600/600',
              ],
              caption: '사랑스러운 🗿🤍', // 영상 캡션
              likeCount: '886,981',
              timestamp: '3 days ago',
            );
          }

          // 4. 일반 게시물 (영상이라고 가정)
          if (index == 4) { // 'aespa_official' 게시물을 4번 인덱스로 가정
            return PostCardWidget(
              username: 'aespa_official',
              userAvatarUrl: 'https://picsum.photos/seed/aespa/100/100',
              postImageUrls: ['https://picsum.photos/seed/aespa_post/600/600'],
              caption: 'Bee~ Gese Stay Alive 🐝',
              likeCount: '918,471',
              timestamp: '5 days ago',
              isVideo: true, // (신규) 이것은 영상입니다!
            );
          }

          // 나머지 일반 사진 게시물
          return PostCardWidget(
            // ... (기본값 사용) ...
            // isVideo의 기본값은 false이므로 사진으로 처리됩니다.
          );
        },
      ),
    );
  }
}