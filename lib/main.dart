import 'dart:math';
import 'package:flutter/material.dart';

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
      home: const TokiHomeShell(),
    );
  }
}

class TokiHomeShell extends StatefulWidget {
  const TokiHomeShell({super.key});

  @override
  State<TokiHomeShell> createState() => _TokiHomeShellState();
}

class _TokiHomeShellState extends State<TokiHomeShell> {
  int _tab = 0;
  int _homeFilter = 0;
  int _coins = 500;
  int _avatarIdx = 0;
  final TextEditingController _nameCtrl = TextEditingController(text: 'Pravin');

  final List _avatars = const [
    {'e': '😎', 'bg': 0xFFFFB74D},
    {'e': '👑', 'bg': 0xFFF48FB1},
    {'e': '🎧', 'bg': 0xFF90CAF9},
    {'e': '🔥', 'bg': 0xFFFF8A65},
    {'e': '🌸', 'bg': 0xFFCE93D8},
  ];

  final List _users = const [
    {
      'name': 'Riya Sharma',
      'age': '22',
      'vip': 'VIP5',
      'bio': 'Singing & late night gossips 🎶',
      'e': '🌸',
      'bg': 0xFFF48FB1,
      'room': 'Dil Se Dosti Party',
      'isNew': false,
      'feat': true,
    },
    {
      'name': 'Aarav Singh',
      'age': '24',
      'vip': 'VIP2',
      'bio': 'Ludo King champion! Aao khelte hain 🎲',
      'e': '🎧',
      'bg': 0xFF90CAF9,
      'room': 'Ludo & Masti Club',
      'isNew': true,
      'feat': true,
    },
    {
      'name': 'Ananya ✨',
      'age': '21',
      'vip': 'VIP6',
      'bio': 'Shayari & dosti party room ❤️',
      'e': '👑',
      'bg': 0xFFCE93D8,
      'room': 'Dil Se Dosti Party',
      'isNew': true,
      'feat': false,
    },
  ];

  final List _moments = [
    {
      'user': 'Thakurain 🐰',
      'e': '👑',
      'bg': 0xFFF48FB1,
      'text': 'jisko dost banna ho msg kro ✨',
      'tag': '# Selfie',
      'likes': 44,
      'liked': false,
    },
    {
      'user': 'shivani ❤️',
      'e': '🌸',
      'bg': 0xFFCE93D8,
      'text': 'Aaj party room mein gaana sunate hain 🎶',
      'tag': '# Love',
      'likes': 29,
      'liked': false,
    },
  ];

  final List _chats = [
    {'name': 'Riya Sharma', 'msg': 'Hi! Party room mein aao na 🎙️', 'time': 'Now'},
    {'name': 'Toki Official', 'msg': 'Welcome! 500 Free Coins mile 🎉', 'time': 'Today'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _openRoom(String title) {
    final myName = _nameCtrl.text.trim().isEmpty ? 'Pravin' : _nameCtrl.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveRoomPage(
          roomTitle: title,
          myName: myName,
          myEmoji: _avatars[_avatarIdx]['e'].toString(),
          myBg: _avatars[_avatarIdx]['bg'] as int,
        ),
      ),
    );
  }

  void _openChat(String name, String roomTitle) {
    setState(() {
      _chats.insert(0, {'name': name, 'msg': '👋 Hi bheja! Tap karein', 'time': 'Now'});
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DirectChatPage(
          peerName: name,
          onJoinRoom: () {
            Navigator.pop(context);
            _openRoom(roomTitle);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _homeView(),
      _momentsView(),
      _roomsView(),
      _messagesView(),
      _meView(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_tab]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
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

  Widget _homeView() {
    final list = _users.where((u) {
      if (_homeFilter == 1) return u['isNew'] == true;
      if (_homeFilter == 2) return u['feat'] == true;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          children: [
            _tabChip('Recommend', 0),
            const SizedBox(width: 14),
            _tabChip('New users', 1),
            const SizedBox(width: 14),
            _tabChip('Featured', 2),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _openChat('Riya Sharma', 'Dil Se Dosti Party'),
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
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _openRoom('Dil Se Dosti Party'),
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
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...list.map((u) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(u['bg'] as int),
                    child: Text(u['e'].toString(),
                        style: const TextStyle(fontSize: 25)),
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
                        Text('♀ ${u['age']}  •  👑 ${u['vip']}',
                            style: const TextStyle(
                                color: Color(0xFFFF7A30),
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                        Text(u['bio'].toString(),
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        _openChat(u['name'].toString(), u['room'].toString()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A30),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('👋 Hi'),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _tabChip(String label, int idx) {
    final sel = _homeFilter == idx;
    return GestureDetector(
      onTap: () => setState(() => _homeFilter = idx),
      child: Text(
        label,
        style: TextStyle(
          fontSize: sel ? 19 : 15,
          fontWeight: FontWeight.bold,
          color: sel ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  Widget _momentsView() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('Moments Feed',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._moments.map((m) {
          final liked = m['liked'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(m['bg'] as int),
                      child: Text(m['e'].toString()),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(m['user'].toString(),
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () => _openChat(
                          m['user'].toString(), 'Dil Se Dosti Party'),
                      child: const Text('👋 Hi',
                          style: TextStyle(color: Color(0xFFFF7A30))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(m['text'].toString(),
                    style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(m['tag'].toString(),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          m['liked'] = !liked;
                          m['likes'] = (m['likes'] as int) + (liked ? -1 : 1);
                        });
                      },
                      icon: Icon(
                        liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: liked ? const Color(0xFFFF7A30) : Colors.grey,
                        size: 18,
                      ),
                    ),
                    Text('${m['likes']}',
                        style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _roomsView() {
    final rooms = [
      {'title': '🎉 Dil Se Dosti Party', 'host': 'Riya Sharma', 'c1': 0xFF4B39EF, 'c2': 0xFFFF7A30},
      {'title': '🎲 Ludo & Masti Club', 'host': 'Aarav Singh', 'c1': 0xFF00897B, 'c2': 0xFF43A047},
    ];
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('Live Party Rooms',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...rooms.map((r) => GestureDetector(
              onTap: () => _openRoom(r['title'].toString()),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(r['c1'] as int), Color(r['c2'] as int)]),
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
                    const SizedBox(height: 4),
                    Text('Host: ${r['host']}  •  9 Seats Open',
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _messagesView() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _chats.length,
      itemBuilder: (_, i) {
        final c = _chats[i];
        return Card(
          color: Colors.white,
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
            onTap: () =>
                _openChat(c['name'].toString(), 'Dil Se Dosti Party'),
          ),
        );
      },
    );
  }

  Widget _meView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Color(_avatars[_avatarIdx]['bg'] as int),
            child: Text(_avatars[_avatarIdx]['e'].toString(),
                style: const TextStyle(fontSize: 34)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameCtrl,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(
            labelText: 'Your Name',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_avatars.length, (i) {
            return GestureDetector(
              onTap: () => setState(() => _avatarIdx = i),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Color(_avatars[i]['bg'] as int),
                child: Text(_avatars[i]['e'].toString(),
                    style: const TextStyle(fontSize: 20)),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Text('🪙 Coins:',
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold)),
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
                    foregroundColor: Colors.white),
                child: const Text('+200'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DirectChatPage extends StatefulWidget {
  final String peerName;
  final VoidCallback onJoinRoom;

  const DirectChatPage({
    super.key,
    required this.peerName,
    required this.onJoinRoom,
  });

  @override
  State<DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<DirectChatPage> {
  final TextEditingController _ctrl = TextEditingController();
  final List _msgs =
    
