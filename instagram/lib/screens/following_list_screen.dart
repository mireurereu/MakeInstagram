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
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
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
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
            Tab(text: 'Subscriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text('Followers list')),
          _buildFollowingList(),
          const Center(child: Text('Subscriptions list')),
        ],
      ),
    );
  }

  Widget _buildFollowingList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              fillColor: const Color(0xFFEFEFEF),
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

  Widget _buildUserTile(Map<String, String> user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage('https://picsum.photos/seed/${user['img'] ?? 'default'}/100/100'),
      ),
      title: Text(user['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(user['name'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
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
          ),
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.black), constraints: const BoxConstraints(), onPressed: () {}),
        ],
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(username: user['username'])));
      },
    );
  }
}
