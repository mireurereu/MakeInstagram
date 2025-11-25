import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SuggestedReelsWidget extends StatelessWidget {
  const SuggestedReelsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Debug: confirm build
    // ignore: avoid_print
    print('SuggestedReelsWidget.build');
    // [확인용] Flutter 공식 더미 비디오 URL들
    final List<String> videoUrls = [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 나비
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',       // 벌
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // 나비 (반복)
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',       // 벌 (반복)
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 타이틀
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Suggested reels',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.close, size: 20, color: Colors.grey),
              ],
            ),
          ),
          
          // 릴스 리스트 (가로 스크롤)
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: videoUrls.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                return _ReelItem(
                  // 리스트 갱신 문제를 피하기 위해 고유 키 설정
                  key: ValueKey('${videoUrls[index]}_$index'),
                  url: videoUrls[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelItem extends StatefulWidget {
  final String url;
  const _ReelItem({super.key, required this.url});

  @override
  State<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<_ReelItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasInitError = false;

  @override
  void initState() {
    super.initState();
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _controller!.setLooping(true); // 무한 반복
            _controller!.setVolume(0);     // 소리 끄기 (자동 재생 정책)
          });
        }
      }).catchError((e) {
        // ignore: avoid_print
        print('Video initialize error for ${widget.url}: $e');
        if (mounted) setState(() => _hasInitError = true);
      });
    } catch (e) {
      // ignore: avoid_print
      print('Video controller creation error for ${widget.url}: $e');
      if (mounted) setState(() => _hasInitError = true);
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 노출 감지 위젯
    return VisibilityDetector(
      key: widget.key!,
      onVisibilityChanged: (VisibilityInfo info) {
        if (!_isInitialized || _controller == null) return;

        // 화면에 50% 이상 보이면 재생, 아니면 멈춤
        if (info.visibleFraction > 0.5) {
          if (!_controller!.value.isPlaying) _controller!.play();
        } else {
          if (_controller!.value.isPlaying) _controller!.pause();
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 비디오 영역
            if (_hasInitError)
              // fallback: show placeholder with play icon
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white70),
                ),
              )
            else if (_isInitialized && _controller != null)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            else
              const Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
              ),

            // 텍스트 가독성을 위한 그림자
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.6, 1.0],
                ),
              ),
            ),

            // 하단 정보
            Positioned(
              bottom: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Reels',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  Text('Sponsored',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}