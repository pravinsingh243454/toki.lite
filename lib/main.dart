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
        scaffoldBackgroundColor: const Color(0xFFF6F6F8),
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
  int _tabIndex = 0;
  int _homeFilter = 0;
  int _coins = 500;
  int _selectedAvatar = 0;
  final TextEditingController _nameController =
      TextEditingController(text: 'Pravin');

  final List _avatars = const [
    {'emoji': '😎', 'bg': 0xFFFFB74D},
    {'emoji': '👑', 'bg': 0xFFF48FB1},
    {'emoji': '🎧', 'bg': 0xFF90CAF9},
    {'emoji': '🔥', 'bg': 0xFFFF8A65},
    {'emoji': '🌸', 'bg': 0xFFCE93D8},
  ];

  final List _users = const [
    {
      'name': 'Riya Sharma',
      'age': '22',
      'vip': 'VIP5',
      'bio': 'Singing & late night gossips 🎶',
      'emoji': '🌸',
      'bg': 0xFFF48FB1,
      'room': 'toki_party_1',
      'isNew': false,
      'featured': true,
    },
    {
      'name': 'Aarav Singh',
      'age': '24',
      'vip': 'VIP2',
      'bio': 'Ludo King champion! Aao khelte hain 🎲',
      'emoji': '🎧',
      'bg': 0xFF90CAF9,
      'room': 'toki_ludo_1',
      'isNew': true,
      'featured': true,
    },
    {
      'name': 'Ananya ✨',
      'age': '21',
      'vip': 'VIP6',
      'bio': 'Shayari & dosti party room ❤️',
      'emoji': '👑',
      'bg': 0xFFCE93D8,
      'room': 'toki_party_1',
      'isNew': true,
      'featured': false,
    },
  ];

  final List _rooms = const [
    {
      'id': 'toki_party_1',
      'title': '🎉 Dil Se Dosti Party Room',
      'host': 'Riya Sharma',
      'count': '128',
      'tag': 'Party',
      'c1': 0xFF4B39EF,
      'c2': 0xFFFF7A30,
    },
    {
      'id': 'toki_ludo_1',
      'title': '🎲 Ludo & Masti Club',
      'host': 'Aarav Singh',
      'count': '84',
      'tag': 'Ludo',
      'c1': 0xFF00897B,
      'c2': 0xFF43A047,
    },
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

  void _enterRoom(String roomId) {
    final myName = _nameController.text.trim().isEmpty
        ? 'Pravin'
        : _nameController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartyRoomScreen(
          roomId: roomId,
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
            _enterRoom(u['room'].toString());
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
        backgroundColor: const Color(0xFF18181B),
        selectedItemColor: const Color(0xFFFF7A30),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Moments'),
          BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final filtered = _users.where((u) {
      if (_homeFilter == 1) return u['isNew'] == true;
      if (_homeFilter == 2) return u['featured'] == true;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          children: [
            _filterBtn('Recommend', 0),
            const SizedBox(width: 14),
            _filterBtn('New users', 1),
            const SizedBox(width: 14),
            _filterBtn('Featured', 2),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _sayHiToUser(_users[0]),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A65), Color(0xFFFF7043)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('💖 SoulLink',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Instant dost match',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _enterRoom('toki_party_1'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF4B39EF), Color(0xFF7C4DFF)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🎙️ Party Room',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(height: 4),
                      Text('9-Seat Live Voice',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...filtered.map((u) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(u['bg'] as int),
                    child: Text(u['emoji'].toString(),
                        style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u['name'].toString(),
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF80AB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('♀ ${u['age']}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('👑 ${u['vip']}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(u['bio'].toString(),
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _sayHiToUser(u),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A30),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('👋 Hi'),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _filterBtn(String label, int idx) {
    final active = _homeFilter == idx;
    return GestureDetector(
      onTap: () => setState(() => _homeFilter = idx),
      child: Text(
        label,
        style: TextStyle(
          fontSize: active ? 19 : 15,
          fontWeight: FontWeight.bold,
          color: active ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMomentsTab() {
    return TokiMomentsTab(
      userName: _nameController.text.trim().isEmpty
          ? 'Pravin'
          : _nameController.text.trim(),
      userEmoji: _avatars[_selectedAvatar]['emoji'].toString(),
      userBg: _avatars[_selectedAvatar]['bg'] as int,
      onSayHi: (name) => _sayHiToUser({
        'name': name,
        'room': 'toki_party_1',
      }),
    );
  }

  Widget _buildRoomsTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('Live Party Rooms',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._rooms.map((r) => GestureDetector(
              onTap: () => _enterRoom(r['id'].toString()),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(r['c1'] as int), Color(r['c2'] as int)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['title'].toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Host: ${r['host']}  •  🔥 ${r['count']} online',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            )),
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
            title: Text(c['name'].toString(),
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold)),
            subtitle: Text(c['msg'].toString(),
                style: const TextStyle(color: Colors.black54)),
            trailing: Text(c['time'].toString(),
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrivateChatScreen(
                    peerName: c['name'].toString(),
                    peerEmoji: '🌸',
                    onJoinVoiceRoom: () {
                      Navigator.pop(context);
                      _enterRoom('toki_party_1');
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
            child: Text(_avatars[_selectedAvatar]['emoji'].toString(),
                style: const TextStyle(fontSize: 36)),
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
        const Text('Select Avatar:',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_avatars.length, (i) {
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = i),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Color(_avatars[i]['bg'] as int),
                child: Text(_avatars[i]['emoji'].toString(),
                    style: const TextStyle(fontSize: 22)),
              ),
            );
          }),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Text('🪙 My Coins:',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('$_coins',
                  style: const TextStyle(
                      color: Color(0xFFFF7A30),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
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
