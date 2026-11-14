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
  String _cat = 'All';
  bool _claimed = false;
  final _postCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  void _openRoom(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartyRoomScreen(
          roomTitle: title,
          userName: widget.userName,
          userEmoji: widget.userEmoji,
          userBg: widget.userBg,
          coins: widget.coins,
          onCoins: widget.onCoins,
        ),
      ),
    );
  }

  void _createRoomDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎙️ Apna Live Room Banayein'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Room ka naam likhein...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
            onPressed: () async {
              final title = ctrl.text.trim().isEmpty ? '${widget.userName} ka Party Room' : ctrl.text.trim();
              await FirebaseFirestore.instance.collection('rooms').add({
                'title': title,
                'host': widget.userName,
                'cat': 'Chat',
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _openRoom(title);
            },
            child: const Text('Start Live'),
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    final users = [
      {'name': 'Riya Sharma', 'age': '21', 'dist': '1.2 km', 'emoji': '🌸', 'bio': 'Music & Late night talks 🎧'},
      {'name': 'Simran Kaur', 'age': '22', 'dist': '2.5 km', 'emoji': '👑', 'bio': 'Shayari aur dosti ❤️'},
      {'name': 'Ananya Verma', 'age': '20', 'dist': '3.0 km', 'emoji': '🦋', 'bio': 'Let us voice match! ⚡'},
      {'name': 'Kabir Singh', 'age': '23', 'dist': '1.8 km', 'emoji': '🦁', 'bio': 'Cricket & Party Rooms 🔥'},
    ];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF7A30), Color(0xFFFF3D71)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('⚡ Quick Voice Match', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('1-Tap mein kisi naye dost se live voice call par judein!', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF3D71)),
              onPressed: () => _openRoom('⚡ Toki Quick Voice Match'),
              child: const Text('Call Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Card(
          color: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const Text('🎁', style: TextStyle(fontSize: 28)),
            title: const Text('Daily Check-in Bonus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Roz +50 Free Coins paayein!', style: TextStyle(color: Colors.white70, fontSize: 12)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _claimed ? Colors.grey : Colors.amber, foregroundColor: Colors.black),
              onPressed: _claimed ? null : () {
                setState(() => _claimed = true);
                widget.onCoins(widget.coins + 50);
              },
              child: Text(_claimed ? 'Claimed ✅' : '+50 🪙'),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('🔥 Nearby Active Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...users.map((u) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(radius: 24, backgroundColor: const Color(0xFFFF7A30).withOpacity(0.15), child: Text(u['emoji']!, style: const TextStyle(fontSize: 24))),
            title: Text('${u['name']}, ${u['age']} 🟢', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${u['dist']} away • ${u['bio']}'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF), foregroundColor: Colors.white),
              onPressed: () => _openRoom('💬 Chat with ${u['name']}'),
              child: const Text('Say Hi 👋'),
            ),
          ),
        )),
      ],
    );
  }
    Widget _buildRooms() {
    final defaultRooms = [
      {'title': '🔥 Desi Adda & Shayari Night', 'host': 'Riya 🌸', 'cat': 'Chat', 'users': 142},
      {'title': '🎵 Non-Stop Bollywood Lofi', 'host': 'Aarav 🎧', 'cat': 'Music', 'users': 89},
      {'title': '❤️ Dil Se Dil Tak (Dating)', 'host': 'Simran 👑', 'cat': 'Dating', 'users': 210},
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF7A30),
        foregroundColor: Colors.white,
        onPressed: _createRoomDialog,
        icon: const Icon(Icons.mic),
        label: const Text('Create Room'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['All', 'Chat', 'Music', 'Dating'].map((c) => ChoiceChip(
              label: Text(c),
              selected: _cat == c,
              selectedColor: const Color(0xFFFF7A30),
              labelStyle: TextStyle(color: _cat == c ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
              onSelected: (_) => setState(() => _cat = c),
            )).toList(),
          ),
          const SizedBox(height: 8),
          ...defaultRooms.where((r) => _cat == 'All' || r['cat'] == _cat).map((r) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF1E1E2C), child: Text('🎙️')),
              title: Text(r['title'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('Host: ${r['host']} • ${r['cat']}'),
              trailing: Text('🟢 ${r['users']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              onTap: () => _openRoom(r['title'].toString()),
            ),
          )),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox();
              return Column(
                children: snap.data!.docs.map((d) {
                  final m = d.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFFFF7A30), child: Text('🔥')),
                      title: Text((m['title'] ?? 'Live Room').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Host: ${m['host']} • Live Now'),
                      trailing: const Text('🟢 Join', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      onTap: () => _openRoom((m['title'] ?? 'Live Room').toString()),
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

  Widget _buildMoments() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _postCtrl,
              decoration: InputDecoration(hintText: 'Apni shayari ya status post karein...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
            onPressed: () async {
              if (_postCtrl.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('moments').add({
                'user': widget.userName,
                'emoji': widget.userEmoji,
                'text': _postCtrl.text.trim(),
                'likes': 1,
                'createdAt': FieldValue.serverTimestamp(),
              });
              _postCtrl.clear();
            },
            child: const Text('Post'),
          ),
        ]),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('moments').snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('Pehla Moment post karein! ✨'));
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final d = docs[i];
                final m = d.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(child: Text((m['emoji'] ?? '😎').toString())),
                    title: Text((m['user'] ?? 'User').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text((m['text'] ?? '').toString()),
                    trailing: TextButton.icon(
                      onPressed: () => d.reference.update({'likes': FieldValue.increment(1)}),
                      icon: const Icon(Icons.favorite, color: Colors.red, size: 18),
                      label: Text('${m['likes'] ?? 0}'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildMessages() {
    return Column(children: [
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('private_chats').orderBy('ts', descending: true).limit(30).snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('💬 Apne doston ko pehla message bhejein!'));
            return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final m = docs[i].data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text((m['emoji'] ?? '😎').toString())),
                    title: Text((m['user'] ?? 'User').toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text((m['text'] ?? '').toString()),
                  ),
                );
              },
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Expanded(child: TextField(controller: _msgCtrl, decoration: const InputDecoration(hintText: 'Message likhein...', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFFFF7A30)),
            onPressed: () async {
              if (_msgCtrl.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('private_chats').add({
                'user': widget.userName,
                'emoji': widget.userEmoji,
                'text': _msgCtrl.text.trim(),
                'ts': FieldValue.serverTimestamp(),
              });
              _msgCtrl.clear();
            },
          ),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabIndex == 1) return _buildMoments();
    if (widget.tabIndex == 2) return _buildRooms();
    if (widget.tabIndex == 3) return _buildMessages();
    return _buildHome();
  }
}
