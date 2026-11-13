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
  static const String _agoraAppId = '7d9fb3e0517840d38e246fbb98315d22';

  int _tabIndex = 0;
  int _topSubTab = 0; // 0 = Recommend, 1 = New users, 2 = Featured
  int _selectedAvatar = 0;
  int _walletCoins = 5000;
  bool _dailyClaimed = false;
  int _unreadMessages = 99;

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

  final List _recommendUsers = const [
    {
      'name': 'neha',
      'age': '22',
      'vip': '',
      'featured': false,
      'bio': '441km • 1.5km',
      'emoji': '🌸',
      'bg': 0xFFF48FB1,
      'room': 'toki_party_1',
    },
    {
      'name': "Mrs. D'Souza 💖",
      'age': '21',
      'vip': 'VIP1',
      'featured': true,
      'bio': '1282km • "Pursuing esoteri..."',
      'emoji': '👓',
      'bg': 0xFF90CAF9,
      'room': 'toki_vip',
    },
    {
      'name': '💕miss__sonam_💕',
      'age': '20',
      'vip': '',
      'featured': false,
      'bio': '310km • Music & Late Night Talks',
      'emoji': '🦋',
      'bg': 0xFFCE93D8,
      'room': 'toki_friends',
    },
    {
      'name': 'Ritu RJ',
      'age': '22',
      'vip': 'VIP4',
      'featured': true,
      'bio': "You're gonna missing out o...",
      'emoji': '👑',
      'bg': 0xFFFFCC80,
      'room': 'toki_vip',
    },
    {
      'name': 'Harshita',
      'age': '18',
      'vip': '',
      'featured': true,
      'bio': '523km • Singing & Ludo Lover',
      'emoji': '🌺',
      'bg': 0xFFA5D6A7,
      'room': 'toki_party_1',
    },
  ];

  final List _hotRooms = const [
    {'name': 'toki_party_1', 'title': 'Masti & Singing Party Room', 'tag': 'LIVE', 'users': '24'},
    {'name': 'toki_friends', 'title': 'Late Night Adda & Ludo Club', 'tag': 'LUDO', 'users': '18'},
    {'name': 'toki_vip', 'title': 'VIP Golden Mic Lounge', 'tag': 'VIP', 'users': '32'},
  ];

  final List _moments = [
    {'user': 'Ritu RJ 👑', 'time': '2m ago', 'text': 'Aaj raat 9 baje VIP Ludo Tournament! Sab aa jao 🎲🔥', 'likes': 14},
    {'user': 'neha 🌸', 'time': '15m ago', 'text': 'Singing room mein naya gaana sunaya sabne, maza aa gaya 🎶💖', 'likes': 29},
  ];

  final List _chats = [
    {'name': 'Toki Official', 'msg': 'Welcome to toki.lite! Claim your +500 daily coins 🎁', 'time': 'Now'},
    {'name': 'neha 🌸', 'msg': 'Hi! Voice party room mein aao 👋', 'time': '2m'},
    {'name': 'Ritu RJ 👑', 'msg': 'Ludo khelein kya voice room mein?', 'time': '10m'},
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

  void _sayHiToUser(Map user) {
    setState(() {
      _chats.insert(0, {
        'name': user['name'].toString(),
        'msg': '👋 Hi ${user['name']}! Chalo voice room mein baat karte hain.',
        'time': 'Just now',
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('👋 ${user['name']} ko Hi bhej diya!'),
        action: SnackBarAction(
          label: 'Join Room',
          onPressed: () => _enterRoom(user['room'].toString()),
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
        backgroundColor: const Color(0xFF181818),
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
            icon: Icon(Icons.home_work_outlined),
            activeIcon: Icon(Icons.home_work_rounded),
            label: 'Rooms',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded),
                if (_unreadMessages > 0)
                  Positioned(
                    right: -10,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _unreadMessages >= 99 ? '99+' : '$_unreadMessages',
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
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
    List displayList;
    if (_topSubTab == 1) {
      displayList = _recommendUsers.reversed.toList();
    } else if (_topSubTab == 2) {
      displayList = _recommendUsers.where((u) => u['featured'] == true).toList();
    } else {
      displayList = _recommendUsers;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
          child: Row(
            children: [
              _topTabItem('Recommend', 0),
              const SizedBox(width: 12),
              _topTabItem('New users', 1),
              const SizedBox(width: 12),
              _topTabItem('Featured', 2),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _tabIndex = 2),
                icon: const Icon(Icons.search, color: Colors.black87, size: 22),
              ),
              const SizedBox(width: 10),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _claimBonus,
                icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 22),
                tooltip: 'Daily Coins & Rank',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _enterRoom('toki_soullink'),
                  child: Container(
                    height: 76,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B61FF), Color(0xFFA88BFF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('SoulLink',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('🔔 772 Online',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                    height: 76,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEC5FE8), Color(0xFFFF8AE2)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Video Room',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('🎙️ 3641 Online',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              ...displayList.take(3).map((u) => _buildUserCard(u)),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF90D5FF), Color(0xFFD6EEFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user, color: Color(0xFF1565C0), size: 34),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('फ्रॉड चेतावनी',
                              style: TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('अजनबियों को OTP या पैसे न भेजें • सुरक्षित रहें',
                              style: TextStyle(
                                  color: Color(0xFF1565C0), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ...displayList.skip(3).map((u) => _buildUserCard(u)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topTabItem(String title, int index) {
    final isSelected = _topSubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _topSubTab = index),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSelected ? 19 : 14,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildUserCard(Map u) {
    final vip = u['vip'].toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Color(u['bg'] as int),
                child: Text(u['emoji'].toString(),
                    style: const TextStyle(fontSize: 28)),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u['name'].toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF80AB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('♀ ${u['age']}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    if (vip.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('👑 $vip',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  u['bio'].toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _sayHiToUser(u),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFF6D00)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('👋 Hi',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
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
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Share your moment...',
                    filled: true,
                    fillColor: Colors.white,
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
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment:
