import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_screen.dart';
import 'me_screen.dart';
import 'room_screen.dart';
import 'chat_screen.dart';
import 'home_tabs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TokiLiteApp());
}

class TokiLiteApp extends StatefulWidget {
  const TokiLiteApp({super.key});
  @override
  State<TokiLiteApp> createState() => _TokiLiteAppState();
}

class _TokiLiteAppState extends State<TokiLiteApp> {
  bool _loggedIn = false;
  String _userName = 'Pravin', _phone = '9303323525', _lang = 'Hindi';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'toki.lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFFFF7A30),
        scaffoldBackgroundColor: const Color(0xFFFCF6F2),
      ),
      home: _loggedIn
          ? TokiMainShell(
              initialName: _userName,
              phone: _phone,
              initialLang: _lang,
              onLogout: () => setState(() => _loggedIn = false),
            )
          : AuthScreen(
              onLoginSuccess: (name, phone, lang) => setState(() {
                _userName = name;
                _phone = phone;
                _lang = lang;
                _loggedIn = true;
              }),
            ),
    );
  }
}

class TokiMainShell extends StatefulWidget {
  final String initialName, phone, initialLang;
  final VoidCallback onLogout;
  const TokiMainShell({
    super.key,
    required this.initialName,
    required this.phone,
    required this.initialLang,
    required this.onLogout,
  });

  @override
  State<TokiMainShell> createState() => _TokiMainShellState();
}

class _TokiMainShellState extends State<TokiMainShell> {
  int _tab = 0, _homeFilter = 0, _roomFilter = 0, _coins = 500, _avatar = 0;
  bool _searching = false, _bonusClaimed = false;
  String _query = '';
  late String _myName, _lang;
  final _searchCtrl = TextEditingController();

  final List _avatars = const [
    {'e': '😎', 'bg': 0xFFFFB74D},
    {'e': '👑', 'bg': 0xFFF48FB1},
    {'e': '🎧', 'bg': 0xFF90CAF9},
    {'e': '🔥', 'bg': 0xFFFF8A65},
    {'e': '🌸', 'bg': 0xFFCE93D8},
    {'e': '🦁', 'bg': 0xFFA5D6A7},
  ];

  final List _users = const [
    {'name': 'Riya Sharma', 'vip': 'VIP5', 'bio': 'Singing & late night gossips 🎶', 'e': '🌸', 'bg': 0xFFF48FB1, 'room': 'welcome everyone 🎶', 'new': false, 'feat': true},
    {'name': 'Aarav Singh', 'vip': 'VIP2', 'bio': 'Ludo King champion! Aao khelte hain 🎲', 'e': '🎧', 'bg': 0xFF90CAF9, 'room': 'SB AGENCY 14 🏵️', 'new': true, 'feat': true},
    {'name': 'Ananya ✨', 'vip': 'VIP6', 'bio': 'Shayari & dosti party room ❤️', 'e': '👑', 'bg': 0xFFCE93D8, 'room': '🙏 Dwarka Nath ✓✓✓✓', 'new': true, 'feat': false},
  ];

  final List _moments = [
    {'name': 'Riya Sharma', 'e': '🌸', 'bg': 0xFFF48FB1, 'time': '2m ago', 'tag': '#MusicParty', 'text': 'Aaj raat party room mein gaane aur masti hogi! Sabhi dost aao 🎙️🎶', 'likes': 48, 'liked': false},
    {'name': 'Aarav Singh', 'e': '🎧', 'bg': 0xFF90CAF9, 'time': '15m ago', 'tag': '#LudoKing', 'text': 'Ludo race mein kaun mujhe hara sakta hai? Room mein challenge karo 🎲🔥', 'likes': 31, 'liked': false},
  ];

  final List _rooms = [
    {'title': 'welcome everyone', 'sub': '2187 a💑👩‍❤️‍👩🎁🎁🎁🎁👍', 'tag': 'Music', 'views': '95', 'e': '👩🏻', 'c1': 0xFFF8BBD0, 'c2': 0xFFF48FB1, 'tc': 0xFF2979FF, 'cat': 'Video', 'mine': false},
    {'title': 'SB AGENCY 14 🏵️', 'sub': 'Welcome to the room, let\'s chat~', 'tag': 'Friendship', 'views': '43', 'e': '🪷', 'c1': 0xFFFFE0B2, 'c2': 0xFFFFCC80, 'tc': 0xFFFF4081, 'cat': 'Recommend', 'mine': false},
    {'title': '🙏 Dwarka Nath ✓✓✓✓', 'sub': 'Radhe Radhe ji 🙏', 'tag': 'Chat', 'views': '32', 'e': '💃🏻', 'c1': 0xFFFFF59D, 'c2': 0xFFFFD54F, 'tc': 0xFFAA00FF, 'cat': 'Video', 'mine': false},
  ];

  final List _chats = [
    {'name': 'Riya Sharma', 'e': '🌸', 'msg': 'Hi! Party room mein aao na 🎙️', 'time': 'Just now'},
    {'name': 'Toki Official', 'e': '👑', 'msg': 'Welcome to toki.lite! 500 Free Coins mile 🎉', 'time': 'Today'},
  ];

  @override
  void initState() {
    super.initState();
    _myName = widget.initialName;
    _lang = widget.initialLang;
    FirebaseFirestore.instance.collection('users').doc(widget.phone).snapshots().listen((doc) {
      if (doc.exists && mounted) {
        final d = doc.data()!;
        setState(() {
          _coins = (d['coins'] ?? 500) as int;
          _myName = (d['name'] ?? _myName).toString();
          _avatar = (d['avatar'] ?? _avatar) as int;
        });
      }
    });
  }

  Future<void> _syncUser(Map<String, dynamic> f) =>
      FirebaseFirestore.instance.collection('users').doc(widget.phone).set(f, SetOptions(merge: true));

  void _enterRoom(String title) {
    final av = _avatars[_avatar % _avatars.length];
    Navigator.push(context, MaterialPageRoute(builder: (_) => PartyRoomScreen(
      roomTitle: title,
      userName: _myName,
      userEmoji: av['e'].toString(),
      userBg: av['bg'] as int,
      coins: _coins,
      onCoins: (v) { setState(() => _coins = v); _syncUser({'coins': v}); },
    )));
  }

  void _sayHi(String name, String emoji, String room) {
    setState(() => _chats.insert(0, {'name': name, 'e': emoji, 'msg': '👋 Aapne Hi bheja!', 'time': 'Now'}));
    Navigator.push(context, MaterialPageRoute(builder: (_) => PrivateChatScreen(
      peerName: name,
      peerEmoji: emoji,
      onJoinRoom: () { Navigator.pop(context); _enterRoom(room); },
    )));
  }

  void _postMoment() {
    final c = TextEditingController();
    final av = _avatars[_avatar % _avatars.length];
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('🪐 Post New Moment'),
      content: TextField(controller: c, maxLines: 3, decoration: const InputDecoration(hintText: 'Dil ki baat likhein...', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
          onPressed: () {
            if (c.text.trim().isNotEmpty) {
              setState(() => _moments.insert(0, {'name': _myName, 'e': av['e'], 'bg': av['bg'], 'time': 'Just now', 'tag': '#TokiStar', 'text': c.text.trim(), 'likes': 1, 'liked': true}));
            }
            Navigator.pop(ctx);
          },
          child: const Text('Post'),
        ),
      ],
    ));
  }

  void _createRoom() {
    final c = TextEditingController();
    final av = _avatars[_avatar % _avatars.length];
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('🎙️ Create Live Room'),
      content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Room ka naam...', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
          onPressed: () {
            final t = c.text.trim().isEmpty ? '$_myName\'s Party Room' : c.text.trim();
            setState(() => _rooms.insert(0, {'title': t, 'sub': 'Host: $_myName • Live 🎙️', 'tag': 'Music', 'views': '1', 'e': av['e'], 'c1': 0xFFFFCC80, 'c2': 0xFFFF7A30, 'tc': 0xFFFF7A30, 'cat': 'New', 'mine': true}));
            Navigator.pop(ctx);
            _enterRoom(t);
          },
          child: const Text('Go Live'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TokiHomeTabs.homeTab(users: _users, homeFilter: _homeFilter, onFilter: (v) => setState(() => _homeFilter = v), onSayHi: _sayHi, onEnterRoom: _enterRoom),
      TokiHomeTabs.momentsTab(moments: _moments, onPostMoment: _postMoment, onToggleLike: (i, liked) => setState(() { _moments[i]['liked'] = !liked; _moments[i]['likes'] = (_moments[i]['likes'] as int) + (liked ? -1 : 1); }), onSayHi: _sayHi),
      TokiHomeTabs.roomsTab(
        rooms: _rooms, roomFilter: _roomFilter, searching: _searching, query: _query, searchCtrl: _searchCtrl, bonusClaimed: _bonusClaimed, coins: _coins,
        onFilter: (v) => setState(() => _roomFilter = v),
        onToggleSearch: () => setState(() { _searching = !_searching; _query = ''; _searchCtrl.clear(); }),
        onQueryChanged: (v) => setState(() => _query = v),
        onCreateRoom: _createRoom,
        onClaimBonus: () {
          if (!_bonusClaimed) { final u = _coins + 300; setState(() { _coins = u; _bonusClaimed = true; }); _syncUser({'coins': u}); }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🪙 Total Coins: $_coins')));
        },
        onEnterRoom: _enterRoom,
      ),
      ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _chats.length,
        itemBuilder: (_, i) => Card(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFFFF7A30), child: Text(_chats[i]['e'].toString())),
            title: Text(_chats[i]['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_chats[i]['msg'].toString()),
            onTap: () => _sayHi(_chats[i]['name'].toString(), _chats[i]['e'].toString(), 'welcome everyone 🎶'),
          ),
        ),
      ),
      TokiMeScreen(
        userName: _myName, phone: widget.phone, lang: _lang, coins: _coins, selectedAvatar: _avatar,
        onNameChanged: (n) { setState(() => _myName = n); _syncUser({'name': n}); },
        onAvatarChanged: (idx) { setState(() => _avatar = idx); _syncUser({'avatar': idx}); },
        onCoinsChanged: (c) { setState(() => _coins = c); _syncUser({'coins': c}); },
        onLangChanged: (l) { setState(() => _lang = l); _syncUser({'lang': l}); },
        onLogout: widget.onLogout,
      ),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E24),
        selectedItemColor: const Color(0xFFFF7A30),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Moments'),
          BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
