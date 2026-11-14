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

  void _openRoom(String title) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PartyRoomScreen(
      roomTitle: title, userName: widget.userName, userEmoji: widget.userEmoji,
      userBg: widget.userBg, coins: widget.coins, onCoins: widget.onCoins,
    )));
  }

  void _createRoomDialog() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('🎙️ Apna Live Room Banayein'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Room ka naam...')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
          onPressed: () async {
            final t = ctrl.text.trim().isEmpty ? '${widget.userName} ka Room' : ctrl.text.trim();
            await FirebaseFirestore.instance.collection('rooms').add({'title': t, 'host': widget.userName, 'cat': 'Chat'});
            if (ctx.mounted) Navigator.pop(ctx);
            _openRoom(t);
          },
          child: const Text('Start Live'),
        ),
      ],
    ));
  }

  void _openComments(DocumentReference ref, String author) {
    final cCtrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 12, right: 12, top: 12),
      child: SizedBox(height: 300, child: Column(children: [
        Text('💬 Comments on $author', style: const TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: ref.collection('comments').orderBy('ts', descending: true).snapshots(),
          builder: (_, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            final docs = s.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('Pehla comment karein! ✨'));
            return ListView.builder(itemCount: docs.length, itemBuilder: (_, i) {
              final m = docs[i].data() as Map<String, dynamic>;
              return ListTile(dense: true, title: Text('${m['user']}: ${m['text']}'));
            });
          },
        )),
        Row(children: [
          Expanded(child: TextField(controller: cCtrl, decoration: const InputDecoration(hintText: 'Comment likhein...'))),
          IconButton(icon: const Icon(Icons.send, color: Color(0xFFFF7A30)), onPressed: () async {
            if (cCtrl.text.trim().isEmpty) return;
            await ref.collection('comments').add({'user': widget.userName, 'text': cCtrl.text.trim(), 'ts': FieldValue.serverTimestamp()});
            cCtrl.clear();
          }),
        ]),
      ])),
    ));
  }

  void _openDirectChat(String friendName, String friendEmoji) {
    final cCtrl = TextEditingController();
    final chatId = friendName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C), foregroundColor: Colors.white,
        title: Row(children: [Text(friendEmoji), const SizedBox(width: 8), Text('$friendName 🟢', style: const TextStyle(fontSize: 16))]),
        actions: [IconButton(icon: const Icon(Icons.call, color: Colors.greenAccent), onPressed: () => _openRoom('📞 Call: $friendName'))],
      ),
      body: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('dm_$chatId').orderBy('ts', descending: true).snapshots(),
          builder: (_, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            if (docs.isEmpty) return Center(child: Text('👋 $friendName ko pehla message ya Rose bhejein!'));
            return ListView.builder(reverse: true, padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (_, i) {
              final m = docs[i].data() as Map<String, dynamic>;
              final isMe = m['sender'] == widget.userName;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: isMe ? const Color(0xFFFF7A30) : Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
                  child: Text('${m['text']}', style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                ),
              );
            });
          },
        )),
        Container(padding: const EdgeInsets.all(8), color: Colors.white, child: Row(children: [
          IconButton(icon: const Text('🌹', style: TextStyle(fontSize: 22)), onPressed: () async {
            if (widget.coins < 10) return;
            widget.onCoins(widget.coins - 10);
            await FirebaseFirestore.instance.collection('dm_$chatId').add({'sender': widget.userName, 'text': '🎁 Sent a 🌹 Rose (-10 🪙)', 'ts': FieldValue.serverTimestamp()});
          }),
          Expanded(child: TextField(controller: cCtrl, decoration: const InputDecoration(hintText: 'Message likhein...', border: InputBorder.none))),
          IconButton(icon: const Icon(Icons.send, color: Color(0xFFFF7A30)), onPressed: () async {
            if (cCtrl.text.trim().isEmpty) return;
            await FirebaseFirestore.instance.collection('dm_$chatId').add({'sender': widget.userName, 'text': cCtrl.text.trim(), 'ts': FieldValue.serverTimestamp()});
            cCtrl.clear();
          }),
        ])),
      ]),
    )));
  }

  Widget _buildHome() {
    final users = [
      {'name': 'Riya Sharma', 'age': '21', 'dist': '1.2 km', 'emoji': '🌸', 'bio': 'Music & Late night talks 🎧'},
      {'name': 'Simran Kaur', 'age': '22', 'dist': '2.5 km', 'emoji': '👑', 'bio': 'Shayari aur dosti ❤️'},
      {'name': 'Ananya Verma', 'age': '20', 'dist': '3.0 km', 'emoji': '🦋', 'bio': 'Let us voice match! ⚡'},
    ];
    return ListView(padding: const EdgeInsets.all(12), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF7A30), Color(0xFFFF3D71)]), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('⚡ Quick Voice Match', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('1-Tap mein live voice call par judein!', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF3D71)), onPressed: () => _openRoom('⚡ Toki Quick Voice Match'), child: const Text('Call Now')),
        ]),
      ),
      const SizedBox(height: 10),
      Card(color: const Color(0xFF1E1E2C), child: ListTile(
        leading: const Text('🎁', style: TextStyle(fontSize: 28)),
        title: const Text('Daily Check-in Bonus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: const Text('Roz +50 Free Coins paayein!', style: TextStyle(color: Colors.white70, fontSize: 12)),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _claimed ? Colors.grey : Colors.amber, foregroundColor: Colors.black),
          onPressed: _claimed ? null : () { setState(() => _claimed = true); widget.onCoins(widget.coins + 50); },
          child: Text(_claimed ? 'Claimed ✅' : '+50 🪙'),
        ),
      )),
      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('🔥 Nearby Active Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      ...users.map((u) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFFFF7A30).withOpacity(0.15), child: Text(u['emoji']!, style: const TextStyle(fontSize: 22))),
        title: Text('${u['name']}, ${u['age']} 🟢', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${u['dist']} • ${u['bio']}'),
        trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF), foregroundColor: Colors.white), onPressed: () => _openDirectChat(u['name']!, u['emoji']!), child: const Text('Say Hi 👋')),
      ))),
    ]);
  }

  Widget _buildMoments() {
    final samples = [
      {'user': 'Riya 🌸', 'emoji': '🌸', 'tag': '#Shayari', 'text': 'Dil ki baat zubaan par aane lagi hai, ab toh raaton mein bhi neend udne lagi hai ✨❤️', 'likes': 48, 'gifts': 5},
      {'user': 'Aarav 🎧', 'emoji': '🎧', 'tag': '#Party', 'text': 'Aaj raat 10 baje mere Live Voice Room mein sabka swagat hai! 🎙️🔥', 'likes': 92, 'gifts': 12},
      {'user': 'Simran 👑', 'emoji': '👑', 'tag': '#Love', 'text': 'Koi aisa ho jo bina kahe dil ki har baat samajh le... 💫🌹', 'likes': 134, 'gifts': 19},
    ];
    return Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: Column(children: [
        Row(children: [
          Expanded(child: TextField(controller: _postCtrl, decoration: InputDecoration(hintText: 'Shayari ya status likhein...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)))),
          const SizedBox(width: 6),
          DropdownButton<String>(value: _postTag, items: ['#Shayari', '#Love', '#Party'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(), onChanged: (v) => setState(() => _postTag = v ?? '#Shayari')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white), onPressed: () async {
            if (_postCtrl.text.trim().isEmpty) return;
            await FirebaseFirestore.instance.collection('moments').add({'user': widget.userName, 'emoji': widget.userEmoji, 'text': _postCtrl.text.trim(), 'tag': _postTag, 'likes': 1, 'gifts': 0, 'createdAt': FieldValue.serverTimestamp()});
            _postCtrl.clear();
          }, child: const Text('Post')),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['All', '#Shayari', '#Love', '#Party'].map((t) => ChoiceChip(
          label: Text(t, style: const TextStyle(fontSize: 11)), selected: _mTag == t, selectedColor: const Color(0xFFFF7A30),
          labelStyle: TextStyle(color: _mTag == t ? Colors.white : Colors.black87), onSelected: (_) => setState(() => _mTag = t),
        )).toList()),
      ])),
      Expanded(child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('moments').snapshots(),
        builder: (context, snap) {
          final docs = snap.hasData ? snap.data!.docs : [];
          return ListView(padding: const EdgeInsets.all(10), children: [
            ...docs.map((d) {
              final m = d.data() as Map<String, dynamic>;
              if (_mTag != 'All' && (m['tag'] ?? '#Shayari') != _mTag) return const SizedBox();
              final user = (m['user'] ?? 'User').toString();
              return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(child: Text((m['emoji'] ?? '😎').toString())), const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user, style: const TextStyle(fontWeight: FontWeight.bold)), Text((m['tag'] ?? '#Shayari').toString(), style: const TextStyle(color: Color(0xFFFF7A30), fontSize: 11))])),
                  OutlinedButton(onPressed: () => _openDirectChat(user, (m['emoji'] ?? '😎').toString()), child: const Text('Say Hi 👋', style: TextStyle(fontSize: 11))),
                ]),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text((m['text'] ?? '').toString())),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  TextButton.icon(onPressed: () => d.reference.update({'likes': FieldValue.increment(1)}), icon: const Icon(Icons.favorite, color: Colors.red, size: 18), label: Text('${m['likes'] ?? 0}')),
                  TextButton.icon(onPressed: () => _openComments(d.reference, user), icon: const Icon(Icons.chat_bubble_outline, size: 18), label: const Text('Comment')),
                  TextButton.icon(onPressed: () { if (widget.coins >= 10) { widget.onCoins(widget.coins - 10); d.reference.update({'gifts': FieldValue.increment(1)}); } }, icon: const Text('🌹', style: TextStyle(fontSize: 16)), label: Text('${m['gifts'] ?? 0}')),
                ]),
              ])));
            }),
            ...samples.where((s) => _mTag == 'All' || s['tag'] == _mTag).map((s) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(child: Text(s['emoji'].toString())), const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s['user'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)), Text(s['tag'].toString(), style: const TextStyle(color: Color(0xFFFF7A30), fontSize: 11))])),
                OutlinedButton(onPressed: () => _openDirectChat(s['user'].toString(), s['emoji'].toString()), child: const Text('Say Hi 👋', style: TextStyle(fontSize: 11))),
              ]),
              Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s['text'].toString())),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.favorite, color: Colors.red, size: 18), label: Text('${s['likes']}')),
                TextButton.icon(onPressed: () => _openDirectChat(s['user'].toString(), s['emoji'].toString()), icon: const Icon(Icons.chat_bubble_outline, size: 18), label: const Text('Reply')),
                TextButton.icon(onPressed: () { if (widget.coins >= 10) widget.onCoins(widget.coins - 10); }, icon: const Text('🌹', style: TextStyle(fontSize: 16)), label: Text('${s['gifts']}')),
              ]),
            ])))),
          ]);
        },
      )),
    ]);
  }

  Widget _buildRooms() {
    final rooms = [
      {'title': '🔥 Desi Adda & Shayari Night', 'host': 'Riya 🌸', 'cat': 'Chat', 'users': 142},
      {'title': '🎵 Non-Stop Bollywood Lofi', 'host': 'Aarav 🎧', 'cat': 'Music', 'users': 89},
      {'title': '❤️ Dil Se Dil Tak (Dating)', 'host': 'Simran 👑', 'cat': 'Dating', 'users': 210},
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white, onPressed: _createRoomDialog, icon: const Icon(Icons.mic), label: const Text('Create Room')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['All', 'Chat', 'Music', 'Dating'].map((c) => ChoiceChip(
          label: Text(c), selected: _cat == c, selectedColor: const Color(0xFFFF7A30),
          labelStyle: TextStyle(color: _cat == c ? Colors.white : Colors.black87, fontWeight: FontWeight.bold), onSelected: (_) => setState(() => _cat = c),
        )).toList()),
        const SizedBox(height: 8),
        ...rooms.where((r) => _cat == 'All' || r['cat'] == _cat).map((r) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
          leading: const CircleAvatar(backgroundColor: Color(0xFF1E1E2C), child: Text('🎙️')),
          title: Text(r['title'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text('Host: ${r['host']} • ${r['cat']}'),
          trailing: Text('🟢 ${r['users']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          onTap: () => _openRoom(r['title'].toString()),
        ))),
        StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('rooms').snapshots(), builder: (context, snap) {
          if (!snap.hasData) return const SizedBox();
          return Column(children: snap.data!.docs.map((d) {
            final m = d.data() as Map<String, dynamic>;
            return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFF7A30), child: Text('🔥')),
              title: Text((m['title'] ?? 'Live Room').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Host: ${m['host']} • Live Now'),
              trailing: const Text('🟢 Join', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              onTap: () => _openRoom((m['title'] ?? 'Live Room').toString()),
            ));
          }).toList());
        }),
      ]),
    );
  }

  Widget _buildMessages() {
    final friends = [
      {'name': 'Riya Sharma', 'emoji': '🌸', 'msg': 'Hey! Live room mein aa rahe ho kya? 🎙️', 'time': 'Now', 'unread': 2},
      {'name': 'Simran Kaur', 'emoji': '👑', 'msg': 'Tumhari shayari bahut mast thi ❤️', 'time': '5m', 'unread': 1},
      {'name': 'Aarav Singh', 'emoji': '🎧', 'msg': 'Aaj raat party room me milte hain 🔥', 'time': '1h', 'unread': 0},
      {'name': 'Kabir Verma', 'emoji': '🦁', 'msg': 'Bhai lucky spin me 100 coins jeeta! 🎰', 'time': '2h', 'unread': 0},
    ];
    return ListView(padding: const EdgeInsets.all(12), children: [
      Card(color: const Color(0xFF1E1E2C), child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFFF7A30), child: Icon(Icons.notifications_active, color: Colors.white)),
        title: const Text('🔔 Toki Official & System Notice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text('Riya & 3 others visited your profile • Welcome bonus active!', style: TextStyle(color: Colors.white70, fontSize: 12)),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 System Notice: Aapka account 100% Active hai!'))),
      )),
      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('💬 Friends & Direct Messages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      ...friends.map((f) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
        leading: CircleAvatar(radius: 22, backgroundColor: const Color(0xFFFF7A30).withOpacity(0.15), child: Text(f['emoji'].toString(), style: const Text
