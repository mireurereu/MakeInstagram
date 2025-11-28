import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/data/user_state.dart';
import 'package:instagram/screens/main_navigation_screen.dart';

class FollowingListScreen extends StatefulWidget {
  final String? username;

  const FollowingListScreen({super.key, this.username});

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, String>> followingList;

  final Color _instaBlue = const Color(0xFF3797EF);

  @override
  void initState() {
    super.initState();
    // If viewing hellokitty, use custom 4-tab layout and default to '4 following' tab
    final bool isImwinter = (widget.username ?? UserState.myId) == 'hellokitty';
    final int tabCount = isImwinter ? 4 : 3;
    final int initial = isImwinter ? 2 : 1;
    _tabController = TabController(length: tabCount, vsync: this, initialIndex: initial);
    followingList = UserState.getFollowingList(widget.username ?? UserState.myId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.username ?? UserState.myId,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 1.0,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: (widget.username ?? UserState.myId) == 'hellokitty'
              ? const [
                  Tab(text: '3 mutual'),
                  Tab(text: '13M followers'),
                  Tab(text: '4 following'),
                  Tab(text: 'Suggested'),
                ]
              : const [
                  Tab(text: 'Followers'),
                  Tab(text: 'Following'),
                  Tab(text: '0 Subscriptions'),
                  Tab(text: 'Flagged'),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // For hellokitty show placeholders for custom tabs; otherwise default views
          if ((widget.username ?? UserState.myId) == 'hellokitty') ...[
            const Center(child: Text('3 mutual', style: TextStyle(color: Colors.grey))),
            const Center(child: Text('13M followers', style: TextStyle(color: Colors.grey))),
            _buildFollowingList(showSearch: true, showSync: false),
            _buildSuggestedList(),
          ] else ...[
            const Center(child: Text('Followers list')),
            _buildFollowingList(
              showSearch: (widget.username ?? UserState.myId) == UserState.myId,
              showSync: (widget.username ?? UserState.myId) == UserState.myId,
            ),
            const Center(child: Text('Subscriptions list')),
          ],
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFDBDBDB), width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) {
            Navigator.pop(context);
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
              (route) => false,
            );
            mainNavKey.currentState?.changeTab(index);
          }
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined, size: 28),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined, size: 28),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<String>(
              valueListenable: UserState.myAvatarUrlNotifier,
              builder: (context, avatarUrl, child) {
                return Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.black, width: 1.5),
                    image: DecorationImage(
                      image: _getImageProvider(avatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }
  Widget _buildFollowingList({bool showSearch = false, bool showSync = false}) {
    return Column(
      children: [
        // Search first (if requested)
        if (showSearch)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: const Color(0xFFF2F2F2),
                filled: true,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

        // Sync contacts only for own profile
        if (showSync)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: const Center(child: Icon(Icons.person_add_alt_1, color: Colors.black, size: 24)),
              ),
            ),
            title: const Text('Sync contacts', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Find people you know', style: TextStyle(color: Colors.grey, fontSize: 13)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _instaBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(70, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {},
              child: const Text('Sync', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

        // Divider before Sorted by Default
        if (showSync)
          const Divider(height: 1, color: Color(0xFFE0E0E0)),

        // Sorted by Default row for own profile
        if (showSync)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Sorted by Default', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Icon(Icons.swap_vert, color: Colors.black),
              ],
            ),
          ),

        Expanded(
          child: ListView.builder(
            itemCount: followingList.length,
            itemBuilder: (context, index) {
              final user = followingList[index];
              return _buildUserTile(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedList() {
    // Simple suggested list: show the same underlying source but label as suggested.
    final suggestions = UserState.getFollowingList(widget.username ?? UserState.myId);
    return Column(
      children: [
        const SizedBox(height: 8),
        const Divider(height: 1, color: Color(0xFFE0E0E0)),
        Expanded(
          child: ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final user = suggestions[index];
              return _buildUserTile(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(Map<String, String> user) {
    // hellokitty의 following 화면인지 확인
    final bool isImwinterFollowing = (widget.username ?? UserState.myId) == 'hellokitty';
    
    // 프로필 이미지 경로 결정
    String username = user['username'] ?? '';
    ImageProvider avatarImage;
    
    // username 기반으로 프로필 이미지 매핑
    if (username == 'hangyo') {
      avatarImage = const AssetImage('assets/images/profiles/hangyo.jpg');
    } else if (username == 'sanrio_official') {
      avatarImage = const AssetImage('assets/images/profiles/sanrio.jpg');
    } else if (username == 'mymelody') {
      avatarImage = const AssetImage('assets/images/profiles/mymelody.jpg');
    } else if (username == 'pochacco') {
      avatarImage = const AssetImage('assets/images/profiles/pochacco.jpg');
    } else if (username == 'pompom') {
      avatarImage = const AssetImage('assets/images/profiles/pompom.jpg');
    } else if (username == 'keroppi') {
      avatarImage = const AssetImage('assets/images/profiles/keroppi.jpg');
    } else if (username == 'cinnamo') {
      avatarImage = const AssetImage('assets/images/profiles/cinnamo.jpg');
    } else if (username == 'hellokitty') {
      avatarImage = const AssetImage('assets/images/profiles/hellokitty.jpg');
    } else if (username == 'npochamu') {
      avatarImage = const AssetImage('assets/images/profiles/npochamu.jpg');
    } else if (username == 'kuromi') {
      avatarImage = const AssetImage('assets/images/profiles/kuromi.jpg');
    } else {
      // 기본 이미지 또는 네트워크 이미지
      String imgPath = user['img'] ?? 'default';
      if (imgPath.startsWith('assets/')) {
        avatarImage = AssetImage(imgPath);
      } else {
        avatarImage = NetworkImage('https://picsum.photos/seed/$username/100/100');
      }
    }

    final bool hasStory = UserState.hasStory(username);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(2.5), // 링 두께
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasStory
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFBAA47), // 노랑
                    Color(0xFFD91A46), // 빨강
                    Color(0xFFA60F93), // 보라
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                )
              : null, // 스토리가 없으면 링 없음
        ),
        child: Container(
          padding: const EdgeInsets.all(2.5), // 사진과 링 사이 흰색 테두리
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: CircleAvatar(
            radius: 24, // 원래 사이즈 유지
            backgroundImage: avatarImage,
          ),
        ),
      ),
      title: Row(children: [
        Text(user['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 6),
        if (user['username'] != null && user['username']!.isNotEmpty && UserState.isVerified(user['username']!))
          Icon(Icons.verified, color: const Color(0xFF3797EF), size: 16),
      ]),
      subtitle: Text(user['name'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
      trailing: isImwinterFollowing
          ? (UserState.amIFollowing(user['username'] ?? '')
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFEFEF),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(105, 34),
                    maximumSize: const Size(105, 34),
                  ),
                  onPressed: () {},
                  child: const Text('Message', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _instaBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(105, 34),
                    maximumSize: const Size(105, 34),
                  ),
                  onPressed: () {
                    setState(() {
                      UserState.toggleFollow(user['username'] ?? '');
                      followingList = UserState.getFollowingList(widget.username ?? UserState.myId);
                    });
                  },
                  child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserState.amIFollowing(user['username'] ?? '')
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFEFEF),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () {},
                        child: const Text('Message', style: TextStyle(fontWeight: FontWeight.w600)),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _instaBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(70, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () {
                          setState(() {
                            UserState.toggleFollow(user['username'] ?? '');
                            followingList = UserState.getFollowingList(widget.username ?? UserState.myId);
                          });
                        },
                        child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.more_horiz, color: Colors.black), constraints: const BoxConstraints(), onPressed: () {}),
              ],
            ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(username: user['username'])));
      },
    );
  }
}