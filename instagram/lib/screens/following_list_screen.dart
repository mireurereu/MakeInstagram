import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/data/user_state.dart';

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
    // If viewing imwinter, use custom 4-tab layout and default to '4 following' tab
    final bool isImwinter = (widget.username ?? UserState.myId) == 'imwinter';
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
          tabs: (widget.username ?? UserState.myId) == 'imwinter'
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
          // For imwinter show placeholders for custom tabs; otherwise default views
          if ((widget.username ?? UserState.myId) == 'imwinter') ...[
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
    );
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

        const Divider(height: 1, color: Color(0xFFE0E0E0)),

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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage('https://picsum.photos/seed/${user['img'] ?? 'default'}/100/100'),
      ),
      title: Row(children: [
        Text(user['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 6),
        if (user['username'] != null && user['username']!.isNotEmpty && UserState.isVerified(user['username']!))
          Icon(Icons.verified, color: const Color(0xFF3797EF), size: 16),
      ]),
      subtitle: Text(user['name'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
      trailing: Row(
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
