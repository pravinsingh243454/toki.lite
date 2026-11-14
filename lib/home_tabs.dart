import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'room_screen.dart';

class TokiHomeTabs extends StatefulWidget {
  final int tabIndex, coins, userBg;
  final String userName, userEmoji, lang;
  final Function(int newCoins) onCoins;

  const TokiHomeTabs({
    super.key,
    required this.tabIndex,
    required this.userName,
    required this.userEmoji,
    required this.userBg,
    required this.coins,
    required this.lang,
    required this.onCoins,
  });

  @override
  State<TokiHomeTabs> createState() => _TokiHomeTabsState();
}

class _TokiHomeTabsState extends State<TokiHomeTabs> {
  String _cat = 'All', _postTag = '#Shayari';
  bool _claimed = false, _isVip = false;
  final _postCtrl = TextEditingController();

  String get _vipName => _isVip ? '👑 [VIP] ${widget.userName}' : widget.userName;

  void _openRoom(String t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartyRoomScreen(
          roomTitle: t,
          userName: _vipName,
          userEmoji: _isVip ? '👑' : widget.userEmoji,
          userBg: widget.userBg,
          coins: widget.coins,
          onCoins: widget.onCoins,
        ),
      ),
    );
  }

  void _buyVip() {
    if (_isVip) return;
    if (widget.coins < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ VIP ke liye 300 Coins chahiye!')),
      );
      return;
    }
    setState(() => _isVip = true);
    widget.onCoins(widget.coins - 300);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Mubarak ho! Aap ab Royal VIP hain 👑')),
    );
  }

  void _createRoom() {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎙️ New Live Room'),
        content: TextField(controller: c),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final t = c.text.trim().isEmpty
                  ? '$_vipName Room'
                  : c.text.trim();
              await FirebaseFirestore.instance
                  .collection('rooms')
                  .add({'title': t, 'host': _vipName, 'cat': 'Chat'});
              if (ctx.mounted) Navigator.pop(ctx);
              _openRoom(t);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _openChat(String name, String emoji) {
    final c = TextEditingController();
    final id = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1E2C),
            foregroundColor: Colors.white,
            title: Text('$emoji $name 🟢'),
            actions: [
              IconButton(
                icon: const Icon(Icons.call, color: Colors.greenAccent),
                onPressed: () => _openRoom('📞 Call: $name'),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('dm_$id')
                      .orderBy('ts', descending: true)
                      .snapshots(),
                  builder: (_, s) {
                    if (!s.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = s.data!.docs;
                    if (docs.isEmpty) {
                      return Center(child: Text('👋 Say Hi to $name!'));
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final m = docs[i].data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text('${m['sender']}: ${m['text']}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Text('🌹', style: TextStyle(fontSize: 22)),
                    onPressed: () async {
                      if (widget.coins < 10) return;
                      widget.onCoins(widget.coins - 10);
                      await FirebaseFirestore.instance
                          .collection('dm_$id')
                          .add({
                        'sender': _vipName,
                        'text': '🎁 Sent a 🌹 Rose (-10 🪙)',
                        'ts': FieldValue.serverTimestamp(),
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: c,
                      decoration: const InputDecoration(hintText: 'Message...'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFFF7A30)),
                    onPressed: () async {
                      if (c.text.trim().isEmpty) return;
                      await FirebaseFirestore.instance
                          .collection('dm_$id')
                          .add({
                        'sender': _vipName,
                        'text': c.text.trim(),
                        'ts': FieldValue.serverTimestamp(),
                      });
                      c.clear();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    final users = [
      {'name': 'Riya Sharma', 'emoji': '🌸', 'bio': 'Music & Talks 🎧'},
      {'name': 'Simran Kaur', 'emoji': '👑', 'bio': 'Shayari ❤️'},
      {'name': 'Ananya Verma', 'emoji': '🦋', 'bio': 'Voice match ⚡'},
    ];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: const Color(0xFFFF7A30),
          child: ListTile(
            title: const Text(
              '⚡ Quick Voice Match',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              '1-Tap live voice call!',
              style: TextStyle(color: Colors.white70),
            ),
            trailing: ElevatedButton(
              onPressed: () => _openRoom('⚡ Quick Voice Match'),
              child: const Text('Call Now'),
            ),
          ),
        ),
        Card(
          color: const Color(0xFF2B1E16),
          child: ListTile(
            leading: const Text('👑', style: TextStyle(fontSize: 28)),
            title: Text(
              _isVip ? 'Royal VIP Active 👑' : 'Become Toki VIP 👑',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Golden Badge + VIP Room Entry!',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isVip ? Colors.green : Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: _buyVip,
              child: Text(_isVip ? 'VIP ✅' : '300 🪙'),
            ),
          ),
        ),
        Card(
          color: const Color(0xFF1E1E2C),
          child: ListTile(
            leading: const Text('🎁', style: TextStyle(fontSize: 26)),
            title: const Text(
              'Daily Check-in (+50 🪙)',
              style: TextStyle(color: Colors.white),
            ),
            trailing: ElevatedButton(
              onPressed: _claimed
                  ? null
                  : () {
                      setState(() => _claimed = true);
                      widget.onCoins(widget.coins + 50);
                    },
              child: Text(_claimed ? 'Done ✅' : 'Claim'),
            ),
          ),
        ),
        ...users.map(
          (u) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(u['emoji']!)),
              title: Text('${u['name']} 🟢'),
              subtitle: Text(u['bio']!),
              trailing: ElevatedButton(
                onPressed: () => _openChat(u['name']!, u['emoji']!),
                child: const Text('Say Hi 👋'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoments() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postCtrl,
                  decoration: const InputDecoration(hintText: 'Shayari...'),
                ),
              ),
              DropdownButton<String>(
                value: _postTag,
                items: ['#Shayari', '#Love', '#Party']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _postTag = v ?? '#Shayari'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_postCtrl.text.trim().isEmpty) return;
                  await FirebaseFirestore.instance.collection('moments').add({
                    'user': _vipName,
                    'emoji': _isVip ? '👑' : widget.userEmoji,
                    'text': _postCtrl.text.trim(),
                    'tag': _postTag,
                    'likes': 1,
                  });
                  _postCtrl.clear();
                },
                child: const Text('Post'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('moments').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i];
                  final m = d.data() as Map<String, dynamic>;
                  final u = (m['user'] ?? 'User').toString();
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text((m['emoji'] ?? '😎').toString()),
                      ),
                      title: Text('$u (${m['tag'] ?? '#Shayari'})'),
                      subtitle: Text((m['text'] ?? '').toString()),
                      trailing: TextButton.icon(
                        onPressed: () =>
                            d.reference.update({'likes': FieldValue.increment(1)}),
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        label: Text('${m['likes'] ?? 0}'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRooms() {
    final rooms = [
      {'title': '🔥 Desi Adda Night', 'host': 'Riya 🌸', 'cat': 'Chat'},
      {'title': '🎵 Bollywood Lofi', 'host': 'Aarav 🎧', 'cat': 'Music'},
      {'title': '❤️ Dil Se Dil Tak', 'host': 'Simran 👑', 'cat': 'Dating'},
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7A30),
        onPressed: _createRoom,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...rooms.map(
            (r) => Card(
              child: ListTile(
                title: Text(r['title']!),
                subtitle: Text('Host: ${r['host']}'),
                trailing: const Text('🟢 Join'),
                onTap: () => _openRoom(r['title']!),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
            builder: (_, snap) {
              if (!snap.hasData) return const SizedBox();
              return Column(
                children: snap.data!.docs.map((d) {
                  final m = d.data() as Map<String, dynamic>;
                  final t = (m['title'] ?? 'Live Room').toString();
                  return Card(
                    child: ListTile(
                      title: Text(t),
                      subtitle: Text('Host: ${m['host']}'),
                      onTap: () => _openRoom(t),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    final friends = [
      {'name': 'Riya Sharma', 'emoji': '🌸', 'msg': 'Live room me aao 🎙️'},
      {'name': 'Simran Kaur', 'emoji': '👑', 'msg': 'Mast shayari thi ❤️'},
      {'name': 'Aarav Singh', 'emoji': '🎧', 'msg': 'Party room me milte hai 🔥'},
    ];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Card(
          color: Color(0xFF1E1E2C),
          child: ListTile(
            title: Text(
              '🔔 Toki Official Notice',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Welcome to Toki Lite VIP!',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
        ...friends.map(
          (f) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(f['emoji']!)),
              title: Text('${f['name']} 🟢'),
              subtitle: Text(f['msg']!),
              onTap: () => _openChat(f['name']!, f['emoji']!),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabIndex == 1) return _buildMoments();
    if (widget.tabIndex == 2) return _buildRooms();
    if (widget.tabIndex == 3) return _buildMessages();
    return _buildHome();
  }
}
