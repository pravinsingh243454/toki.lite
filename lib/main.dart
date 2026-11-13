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
        scaffoldBackgroundColor: const Color(0xFFFCF6F2),
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
  int _tabIndex = 2; // Opens directly on Toki Rooms screen
  int _roomFilter = 0; // 0: Recommend, 1: Video, 2: New, 3: Me
  int _homeFilter = 0;
  int _coins = 500;
  int _selectedAvatar = 0;
  bool _searching = false;
  String _searchQuery = '';
  bool _bonusClaimed = false;

  final TextEditingController _nameController =
      TextEditingController(text: 'Pravin');
  final TextEditingController _searchController = TextEditingController();

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
      'room': 'welcome_everyone',
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
      'room': 'sb_agency_14',
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
      'room': 'dwarka_nath',
      'isNew': true,
      'featured': false,
    },
  ];

  final List _tokiRooms = [
    {
      'title': 'welcome everyone',
      'id': 'welcome_everyone',
      'subtitle': '2187 a💑👩‍❤️‍👩🎁🎁🎁🎁👍',
      'badge': 'Music',
      'views': '95',
      'emoji': '👩🏻',
      'bg1': 0xFFF8BBD0,
      'bg2': 0xFFF48FB1,
      'badgeColor': 0xFF2979FF,
      'cat': 'Video',
      'isMine': false,
    },
    {
      'title': 'SB AGENCY 14 🏵️',
      'id': 'sb_agency_14',
      'subtitle': 'Welcome to the room, let\'s chat~',
      'badge': 'Friendship',
      'views': '43',
      'emoji': '🪷',
      'bg1': 0xFFFFE0B2,
      'bg2': 0xFFFFCC80,
      'badgeColor': 0xFFFF4081,
      'cat': 'Recommend',
      'isMine': false,
    },
    {
      'title': 'IHGS Thank you so m 🏵️',
      'id': 'ihgs_room',
      'subtitle': 'Everyone has same Eyes but η...',
      'badge': 'Families',
      'views': '42',
      'emoji': '🧔🏻‍♂️',
      'bg1': 0xFFCFD8DC,
      'bg2': 0xFF90A4AE,
      'badgeColor': 0xFF00C853,
      'cat': 'New',
      'isMine': false,
    },
    {
      'title': '🙏 Dwarka Nath ✓✓✓✓ 🏵️',
      'id': 'dwarka_nath',
      'subtitle': 'Radhe Radhe ji 🙏',
      'badge': 'Chat',
      'views': '32',
      'emoji': '💃🏻',
      'bg1': 0xFFFFF59D,
      'bg2': 0xFFFFD54F,
      'badgeColor': 0xFFAA00FF,
      'cat': 'Video',
      'isMine': false,
    },
    {
      'title': '🎂 HBD Alisha 😘🎂 🏵️',
      'id': 'hbd_alisha',
      'subtitle': '🎂 Happy Birthday Alisha! 🎂 (13...',
      'badge': 'Friendship',
      'views': '23',
      'emoji': '🎂',
      'bg1': 0xFFFFCDD2,
      'bg2': 0xFFE57373,
      'badgeColor': 0xFFFF4081,
      'cat': 'New',
      'isMine': false,
    },
    {
      'title': 'R 🙏 😃 🏵️',
      'id': 'r_room',
      'subtitle': 'Dil se dosti ❤️ ap ayiye th...',
      'badge': 'Social',
      'views': '18',
      'emoji': '💐',
      'bg1': 0xFFC8E6C9,
      'bg2': 0xFF81C784,
      'badgeColor': 0xFF00C853,
      'cat': 'Recommend',
      'isMine': false,
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
    _searchController.dispose();
    super.dispose();
  }

  void _enterRoom(String roomId, String title) {
    final myName = _nameController.text.trim().isEmpty
        ? 'Pravin'
        : _nameController.text.trim();
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

  void _openCreateRoomDialog() {
    final titleCtrl = TextEditingController();
    String selectedTag = 'Music';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('🎙️ Create Live Party Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Room ka naam likhein...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Music', 'Friendship', 'Chat', 'Families'].map((t) {
                  final sel = selectedTag == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: sel,
                    selectedColor: const Color(0xFFFF7A30),
                    onSelected: (_) => setDialogState(() => selectedTag = t),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A30),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final title = titleCtrl.text.trim().isEmpty
                    ? '${_nameController.text}\'s Party Room'
                    : titleCtrl.text.trim();
                final newId = 'room_${DateTime.now().millisecondsSinceEpoch}';
                setState(() {
                  _tokiRooms.insert(0, {
                    'title': title,
                    'id': newId,
                    'subtitle': 'Host: ${_nameController.text} • Live Now 🎙️',
                    'badge': selectedTag,
                    'views': '1',
                    'emoji': _avatars[_selectedAvatar]['emoji'],
                    'bg1': 0xFFFFCC80,
                    'bg2': 0xFFFF7A30,
                    'badgeColor': 0xFFFF7A30,
                    'cat': 'New',
                    'isMine': true,
                  });
                });
                Navigator.pop(ctx);
                _enterRoom(newId, title);
              },
              child: const Text('Go Live'),
            ),
          ],
        ),
      ),
    );
  }

  void _claimEventBonus(String title) {
    if (_bonusClaimed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Aap aaj ka Event Bonus le chuke hain!')),
      );
      return;
    }
    setState(() {
      _coins += 300;
      _bonusClaimed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🎉 $title: +300 Free Coins mile! (Total: $_coins 🪙)')),
    );
  }

  void _showLeaderboard() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆 Weekly Top Party Rooms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Colors.amber, child: Text('1')),
              title: const Text('welcome everyone'),
              subtitle: const Text('2187 Gift Points'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _enterRoom('welcome_everyone', 'welcome everyone');
                },
                child: const Text('Join'),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Colors.grey, child: Text('2')),
              title: const Text('SB AGENCY 14 🏵️'),
              subtitle: const Text('1540 Gift Points'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _enterRoom('sb_agency_14', 'SB AGENCY 14 🏵️');
                },
                child: const Text('Join'),
              ),
            ),
          ],
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
        backgroundColor: const Color(0xFF1E1E24),
        selectedItemColor: const Color(0xFFFF7A30),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.blur_circular), label: 'Moments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Rooms'),
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
                    child: Text('99+',
                        style: TextStyle(color: Colors.white, fontSize: 7)),
                  ),
                ),
              ],
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Me'),
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
            _homeFilterBtn('Recommend', 0),
            const SizedBox(width: 14),
            _homeFilterBtn('New users', 1),
            const SizedBox(width: 14),
            _homeFilterBtn('Featured', 2),
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
                onTap: () =>
                    _enterRoom('welcome_everyone', 'welcome everyone'),
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

  Widget _homeFilterBtn(String label, int idx) {
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
      onSayHi: (name) =>
          _sayHiToUser({'name': name, 'room': 'welcome_everyone'}),
    );
  }

  Widget _roomFilterBtn(String label, int idx) {
    final active = _roomFilter == idx;
    return GestureDetector(
      onTap: () => setState(() => _roomFilter = idx),
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(
          label,
          style: TextStyle(
            fontSize: active ? 20 : 15,
            fontWeight: FontWeight.bold,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomsTab() {
    final visibleRooms = _tokiRooms.where((r) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final t = r['title'].toString().toLowerCase();
        final s = r['subtitle'].toString().toLowerC
