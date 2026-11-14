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
  final _postCtrl = TextEditingController();

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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF), foregroundColor: Colors.white),
            onPressed: () async {
              final title = ctrl.text.trim().isEmpty ? '${widget.userName} ka Party Room' : ctrl.text.trim();
              await FirebaseFirestore.instance.collection('rooms').add({
                'title': title,
                'host': widget.userName,
                'cat': 'Chat',
                'users': 1,
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
    Widget _buildRooms() {
    final defaultRooms = [
      {'title': '🔥 Desi Adda & Shayari Night', 'host': 'Riya 🌸', 'cat': 'Chat', 'users': 142},
      {'title': '🎵 Non-Stop Bollywood Lofi', 'host': 'Aarav 🎧', 'cat': 'Music', 'users': 89},
      {'title': '❤️ Dil Se Dil Tak (Dating)', 'host': 'Simran 👑', 'cat': 'Dating', 'users': 210},
      {'title': '🦁 Royal VIP Hangout Club', 'host': 'Kabir 🦁', 'cat': 'Chat', 'users': 64},
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4B39EF),
        foregroundColor: Colors.white,
        onPressed: _createRoomDialog,
        icon: const Icon(Icons.mic),
        label: const Text('Create Room'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4B39EF), Color(0xFFFF7A30)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(children: [
              Text('👑', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Expanded(child: Text('TOKI LIVE PARTY\nDoston ke saath 24x7 Free Voice Chat & Lucky Spin!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            ]),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['All', 'Chat', 'Music', 'Dating'].map((c) => ChoiceChip(
              label: Text(c),
              selected: _cat == c,
              selectedColor: const Color(0xFF4B39EF),
              labelStyle: TextStyle(color: _cat == c ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
              onSelected: (_) => setState(() => _cat = c),
            )).toList(),
          ),
          const SizedBox(height: 8),
          ...defaultRooms.where((r) => _cat == 'All' || r['cat'] == _cat).map((r) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFF4B39EF).withOpacity(0.15), child: const Text('🎙️')),
              title: Text(r['title'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('Host: ${r['host']} • ${r['cat']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text('🟢 ${r['users']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
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
              decoration: InputDecoration(
                hintText: 'Apni shayari ya status post karein...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF), foregroundColor: Colors.white),
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
                    subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text((m['text'] ?? '').toString())),
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

  Widget _buildRanking() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').orderBy('coins', descending: true).limit(10).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final u = docs[i].data() as Map<String, dynamic>;
            final medal = i == 0 ? '🥇' : (i == 1 ? '🥈' : (i == 2 ? '🥉' : '#${i + 1}'));
            return Card(
              child: ListTile(
                leading: Text(medal, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                title: Text((u['name'] ?? 'Toki Star').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('🪙 ${u['coins'] ?? 0}', style: const TextStyle(color: Color(0xFFFF7A30), fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabIndex == 1) return _buildMoments();
    if (widget.tabIndex == 3) return _buildRanking();
    return _buildRooms();
  }
}
