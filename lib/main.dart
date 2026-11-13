import 'package:flutter/material.dart';
import 'room_screen.dart';
import 'moments_tab.dart';
import 'chat_screen.dart';

void main() {
  runApp(const TokiLiteApp());
}

class TokiLiteApp extends StatelessWidget {
  const TokiLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'toki.lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFFFF7A30),
        scaffoldBackgroundColor: const Color(0xFFFCF6F2), // Light peach background
      ),
      home: const TokiMainShell(),
    );
  }
}

class TokiMainShell extends StatefulWidget {
  const TokiMainShell({super.key});

  @override
  State<TokiMainShell> createState() => _TokiMainShellState();
}

class _TokiMainShellState extends State<TokiMainShell> {
  int _tabIndex = 2; // Default to Rooms Tab for testing screen
  int _coins = 500;
  int _selectedAvatar = 0;
  final TextEditingController _nameController = TextEditingController(text: 'Pravin');

  final List _avatars = const [
    {'emoji': '😎', 'bg': 0xFFFFB74D},
    {'emoji': '👑', 'bg': 0xFFF48FB1},
    {'emoji': '🎧', 'bg': 0xFF90CAF9},
    {'emoji': '🔥', 'bg': 0xFFFF8A65},
    {'emoji': '🌸', 'bg': 0xFFCE93D8},
  ];

  final List _tokiRooms = [
    {
      'title': 'welcome everyone',
      'id': 'welcome_everyone',
      'subtitle': '2187 a💑👩‍❤️‍👩🎁🎁🎁🎁👍',
      'badge': 'Music',
      'views': '95',
      'isImage': true,
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100', // Mock female host
      'badgeColor': 0xFF3D5AFE,
    },
    {
      'title': 'SB AGENCY 14 🏵️',
      'id': 'sb_agency_14',
      'subtitle': 'Welcome to the room, let\'s chat~',
      'badge': 'Friendship',
      'views': '43',
      'isImage': true,
      'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100', // Mock art/person
      'badgeColor': 0xFFFF4081,
    },
    {
      'title': 'IHGS Thank you so m 🏵️',
      'id': 'ihgs_room',
      'subtitle': 'Everyone has same Eyes but η...',
      'badge': 'Families',
      'views': '42',
      'isImage': true,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100', // Mock man
      'badgeColor': 0xFF00E676,
    },
    {
      'title': '🙏 Dwarka Nath ✓✓✓✓ 🏵️',
      'id': 'dwarka_nath',
      'subtitle': 'Radhe Radhe ji 🙏',
      'badge': 'Chat',
      'views': '32',
      'isImage': true,
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
      'badgeColor': 0xFFAB47BC,
    },
    {
      'title': '🎂 HBD Alisha 😘🎂 🏵️',
      'id': 'hbd_alisha',
      'subtitle': '🎂 Happy Birthday Alisha! 🎂 (13...',
      'badge': 'Friendship',
      'views': '23',
      'isImage': true,
      'avatar': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100',
      'badgeColor': 0xFFFF4081,
    },
    {
      'title': 'R 🙏 😃 🏵️',
      'id': 'r_room',
      'subtitle': 'اتقى شر من احسنت اليه ❤️ ap ayiye th...',
      'badge': 'Social',
      'views': '18',
      'isImage': true,
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
      'badgeColor': 0xFF00E676,
    }
  ];

  final List _chats = [
    {
      'name': 'Riya Sharma',
      'msg': 'Hi! Party room mein aao na 🎙️',
      'time': 'Just now',
    },
    {
      'name': 'Toki Official',
      'msg': 'Welcome to toki.lite! 500 Free Coins mile 🎉',
      'time': 'Today',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _enterRoom(String roomId, String title) {
    final myName = _nameController.text.trim().isEmpty ? 'Pravin' : _nameController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartyRoomScreen(
          roomId: roomId,
          roomTitle: title,
          userName: myName,
          userEmoji: _avatars[_selectedAvatar]['emoji'].toString(),
          userBg: _avatars[_selectedAvatar]['bg'] as int,
        ),
      ),
    );
  }

  void _sayHiToUser(Map u) {
    final name = u['name'].toString();
    setState(() {
      _chats.insert(0, {
        'name': name,
        'msg': '👋 Aapne Hi bheja! Tap karke chat karein',
        'time': 'Now',
      });
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrivateChatScreen(
          peerName: name,
          peerEmoji: '🌸',
          onJoinVoiceRoom: () {
            Navigator.pop(context);
            _enterRoom(u['room'].toString(), name);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeTab(),
      _buildMomentsTab(),
      _buildRoomsTab(),
      _buildMessagesTab(),
      _buildMeTab(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E24), // Dark navigation bar
        selectedItemColor: const Color(0xFFFF7A30),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.blur_circular), label: 'Moments'),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Rooms'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.chat_bubble_outline),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.red,
                    child: Text('99', style: TextStyle(color: Colors.white, fontSize: 8)),
                  ),
                )
              ],
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
        ],
      ),
    );
  }

  // Home Tab Placeholder
  Widget _buildHomeTab() => const Center(child: Text('Home Tab', style: TextStyle(color: Colors.black87)));

  Widget _buildMomentsTab() {
    return TokiMomentsTab(
      userName: _nameController.text.trim().isEmpty ? 'Pravin' : _nameController.text.trim(),
      userEmoji: _avatars[_selectedAvatar]['emoji'].toString(),
      userBg: _avatars[_selectedAvatar]['bg'] as int,
      onSayHi: (name) => _sayHiToUser({'name': name, 'room': 'welcome_everyone'}),
    );
  }

  // Authentic Toki Rooms Tab
  Widget _buildRoomsTab() {
    return Column(
      children: [
        // Top filter & icons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Text('Recommend', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(width: 14),
              const Text('Video', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(width: 14),
              const Text('New', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const Spacer(),
              const Icon(Icons.search, color: Colors.black54, size: 24),
              const SizedBox(width: 12),
              const Icon(Icons.public, color: Colors.black54, size: 24),
              const SizedBox(width: 12),
              const Icon(Icons.add_box_outlined, color: Colors.black54, size: 24),
              const SizedBox(width: 12),
              const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 24),
            ],
          ),
        ),
        // Event Center banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF8E53), Color(0xFFFE6B8B)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('More', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.event_note, color: Colors.white, size: 36),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: _tokiRooms.length + 1, // Addition for Challenge Banner
            itemBuilder: (context, index) {
              if (index == 3) {
                // Peak Challenge Banner at position 3
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1E4C3),
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1501555088652-021dde106b6a?w=400'), // Adventure illustration mock
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PEAK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('CHALLENGE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                );
              }

              final itemIndex = index > 3 ? index - 1 : index;
              final r = _tokiRooms[itemIndex];

              return GestureDetector(
                onTap: () => _enterRoom(r['id'].toString(), r['title'].toString()),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          r['avatar'].toString(),
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r['title'].toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: Colors.teal, size: 14),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r['subtitle'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(r['badgeColor'] as int).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                r['badge'].toString(),
                                style: TextStyle(color: Color(r['badgeColor'] as int), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bar_chart, color: Color(0xFFFF7A30), size: 14),
                              Text(' ${r['views']}', style: const TextStyle(color: Color(0xFFFF7A30), fontSize: 11)),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _chats.length,
      itemBuilder: (_, idx) {
        final c = _chats[idx];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFF7A30),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(c['name'].toString(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            subtitle: Text(c['msg'].toString(), style: const TextStyle(color: Colors.black54)),
            trailing: Text(c['time'].toString(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrivateChatScreen(
                    peerName: c['name'].toString(),
                    peerEmoji: '🌸',
                    onJoinVoiceRoom: () {
                      Navigator.pop(context);
                      _enterRoom('welcome_everyone', c['name'].toString());
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 38,
            backgroundColor: Color(_avatars[_selectedAvatar]['bg'] as int),
            child: Text(_avatars[_selectedAvatar]['emoji'].toString(), style: const TextStyle(fontSize: 36)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(
            labelText: 'Your Name',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Select Avatar:', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_avatars.length, (i) {
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = i),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Color(_avatars[i]['bg'] as int),
                child: Text(_avatars[i]['emoji'].toString(), style: const TextStyle(fontSize: 22)),
              ),
            );
          }),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Text('🪙 My Coins:', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('$_coins', style: const TextStyle(color: Color(0xFFFF7A30), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => setState(() => _coins += 200),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A30),
                  foregroundColor: Colors.white,
                ),
                child: const Text('+200 Free'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
