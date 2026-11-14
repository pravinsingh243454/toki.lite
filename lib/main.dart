import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_screen.dart';
import 'me_screen.dart';
import 'room_screen.dart';
import 'chat_screen.dart';

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
  String _userName = 'Pravin';
  String _phone = '9303323525';
  String _lang = 'Hindi';

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
              onLoginSuccess: (name, phone, lang) {
                setState(() {
                  _userName = name;
                  _phone = phone;
                  _lang = lang;
                  _loggedIn = true;
                });
              },
            ),
    );
  }
}

class TokiMainShell extends StatefulWidget {
  final String initialName;
  final String phone;
  final String initialLang;
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
  late String _myName;
  late String _lang;
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
    {'title': 'IHGS Thank you so m 🏵️', 'sub': 'Everyone has same Eyes but...', 'tag': 'Families', 'views': '42', 'e': '🧔🏻‍♂️', 'c1': 0xFFCFD8DC, 'c2': 0xFF90A4AE, 'tc': 0xFF00C853, 'cat': 'New', 'mine': false},
    {'title': '🙏 Dwarka Nath ✓✓✓✓', 'sub': 'Radhe Radhe ji 🙏', 'tag': 'Chat', 'views': '32', 'e': '💃🏻', 'c1': 0xFFFFF59D, 'c2': 0xFFFFD54F, 'tc': 0xFFAA00FF, 'cat': 'Video', 'mine': false},
    {'title': '🎂 HBD Alisha 😘🎂', 'sub': 'Happy Birthday Alisha! 🎂', 'tag': 'Friendship', 'views': '23', 'e': '🎂', 'c1': 0xFFFFCDD2, 'c2': 0xFFE57373, 'tc': 0xFFFF4081, 'cat': 'New', 'mine': false},
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
    _listenUserFromFirestore();
  }

  void _listenUserFromFirestore() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.phone)
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _coins = (data['coins'] ?? 500) as int;
          _myName = (data['name'] ?? _myName).toString();
          _avatar = (data['avatar'] ?? _avatar) as int;
        });
      }
    });
  }

  Future<void> _syncUser(Map<String, dynamic> fields) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.phone)
        .set(fields, SetOptions(merge: true));
  }

  void _enterRoom(String title) {
    final av = _avatars[_avatar % _avatars.length];
    Navigator.push(context, MaterialPageRoute(builder: (_) => PartyRoomScreen(
      roomTitle: title,
      userName: _myName,
      userEmoji: av['e'].toString(),
      userBg: av['bg'] as int,
      coins: _coins,
      onCoins: (v) {
        setState(() => _coins = v);
        _syncUser({'coins': v});
      },
    )));
  }

  void _openChat(String name, String emoji, String roomTitle) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PrivateChatScreen(
      peerName: name,
      peerEmoji: emoji,
      onJoinRoom: () {
        Navigator.pop(context);
        _enterRoom(roomTitle);
      },
    )));
  }

  void _sayHi(String name, String emoji, String room) {
    setState(() => _chats.insert(0, {'name': name, 'e': emoji, 'msg': '👋 Aapne Hi bheja! Tap karke chat karein', 'time': 'Now'}));
    _openChat(name, emoji, room);
  }

  void _postMoment() {
    final c = TextEditingController();
    final av = _avatars[_avatar % _avatars.length];
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('🪐 Post New Moment'),
      content: TextField(controller: c, maxLines: 3, decoration: const InputDecoration(hintText: 'Apne dil ki baat likhein...', border: OutlineInputBorder())),
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
      content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Room ka naam likhein...', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
          onPressed: () {
            final t = c.text.trim().isEmpty ? '$_myName\'s Party Room' : c.text.trim();
            setState(() => _rooms.insert(0, {'title': t, 'sub': 'Host: $_myName • Live Now 🎙️', 'tag': 'Music', 'views': '1', 'e': av['e'], 'c1': 0xFFFFCC80, 'c2': 0xFFFF7A30, 'tc': 0xFFFF7A30, 'cat': 'New', 'mine': true}));
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
      _homeTab(),
      _momentsTab(),
      _roomsTab(),
      _messagesTab(),
      TokiMeScreen(
        userName: _myName,
        phone: widget.phone,
        lang: _lang,
        coins: _coins,
        selectedAvatar: _avatar,
        onNameChanged: (n) {
          setState(() => _myName = n);
          _syncUser({'name': n});
        },
        onAvatarChanged: (idx) {
          setState(() => _avatar = idx);
          _syncUser({'avatar': idx});
        },
        onCoinsChanged: (c) {
          setState(() => _coins = c);
          _syncUser({'coins': c});
        },
        onLangChanged: (l) {
          setState(() => _lang = l);
          _syncUser({'lang': l});
        },
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

  Widget _fBtn(String label, int idx, int cur, ValueChanged onTap) {
    final act = cur == idx;
    return GestureDetector(
      onTap: () => onTap(idx),
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Text(label, style: TextStyle(fontSize: act ? 19 : 15, fontWeight: FontWeight.bold, color: act ? Colors.black : Colors.grey)),
      ),
    );
  }

  Widget _homeTab() {
    final list = _users.where((u) => _homeFilter == 1 ? u['new'] == true : (_homeFilter == 2 ? u['feat'] == true : true)).toList();
    return ListView(padding: const EdgeInsets.all(14), children: [
      Row(children: [
        _fBtn('Recommend', 0, _homeFilter, (v) => setState(() => _homeFilter = v)),
        _fBtn('New users', 1, _homeFilter, (v) => setState(() => _homeFilter = v)),
        _fBtn('Featured', 2, _homeFilter, (v) => setState(() => _homeFilter = v)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: GestureDetector(
          onTap: () => _sayHi('Riya Sharma', '🌸', 'welcome everyone 🎶'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF8A65), Color(0xFFFF7043)]), borderRadius: BorderRadius.circular(14)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('💖 SoulLink', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Instant dost match', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
        )),
        const SizedBox(width: 10),
        Expanded(child: GestureDetector(
          onTap: () => _enterRoom('welcome everyone 🎶'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4B39EF), Color(0xFF7C4DFF)]), borderRadius: BorderRadius.circular(14)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('🎙️ Party Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('9-Seat Live Voice', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
        )),
      ]),
      const SizedBox(height: 12),
      ...list.map((u) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          CircleAvatar(radius: 25, backgroundColor: Color(u['bg'] as int), child: Text(u['e'].toString(), style: const TextStyle(fontSize: 24))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${u['name']}  •  👑 ${u['vip']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(u['bio'].toString(), style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ])),
          ElevatedButton(
            onPressed: () => _sayHi(u['name'].toString(), u['e'].toString(), u['room'].toString()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
            child: const Text('👋 Hi'),
          ),
        ]),
      )),
    ]);
  }

  Widget _momentsTab() {
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 8), child: Row(children: [
        const Text('🪐 Moments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        const Spacer(),
        ElevatedButton(
          onPressed: _postMoment,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
          child: const Text('+ Post'),
        ),
      ])),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _moments.length,
        itemBuilder: (_, i) {
          final m = _moments[i];
          final liked = m['liked'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(backgroundColor: Color(m['bg'] as int), child: Text(m['e'].toString())),
                const SizedBox(width: 10),
                Expanded(child: Text('${m['name']}\n${m['time']}', style: const TextStyle(color: Colors.black87, fontSize: 13))),
                TextButton(onPressed: () => _sayHi(m['name'].toString(), m['e'].toString(), 'welcome everyone 🎶'), child: const Text('👋 Hi', style: TextStyle(color: Color(0xFFFF7A30)))),
              ]),
              const SizedBox(height: 8),
              Text(m['text'].toString(), style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 8),
              Row(children: [
                Text(m['tag'].toString(), style: const TextStyle(color: Color(0xFFFF7A30), fontSize: 12)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() {
                    m['liked'] = !liked;
                    m['likes'] = (m['likes'] as int) + (liked ? -1 : 1);
                  }),
                  child: Row(children: [
                    Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : Colors.grey, size: 20),
                    Text(' ${m['likes']}'),
                  ]),
                ),
              ]),
            ]),
          );
        },
      )),
    ]);
  }

  Widget _roomsTab() {
    final list = _rooms.where((r) {
      if (_query.isNotEmpty && !r['title'].toString().toLowerCase().contains(_query.toLowerCase())) return false;
      if (_roomFilter == 1) return r['cat'] == 'Video';
      if (_roomFilter == 2) return r['cat'] == 'New';
      if (_roomFilter == 3) return r['mine'] == true;
      return true;
    }).toList();

    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 6), child: Row(children: [
        _fBtn('Recommend', 0, _roomFilter, (v) => setState(() => _roomFilter = v)),
        _fBtn('Video', 1, _roomFilter, (v) => setState(() => _roomFilter = v)),
        _fBtn('New', 2, _roomFilter, (v) => setState(() => _roomFilter = v)),
        _fBtn('Me', 3, _roomFilter, (v) => setState(() => _roomFilter = v)),
        const Spacer(),
        GestureDetector(onTap: () => setState(() { _searching = !_searching; _query = ''; _searchCtrl.clear(); }), child: const Icon(Icons.search)),
        const SizedBox(width: 10),
        GestureDetector(onTap: _createRoom, child: const Icon(Icons.add_box_outlined)),
      ])),
      if (_searching) Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: TextField(controller: _searchCtrl, onChanged: (v) => setState(() => _query = v), decoration: const InputDecoration(hintText: 'Room khojein...', filled: true, fillColor: Colors.white, border: OutlineInputBorder())),
      ),
      GestureDetector(
        onTap: () {
          if (!_bonusClaimed) {
            final updated = _coins + 300;
            setState(() { _coins = updated; _bonusClaimed = true; });
            _syncUser({'coins': updated});
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🪙 Total Coins: $_coins')));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF9E67), Color(0xFFFF7A30)]), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Expanded(child: Text(_bonusClaimed ? 'Event Center • Bonus Claimed (🪙 $_coins)' : 'Event Center • Tap for +300 Free Coins ➔', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const Icon(Icons.event_note, color: Colors.white, size: 30),
          ]),
        ),
      ),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final r = list[i];
          return GestureDetector(
            onTap: () => _enterRoom(r['title'].toString()),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(r['c1'] as int), Color(r['c2'] as int)]), borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text(r['e'].toString(), style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['title'].toString(), maxLines: 1, overflow: 
