// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart'; // 곧 생성할 파일

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 탭바(Grid, Tagged)를 사용하기 위해 DefaultTabController로 감쌉니다.
    return DefaultTabController(
      length: 2, // 탭 2개 (그리드, 태그)
      child: Scaffold(
        backgroundColor: Colors.black,
        // (영상 2:23) 상단 앱 바
        appBar: _buildAppBar(context),
        
        // NestedScrollView: 스크롤 영역 안에 스크롤 영역(탭뷰)이 있는 구조
        body: NestedScrollView(
          // 1. 상단 앱 바 밑에서 스크롤되는 영역 (프로필 헤더 + 탭바)
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 프로필 정보 (아바타, 통계, 바이오, 버튼)
              SliverToBoxAdapter(
                child: _buildProfileHeader(context),
              ),
              // 상단에 고정될 탭 바
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.person_pin_outlined)), // 태그된 포스트
                    ],
                    indicatorColor: Colors.white, // 활성 탭 아래 흰색 줄
                  ),
                ),
                pinned: true, // 스크롤해도 상단에 고정!
              ),
            ];
          },
          // 2. 탭 바에 따라 변경되는 실제 콘텐츠 (포스트 그리드)
          body: TabBarView(
            children: [
              // 첫 번째 탭: 포스트 그리드 (영상 2:24)
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 한 줄에 3개
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 3, // 영상에서 3개의 포스트가 보임
                itemBuilder: (context, index) {
                  // 영상의 3개 포스트 (임시 이미지)
                  return Image.network(
                    'https://picsum.photos/seed/post${index + 1}/200/200',
                    fit: BoxFit.cover,
                  );
                },
              ),
              // 두 번째 탭: 태그된 포스트 (플레이스홀더)
              Center(
                child: Text(
                  'Tagged Posts',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (영상 2:23) 프로필 화면의 상단 앱 바
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.lock_outline, size: 20.0), // 비공개 계정 아이콘
          const SizedBox(width: 4.0),
          Text(
            'ta_junhyuk', // 영상의 유저 이름
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add_box_outlined, size: 28.0),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.menu, size: 28.0),
          onPressed: () {},
        ),
      ],
    );
  }

  // (영상 2:23) 프로필 헤더 (아바타, 통계, 바이오)
  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아바타 & 통계 (Posts, Followers, Following)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundImage: NetworkImage('https://picsum.photos/seed/profile/200/200'),
              ),
              _buildStatColumn('3', 'Posts'),
              _buildStatColumn('3', 'Followers'), // (영상 3:32 기준)
              _buildStatColumn('9', 'Following'), // (영상 3:32 기준)
              GestureDetector(
                onTap: () {
                  // 팔로잉 목록 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FollowingListScreen()),
                  );
                },
                child: _buildStatColumn('9', 'Following'), // 영상 4:49 기준
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          // 바이오 (Bio)
          Text('puang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('I\'m gonna be the God of Flutter!!!', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16.0),
          // 'Edit profile' 버튼 (영상 3:33)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800], // 어두운 버튼
              foregroundColor: Colors.white, // 흰색 글씨
              minimumSize: Size(double.infinity, 36), // 가로 꽉 채우기
            ),
            onPressed: () {
              // 프로필 수정 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
            child: Text('Edit profile'),
          ),
        ],
      ),
    );
  }

  // 통계 컬럼 (예: '3' Posts)
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(count, style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 14.0)),
      ],
    );
  }
}

// NestedScrollView의 'SliverPersistentHeader'에 탭 바를 고정시키기 위한 Helper 클래스
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.black, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}