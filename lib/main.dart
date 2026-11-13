import 'package:flutter/material.dart';
import 'room_screen.dart';

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
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4B39EF),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4B39EF),
          secondary: Color(0xFFFF7A30),
        ),
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
  static const String _agoraAppId = '7d9fb3e0517840d38e246fbb98315d22';

  int _tabIndex = 0;
  int _selectedAvatar = 0;
  int _walletCoins = 5000;
  bool _dailyClaimed = false;
  int _unreadMessages = 3;

  final TextEditingController _nameController =
      TextEditingController(text: 'Pravin');
  final TextEditingController _roomController =
      TextEditingController(text: 'toki_party_1');
  final TextEditingController _momentController = TextEditingController();

  final List _avatars = const [
    {'emoji': '😎', 'bg': 0xFF4B39EF},
    {'emoji': '👑', 'bg': 0xFFD97706},
    {'emoji': '🦊', 'bg': 0xFFEA580C},
    {'emoji': '🎧', 'bg': 0xFF7C3AED},
    {'emoji': '🦋', 'bg': 0xFFDB2777},
    {'emoji': '🦁', 'bg': 0xFFCA8A04},
    {'emoji': '🚀', 'bg': 0xFF0284C7},
    {'emoji': '💖', 'bg': 0xFFE11D48},
  ];

  final List _hotRooms = const [
    {'name': 'toki_party_1', 'title': 'Masti & Singing Party Room', 'tag': 'LIVE', 'users': '24'},
    {'name': 'toki_friends', 'title': 'Late Night Adda & Ludo Club', 'tag': 'LUDO', 'users': '18'},
    {'name': 'toki_vip', 'title': 'VIP Golden Mic Lounge', 'tag': 'VIP', 'users': '32'},
  ];

  final List _moments = [
    {'user': 'Aarav 👑', 'time': '2m ago', 'text': 'Aaj raat 9 baje VIP Ludo Tournament! Sab aa jao 🎲🔥', 'likes': 14},
    {'user': 'Priya 🦋', 'time': '15m ago', 'text': 'Singing room mein naya gaana sunaya sabne, maza aa gaya 🎶💖', 'likes': 29},
  ];

  final List _chats = [
    {'name': 'Toki Official', 'msg': 'Welcome to toki.lite! Claim your +500 daily coins 🎁', 'time': 'Now'},
    {'name': 'Aarav 👑', 'msg': 'Bhai toki_party_1 room mein aaja jaldi!', 'time': '5m'},
    {'name': 'Priya 🦋', 'msg': 'Ludo khelein kya voice room mein?', 'time': '12m'},
  ];

  void _enterRoom([String? customRoom]) {
    final roomName = customRoom ?? _roomController.text.trim();
    if (roomName.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveRoomScreen(
          appId: _agoraAppId,
          token: '',
          channelName: roomName,
          userName: _nameController.text.trim().isEmpty
              ? 'User'
              : _nameController.text.trim(),
          avatarIndex: _selectedAvatar,
          initialCoins: _walletCoins,
        ),
      ),
    );
  }

  void _claimBonus() {
    if (_dailyClaimed) return;
    setState(() {
      _walletCoins += 500;
      _dailyClaimed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 +500 Daily Bonus Coins mil gaye!')),
    );
  }

  void _postMoment() {
    final txt = _momentController.text.trim();
    if (txt.isEmpty) return;
    _momentController.clear();
    setState(() {
      _moments.insert(0, {
        'user': '${_nameController.text.trim()} ${_avatars[_selectedAvatar]['emoji']}',
        'time': 'Just now',
        'text': txt,
        'likes': 1,
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _momentController.dispose();
    super.dispose();
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
        onTap: (i) {
          setState(() {
            _tabIndex = i;
            if (i == 3) _unreadMessages = 0;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFFFF7A30),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.star_border_rounded),
            activeIcon: Icon(Icons.star_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Moments',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: 'Rooms',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded),
                if (_unreadMessages > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_unreadMessages',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Me',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('toki.lite',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: _claimBonus,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _dailyClaimed ? '🪙 $_walletCoins' : '🎁 +500 Free',
                  style: const TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4B39EF), Color(0xFFFF7A30)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.casino, size: 38, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Toki Ludo & Voice Party',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('1-Tap mein doston ke saath khelein & baatein karein',
                        style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _enterRoom('toki_party_1'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Play'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('🔥 Popular Party Rooms',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._hotRooms.map(
          (room) => Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF4B39EF),
                child: Icon(Icons.headset_mic, color: Colors.white),
              ),
              title: Text(room['title'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('👤 ${room['users']} Online • ${room['name']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(room['tag'].toString(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              onTap: () => _enterRoom(room['name'].toString()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMomentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _momentController,
                  decoration: InputDecoration(
                    hintText: 'Share your moment...',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _postMoment,
                icon: const Icon(Icons.send, color: Color(0xFFFF7A30)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _moments.length,
            itemBuilder: (_, idx) {
              final m = _moments[idx];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m['user'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(m['time'].toString(),
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(m['text'].toString()),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => m['likes'] = (m['likes'] as int) + 1),
                        child: Text('❤️ ${m['likes']} Likes',
                            style: const TextStyle(color: Colors.pinkAccent, fontSize: 12)),
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

  Widget _buildRoomsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('🎙️ Create / Join Room',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _roomController,
            decoration: InputDecoration(
              labelText: 'Room ID / Name',
              prefixIcon: const Icon(Icons.meeting_room),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _enterRoom(),
            icon: const Icon(Icons.mic),
            label: const Text('Start My Live Room',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A30),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _chats.length,
      itemBuilder: (_, idx) {
        final c = _chats[idx];
        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF4B39EF),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(c['name'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(c['msg'].toString()),
            trailing: Text(c['time'].toString(),
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
          decoration: const InputDecoration(
            labelText: 'Your Profile Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Choose Your Avatar:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 54,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _avatars.length,
            itemBuilder: (_, idx) {
              final item = _avatars[idx];
              final isSel = _selectedAvatar == idx;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = idx),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSel ? const Color(0xFFFF7A30) : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(item['bg'] as int),
                    child: Text(item['emoji'].toString(),
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        ListTile(
          tileColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.monetization_on, color: Colors.amber),
          title: const Text('My Coins Wallet'),
          trailing: Text('🪙 $_walletCoins',
              style: const TextStyle(
                  color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}
