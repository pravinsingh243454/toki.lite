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
  String _cat = 'All', _mTag = 'All', _postTag = '#Shayari';
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

  void _openComments(DocumentReference postRef, String author) {
    final cCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 12, right: 12, top: 12),
        child: SizedBox(
          height: 360,
          child: Column(children: [
            Text('💬 Comments on $author', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: postRef.collection('comments').orderBy('ts', descending: true).snapshots(),
                builder: (_, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('Pehla comment karein! ✨'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final m = docs[i].data() as Map<String, dynamic>;
                      return ListTile(dense: true, leading: const Icon(Icons.comment, size: 16), title: Text('${m['user']}: ${m['text']}'));
                    },
                  );
                },
              ),
            ),
            Row(children: [
              Expanded(child: TextField(controller: cCtrl, decoration: const InputDecoration(hintText: 'Comment likhein...'))),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFFFF7A30)),
                onPressed: () async {
                  if (cCtrl.text.trim().isEmpty) return;
                  await postRef.collection('comments').add({
                    'user': widget.userName,
                    'text': cCtrl.text.trim(),
                    'ts': FieldValue.serverTimestamp(),
                  });
                  cCtrl.clear();
                },
              ),
            ]),
          ]),
        ),
      ),
    );
  }
    Widget _buildHome() {
    final users = [
      {'name': 'Riya Sharma', 'age': '21', 'dist': '1.2 km', 'emoji': '🌸', 'bio': 'Music & Late night talks 🎧'},
      {'name': 'Simran Kaur', 'age': '22', 'dist': '2.5 km', 'emoji': '👑', 'bio': 'Shayari aur dosti ❤️'},
      {'name': 'Ananya Verma', 'age': '20', 'dist': '3.0 km', 'emoji': '🦋', 'bio': 'Let us voice match! ⚡'},
      {'name': 'Kabir Singh', 'age': '23', 'dist': '1.8 km', 'emoji': '🦁', 'bio': 'Cricket & Party Rooms 🔥'},
      {'name': 'Priya Patel', 'age': '21', 'dist': '0.9 km', 'emoji': '🌹', 'bio': 'New on Toki, say hi! ✨'},
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
              onPressed: _claimed ? null : () { setState(() => _claimed = true); widget.onCoins(widget.coins + 50); },
              child: Text(_claimed ? 'Claimed ✅' : '+50 🪙'),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('🔥 Nearby Active Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ...users.map((u) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(radius: 24, backgroundColor: const Color(0xFFFF7A30).withOpacity(0.15), child: Text(u['emoji']!, style: const TextStyle(fontSize: 22))),
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

  Widget _buildMoments() {
    final sampleMoments = [
      {'user': 'Riya 🌸', 'emoji': '🌸', 'tag': '#Shayari', 'text': 'Dil ki baat zubaan par aane lagi hai, ab toh raaton mein bhi neend udne lagi hai ✨❤️', 'likes': 48, 'gifts': 5},
      {'user': 'Aarav 🎧', 'emoji': '🎧', 'tag': '#Party', 'text': 'Aaj raat 10 baje mere Live Voice Room mein sabka swagat hai! Full masti aur gaane 🎙️🔥', 'likes': 92, 'gifts': 12},
      {'user': 'Simran 👑', 'emoji': '👑', 'tag': '#Love', 'text': 'Koi aisa ho jo bina kahe dil ki har baat samajh le... 💫🌹', 'likes': 134, 'gifts': 19},
    ];
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _postCtrl,
                decoration: InputDecoration(hintText: 'Apni shayari ya status likhein...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
              ),
            ),
            const SizedBox(width: 6),
            DropdownButton<String>(
              value: _postTag,
              items: ['#Shayari', '#Love', '#Party'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) => setState(() => _postTag = v ?? '#Shayari'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
              onPressed: () async {
                if (_postCtrl.text.trim().isEmpty) return;
                await FirebaseFirestore.instance.collection('moments').add({
                  'user': widget.userName,
                  'emoji': widget.userEmoji,
                  'text': _postCtrl.text.trim(),
                  'tag': _postTag,
                  'likes': 1,
                  'gifts': 0,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                _postCtrl.clear();
              },
              child: const Text('Post'),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['All', '#Shayari', '#Love', '#Party'].map((t) => ChoiceChip(
              label: Text(t, style: const TextStyle(fontSize: 11)),
              selected: _mTag == t,
              selectedColor: const Color(0xFFFF7A30),
              labelStyle: TextStyle(color: _mTag == t ? Colors.white : Colors.black87),
              onSelected: (_) => setState(() => _mTag = t),
            )).toList(),
          ),
        ]),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('moments').snapshots(),
          builder: (context, snap) {
            final liveDocs = snap.hasData ? snap.data!.docs : [];
            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                ...liveDocs.map((d) {
                  final m = d.data() as Map<String, dynamic>;
                  if (_mTag != 'All' && (m['tag'] ?? '#Shayari') != _mTag) return const SizedBox();
                  final user = (m['user'] ?? 'User').toString();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          CircleAvatar(child: Text((m['emoji'] ?? '😎').toString())),
                          const SizedBox(width: 8),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text((m['tag'] ?? '#Shayari').toString(), style: const TextStyle(color: Color(0xFFFF7A30), fontSize: 11)),
                          ])),
                          OutlinedButton(onPressed: () => _openRoom('💬 Chat with $user'), child: const Text('Say Hi 👋', style: TextStyle(fontSize: 11))),
                        ]),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text((m['text'] ?? '').toString(), style: const TextStyle(fontSize: 14))),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          TextButton.icon(onPressed: () => d.reference.update({'likes': FieldValue.increment(1)}), icon: const Icon(Icons.favorite, color: Colors.red, size: 18), label: Text('${m['likes'] ?? 0}')),
                          TextButton.icon(onPressed: () => _openComments(d.reference, user), icon: const Icon(Icons.chat_bubble_outline, size: 18), label: const Text('Comment')),
                          TextButton.icon(onPressed: () { if (widget.coins >= 10) { widget.onCoins(widget.coins - 10); d.reference.update({'gifts': FieldValue.increment(1)}); } }, icon: const Text('🌹', style: TextStyle(fontSize: 16)), label: Text('${m['gifts'] ?? 0}')),
                        ]),
                      ]),
                    ),
                  );
                }),
                ...sampleMoments.where((s) => _mTag == 'All' || s['tag'] == _mTag).map((s) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(child: Text(s['emoji'].toString())),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s['user'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(s['tag'].toString(), style: const TextStyle(color: Color(0xFFFF7A30), fontSize: 11)),
                        ])),
                        OutlinedButton(onPressed: () => _openRoom('💬 Chat with ${s['user']}'), child: const Text('Say Hi 👋', style: TextStyle(fontSize: 11))),
                      ]),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s['text'].toString(), style: const TextStyle(fontSize: 14))),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        TextButton.icon(onPressed: () {}, icon: const Icon(Icons.favorite, color: Colors.red, size: 18), label: Text('${s['likes']}')),
                        TextButton.icon(onPressed: () => _openRoom('💬 Chat with ${s['user']}'), icon: const Icon(Icons.chat_bubble_outline, size: 18), label: const Text('Reply')),
                        TextButton.icon(onPressed: () { if (widget.coins >= 10) widget.onCoins(widget.coins - 10); }, icon: const Text('🌹', style: TextStyle(fontSize: 16)), label: Text('${s['gifts']}')),
                      ]),
                    ]),
                  ),
                )),
              ],
            );
          },
        ),
      ),
    ]);
  }
  
