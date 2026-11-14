import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _postTag = '#Shayari', _bio = 'Music, Shayari & Late Night Talks 🎙️';
  bool _claimed = false, _isVip = false, _nearbyOnly = false;
  int _diamonds = 120;
  final _postCtrl = TextEditingController();
  static const _upi1 = 'Pravinsingh231224@ybl', _upi2 = 'pravin.3525@ptyes';
  static const _cardBg = Color(0xFF1E1E2A), _darkBg = Color(0xFF121218);

  String get _vipName => _isVip ? '👑 [VIP] ${widget.userName}' : widget.userName;

  void _openRoom(String t) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PartyRoomScreen(
      roomTitle: t, userName: _vipName, userEmoji: _isVip ? '👑' : widget.userEmoji,
      userBg: widget.userBg, coins: widget.coins, onCoins: widget.onCoins,
    )));
  }

  void _openUpiPay(String item, String amt, String numAmt) {
    final utr = TextEditingController();
    final qr = 'https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=${Uri.encodeComponent('upi://pay?pa=$_upi1&pn=TokiLite&am=$numAmt&cu=INR')}';
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: _cardBg, builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 14),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('💳 Scan & Pay $amt ($item)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(6), color: Colors.white, child: Image.network(qr, height: 140, width: 140)),
        ListTile(dense: true, title: const Text('PhonePe: $_upi1', style: TextStyle(color: Colors.white)), trailing: IconButton(icon: const Icon(Icons.copy, color: Colors.amber, size: 18), onPressed: () => Clipboard.setData(const ClipboardData(text: _upi1)))),
        ListTile(dense: true, title: const Text('Paytm: $_upi2', style: TextStyle(color: Colors.white)), trailing: IconButton(icon: const Icon(Icons.copy, color: Colors.amber, size: 18), onPressed: () => Clipboard.setData(const ClipboardData(text: _upi2)))),
        TextField(controller: utr, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '12-digit UTR No...', hintStyle: TextStyle(color: Colors.white54), filled: true, fillColor: _darkBg)),
        const SizedBox(height: 8),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white), onPressed: () async {
          if (utr.text.trim().length < 6) return;
          await FirebaseFirestore.instance.collection('upi_orders').add({'user': widget.userName, 'item': item, 'amount': amt, 'utr': utr.text.trim(), 'status': 'Pending'});
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text('Submit UTR')),
      ])),
    ));
  }

  void _openAdmin() {
    final pin = TextEditingController();
    showDialog(context: context, builder: (d) => AlertDialog(
      backgroundColor: _cardBg,
      title: const Text('🔐 Admin PIN', style: TextStyle(color: Colors.white)),
      content: TextField(controller: pin, style: const TextStyle(color: Colors.white), obscureText: true, keyboardType: TextInputType.number),
      actions: [ElevatedButton(onPressed: () {
        if (pin.text.trim() != '3525' && pin.text.trim() != '9303323525') return;
        Navigator.pop(d);
        showModalBottomSheet(context: context, backgroundColor: _cardBg, builder: (_) => StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('upi_orders').snapshots(),
          builder: (_, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            return ListView(children: s.data!.docs.map((doc) {
              final m = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('${m['user']} - ${m['item']} (${m['amount']})', style: const TextStyle(color: Colors.white)),
                subtitle: Text('UTR: ${m['utr']} | ${m['status']}', style: const TextStyle(color: Colors.white70)),
                trailing: m['status'] == 'Pending' ? ElevatedButton(onPressed: () {
                  doc.reference.update({'status': 'Approved ✅'});
                  if (m['user'] == widget.userName) m['item'] == 'VIP' ? setState(() => _isVip = true) : widget.onCoins(widget.coins + 500);
                }, child: const Text('Approve')) : const Text('✅'),
              );
            }).toList());
          },
        ));
      }, child: const Text('Unlock'))],
    ));
  }

  void _openChat(String name, String emoji) {
    final c = TextEditingController();
    final id = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(backgroundColor: _cardBg, foregroundColor: Colors.white, title: Text('$emoji $name 🟢'), actions: [IconButton(icon: const Icon(Icons.call, color: Colors.greenAccent), onPressed: () => _openRoom('📞 Call: $name'))]),
      body: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('dm_$id').orderBy('ts', descending: true).snapshots(),
          builder: (_, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            return ListView(reverse: true, padding: const EdgeInsets.all(10), children: s.data!.docs.map((d) {
              final m = d.data() as Map<String, dynamic>;
              return Card(color: _cardBg, child: ListTile(title: Text('${m['sender']}: ${m['text']}', style: const TextStyle(color: Colors.white))));
            }).toList());
          },
        )),
        Container(color: _cardBg, padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
          IconButton(icon: const Text('🌹', style: TextStyle(fontSize: 22)), onPressed: () async {
            if (widget.coins < 10) return;
            widget.onCoins(widget.coins - 10);
            await FirebaseFirestore.instance.collection('dm_$id').add({'sender': _vipName, 'text': '🎁 Sent 🌹 Rose (-10 🪙)', 'ts': FieldValue.serverTimestamp()});
          }),
          Expanded(child: TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Message...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none))),
          IconButton(icon: const Icon(Icons.send, color: Color(0xFFFF7A30)), onPressed: () async {
            if (c.text.trim().isEmpty) return;
            await FirebaseFirestore.instance.collection('dm_$id').add({'sender': _vipName, 'text': c.text.trim(), 'ts': FieldValue.serverTimestamp()});
            c.clear();
          }),
        ])),
      ]),
    )));
  }

  Widget _buildHome() {
    final users = [
      {'name': 'Riya Sharma, 21', 'emoji': '🌸', 'dist': '1.2 km • Music & Late Night 🎧'},
      {'name': 'Simran Kaur, 22', 'emoji': '👑', 'dist': '2.5 km • Shayari & Dosti ❤️'},
      {'name': 'Ananya Verma, 20', 'emoji': '🦋', 'dist': '3.0 km • Voice Match ⚡'},
    ];
    return Container(color: _darkBg, child: ListView(padding: const EdgeInsets.all(12), children: [
      Row(children: [
        ChoiceChip(label: const Text('For You'), selected: !_nearbyOnly, selectedColor: const Color(0xFFFF7A30), labelStyle: const TextStyle(color: Colors.white), onSelected: (_) => setState(() => _nearbyOnly = false)),
        const SizedBox(width: 8),
        ChoiceChip(label: const Text('Nearby 📍'), selected: _nearbyOnly, selectedColor: const Color(0xFFFF7A30), labelStyle: const TextStyle(color: Colors.white), onSelected: (_) => setState(() => _nearbyOnly = true)),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF7A30), Color(0xFFFF3D71)]), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('⚡ Quick Voice Match', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            Text('1-Tap mein live voice call par judein!', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF3D71)), onPressed: () => _openRoom('⚡ Quick Voice Match'), child: const Text('Call')),
        ]),
      ),
      const SizedBox(height: 8),
      Card(color: const Color(0xFF2B1E16), child: ListTile(leading: const Text('👑', style: TextStyle(fontSize: 26)), title: Text(_isVip ? 'Royal VIP Active 👑' : 'Buy Royal VIP (₹99)', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)), subtitle: const Text('Scan QR / UPI to unlock VIP', style: TextStyle(color: Colors.white70, fontSize: 11)), trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black), onPressed: () => _openUpiPay('VIP', '₹99', '99'), child: const Text('₹99')))),
      Card(color: _cardBg, child: ListTile(leading: const Text('🎁', style: TextStyle(fontSize: 24)), title: const Text('Daily Bonus (+50 🪙)', style: TextStyle(color: Colors.white)), trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white), onPressed: _claimed ? null : () { setState(() => _claimed = true); widget.onCoins(widget.coins + 50); }, child: Text(_claimed ? '✅' : 'Claim')))),
      ...users.map((u) => Card(color: _cardBg, child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white12, child: Text(u['emoji']!, style: const TextStyle(fontSize: 22))),
        title: Text('${u['name']} 🟢', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(u['dist']!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white), onPressed: () => _openChat(u['name']!, u['emoji']!), child: const Text('Say Hi')),
      ))),
    ]));
  }

  Widget _buildMoments() {
    return Container(color: _darkBg, child: Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [
        Expanded(child: TextField(controller: _postCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Apni shayari likhein...', hintStyle: TextStyle(color: Colors.white54), filled: true, fillColor: _cardBg))),
        DropdownButton<String>(dropdownColor: _cardBg, value: _postTag, items: ['#Shayari', '#Love', '#Party'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.amber)))).toList(), onChanged: (v) => setState(() => _postTag = v ?? '#Shayari')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white), onPressed: () async {
          if (_postCtrl.text.trim().isEmpty) return;
          await FirebaseFirestore.instance.collection('moments').add({'user': _vipName, 'emoji': _isVip ? '👑' : widget.userEmoji, 'text': _postCtrl.text.trim(), 'tag': _postTag, 'likes': 1});
          _postCtrl.clear();
        }, child: const Text('Post')),
      ])),
      Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('moments').snapshots(), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(children: s.data!.docs.map((d) {
          final m = d.data() as Map<String, dynamic>;
          return Card(color: _cardBg, child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white12, child: Text('${m['emoji'] ?? '😎'}')),
            title: Text('${m['user']} • ${m['tag']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('${m['text']}', style: const TextStyle(color: Colors.white)),
            trailing: TextButton.icon(onPressed: () => d.reference.update({'likes': FieldValue.increment(1)}), icon: const Icon(Icons.favorite, color: Colors.red), label: Text('${m['likes'] ?? 0}', style: const TextStyle(color: Colors.white))),
          ));
        }).toList());
      })),
    ]));
  }

  Widget _buildRooms() {
    final rooms = [
      {'title': '🔥 Desi Adda & Shayari Night', 'host': 'Riya 🌸', 'users': '142'},
      {'title': '🎵 Non-Stop Bollywood Lofi', 'host': 'Aarav 🎧', 'users': '89'},
      {'title': '❤️ Dil Se Dil Tak (Dating)', 'host': 'Simran 👑', 'users': '210'},
    ];
    return Scaffold(
      backgroundColor: _darkBg,
      floatingActionButton: FloatingActionButton.extended(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white, onPressed: () {
        final c = TextEditingController();
        showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: _cardBg, title: const Text('🎙️ New Room', style: TextStyle(color: Colors.white)), content: TextField(controller: c, style: const TextStyle(color: Colors.white)), actions: [ElevatedButton(onPressed: () async {
          final t = c.text.trim().isEmpty ? '$_vipName Room' : c.text.trim();
          await FirebaseFirestore.instance.collection('rooms').add({'title': t, 'host': _vipName});
          if (ctx.mounted) Navigator.pop(ctx);
          _openRoom(t);
        }, child: const Text('Start'))]));
      }, icon: const Icon(Icons.mic), label: const Text('Create Room')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        ...rooms.map((r) => Card(color: _cardBg, child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFFF7A30), child: Text('🎙️')), title: Text(r['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text('Host: ${r['host']}', style: const TextStyle(color: Colors.white60)), trailing: Text('🟢 ${r['users']}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)), onTap: () => _openRoom(r['title']!)))),
        StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('rooms').snapshots(), builder: (_, s) {
          if (!s.hasData) return const SizedBox();
          return Column(children: s.data!.docs.map((d) {
            final m = d.data() as Map<String, dynamic>;
            return Card(color: _cardBg, child: ListTile(leading: const CircleAvatar(backgroundColor: Colors.amber, child: Text('🔥')), title: Text('${m['title']}', style: const TextStyle(color: Colors.white)), subtitle: Text('Host: ${m['host']}', style: const TextStyle(color: Colors.white60)), trailing: const Text('🟢 Live', style: TextStyle(color: Colors.greenAccent)), onTap: () => _openRoom('${m['title']}')));
          }).toList());
        }),
      ]),
    );
  }

  Widget _buildMessages() {
    final friends = [
      {'name': 'Riya Sharma', 'emoji': '🌸', 'msg': 'Live room me aa rahe ho kya? 🎙️', 'u': '2'},
      {'name': 'Simran Kaur', 'emoji': '👑', 'msg': 'Tumhari shayari mast thi ❤️', 'u': '1'},
      {'name': 'Aarav Singh', 'emoji': '🎧', 'msg': 'Aaj raat party room me milte hai 🔥', 'u': '0'},
    ];
    return Container(color: _darkBg, child: ListView(padding: const EdgeInsets.all(12), children: [
      const Card(color: _cardBg, child: ListTile(leading: CircleAvatar(backgroundColor: Color(0xFFFF7A30), child: Icon(Icons.notifications, color: Colors.white)), title: Text('🔔 Toki Official Notice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text('Riya & 3 others visited your profile!', style: TextStyle(color: Colors.white70, fontSize: 12)))),
      ...friends.map((f) => Card(color: _cardBg, child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white12, child: Text(f['emoji']!)),
        title: Text('${f['name']} 🟢', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(f['msg']!, style: const TextStyle(color: Colors.white60)),
        trailing: f['u'] != '0' ? CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text(f['u']!, style: const TextStyle(color: Colors.white, fontSize: 10))) : null,
        onTap: () => _openChat(f['name']!, f['emoji']!),
      ))),
    ]));
  }

  Widget _buildMe() {
    final lv = (widget.coins ~/ 100) + 1;
    return Container(color: _darkBg, child: ListView(padding: const EdgeInsets.all(12), children: [
      Card(color: _cardBg, child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _isVip ? Colors.amber : const Color(0xFFFF7A30), width: 3)), child: CircleAvatar(radius: 26, backgroundColor: Color(widget.userBg), child: Text(_isVip ? '👑' : widget.userEmoji, style: const TextStyle(fontSize: 24)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_vipName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('🎖️ Wealth Lv.$lv  •  💖 Charm Lv.3', style: const TextStyle(color: Colors.amber, fontSize: 12)),
            Text(_bio, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () {
            final b = TextEditingController(text: _bio);
            showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: _cardBg, title: const Text('✏️ Edit Bio', style: TextStyle(color: Colors.white)), content: TextField(controller: b, style: const TextStyle(color: Colors.white)), actions: [ElevatedButton(onPressed: () { setState(() => _bio = b.text.trim()); Navigator.pop(ctx); }, child: const Text('Save'))]));
          }),
        ]),
        const Divider(color: Colors.white24),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text('128\nFollowers', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
          Text('64\nFollowing', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
          Text('42 👀\nVisitors', textAlign: TextAlign.center, style: TextStyle(color: Colors.amber, fontSize: 12)),
        ]),
      ]))),
      Row(children: [
        Expanded(child: Card(color: _cardBg, child: ListTile(title: Text('🪙 ${widget.coins}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)), subtitle: const Text('Recharge Coins', style: TextStyle(color: Colors.white60, fontSize: 11)), onTap: () => _openUpiPay('500 Coins', '₹49', '49')))),
        Expanded(child: Card(color: _cardBg, child: ListTile(title: Text('💎 $_diamonds', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)), subtitle: const Text('Withdraw', style: TextStyle(color: Colors.white60, fontSize: 11)), onTap: (
