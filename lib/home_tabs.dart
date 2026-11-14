import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'room_screen.dart';

class TokiHomeTabs extends StatefulWidget {
  final int tabIndex, coins, userBg;
  final String userName, userEmoji, lang;
  final Function(int newCoins) onCoins;
  const TokiHomeTabs({super.key, required this.tabIndex, required this.userName, required this.userEmoji, required this.userBg, required this.coins, required this.lang, required this.onCoins});
  @override
  State<TokiHomeTabs> createState() => _TokiHomeTabsState();
}

class _TokiHomeTabsState extends State<TokiHomeTabs> {
  String _tag = '#Shayari', _bio = 'Music & Late Night Talks 🎙️';
  bool _claimed = false, _vip = false;
  final _postCtrl = TextEditingController();
  static const _u1 = 'Pravinsingh231224@ybl', _u2 = 'pravin.3525@ptyes', _bg = Color(0xFF121218), _card = Color(0xFF1E1E2A);
  String get _name => _vip ? '👑 [VIP] ${widget.userName}' : widget.userName;

  void _room(String t) => Navigator.push(context, MaterialPageRoute(builder: (_) => PartyRoomScreen(roomTitle: t, userName: _name, userEmoji: _vip ? '👑' : widget.userEmoji, userBg: widget.userBg, coins: widget.coins, onCoins: widget.onCoins)));

  void _pay(String item, String amt, String n) {
    final utr = TextEditingController();
    final qr = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent('upi://pay?pa=$_u1&pn=TokiLite&am=$n&cu=INR')}';
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: _card, builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('💳 Scan & Pay $amt ($item)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(color: Colors.white, padding: const EdgeInsets.all(4), child: Image.network(qr, height: 130, width: 130)),
        ListTile(dense: true, title: const Text('PhonePe: $_u1', style: TextStyle(color: Colors.white)), trailing: IconButton(icon: const Icon(Icons.copy, color: Colors.amber), onPressed: () => Clipboard.setData(const ClipboardData(text: _u1)))),
        ListTile(dense: true, title: const Text('Paytm: $_u2', style: TextStyle(color: Colors.white)), trailing: IconButton(icon: const Icon(Icons.copy, color: Colors.amber), onPressed: () => Clipboard.setData(const ClipboardData(text: _u2)))),
        TextField(controller: utr, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '12-digit UTR...', hintStyle: TextStyle(color: Colors.white54))),
        ElevatedButton(onPressed: () async {
          if (utr.text.trim().length < 6) return;
          await FirebaseFirestore.instance.collection('upi_orders').add({'user': widget.userName, 'item': item, 'amount': amt, 'utr': utr.text.trim(), 'status': 'Pending'});
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text('Submit UTR')),
      ]),
    ));
  }

  void _admin() {
    final p = TextEditingController();
    showDialog(context: context, builder: (d) => AlertDialog(backgroundColor: _card, title: const Text('🔐 PIN', style: TextStyle(color: Colors.white)), content: TextField(controller: p, style: const TextStyle(color: Colors.white), obscureText: true), actions: [ElevatedButton(onPressed: () {
      if (p.text.trim() != '3525' && p.text.trim() != '9303323525') return;
      Navigator.pop(d);
      showModalBottomSheet(context: context, backgroundColor: _card, builder: (_) => StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('upi_orders').snapshots(), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(children: s.data!.docs.map((doc) {
          final m = doc.data() as Map<String, dynamic>;
          return ListTile(title: Text('${m['user']} - ${m['item']}', style: const TextStyle(color: Colors.white)), subtitle: Text('UTR: ${m['utr']}', style: const TextStyle(color: Colors.white70)), trailing: m['status'] == 'Pending' ? ElevatedButton(onPressed: () { doc.reference.update({'status': 'Approved ✅'}); if (m['user'] == widget.userName) m['item'] == 'VIP' ? setState(() => _vip = true) : widget.onCoins(widget.coins + 500); }, child: const Text('Approve')) : const Text('✅'));
        }).toList());
      }));
    }, child: const Text('Unlock'))]));
  }

  void _chat(String name, String emoji) {
    final c = TextEditingController(), id = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(backgroundColor: _card, foregroundColor: Colors.white, title: Text('$emoji $name 🟢'), actions: [IconButton(icon: const Icon(Icons.call, color: Colors.greenAccent), onPressed: () => _room('📞 Call: $name'))]),
      body: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('dm_$id').orderBy('ts', descending: true).snapshots(), builder: (_, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(reverse: true, children: s.data!.docs.map((d) { final m = d.data() as Map<String, dynamic>; return Card(color: _card, child: ListTile(title: Text('${m['sender']}: ${m['text']}', style: const TextStyle(color: Colors.white)))); }).toList());
        })),
        Row(children: [
          Expanded(child: TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Message...', hintStyle: TextStyle(color: Colors.white54)))),
          IconButton(icon: const Icon(Icons.send, color: Color(0xFFFF7A30)), onPressed: () async { if (c.text.trim().isEmpty) return; await FirebaseFirestore.instance.collection('dm_$id').add({'sender': _name, 'text': c.text.trim(), 'ts': FieldValue.serverTimestamp()}); c.clear(); }),
        ]),
      ]),
    )));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabIndex == 1) {
      return Container(color: _bg, child: Column(children: [
        Row(children: [
          Expanded(child: TextField(controller: _postCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Shayari...', hintStyle: TextStyle(color: Colors.white54)))),
          DropdownButton<String>(dropdownColor: _card, value: _tag, items: ['#Shayari', '#Love', '#Party'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.amber)))).toList(), onChanged: (v) => setState(() => _tag = v ?? '#Shayari')),
          ElevatedButton(onPressed: () async { if (_postCtrl.text.trim().isEmpty) return; await FirebaseFirestore.instance.collection('moments').add({'user': _name, 'text': _postCtrl.text.trim(), 'tag': _tag, 'likes': 1}); _postCtrl.clear(); }, child: const Text('Post')),
        ]),
        Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('moments').snapshots(), builder: (_, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(children: s.data!.docs.map((d) { final m = d.data() as Map<String, dynamic>; return Card(color: _card, child: ListTile(title: Text('${m['user']} • ${m['tag']}', style: const TextStyle(color: Colors.amber)), subtitle: Text('${m['text']}', style: const TextStyle(color: Colors.white)), trailing: IconButton(icon: const Icon(Icons.favorite, color: Colors.red), onPressed: () => d.reference.update({'likes': FieldValue.increment(1)})))); }).toList());
        })),
      ]));
    }
    if (widget.tabIndex == 2) {
      return Scaffold(backgroundColor: _bg, floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFFFF7A30), onPressed: () => _room('$_name Live Room'), child: const Icon(Icons.mic, color: Colors.white)), body: ListView(padding: const EdgeInsets.all(10), children: [
        Card(color: _card, child: ListTile(title: const Text('🔥 Desi Adda Night', style: TextStyle(color: Colors.white)), subtitle: const Text('Host: Riya 🌸 • 142 Online', style: TextStyle(color: Colors.greenAccent)), onTap: () => _room('🔥 Desi Adda Night'))),
        Card(color: _card, child: ListTile(title: const Text('🎵 Bollywood Lofi', style: TextStyle(color: Colors.white)), subtitle: const Text('Host: Aarav 🎧 • 89 Online', style: TextStyle(color: Colors.greenAccent)), onTap: () => _room('🎵 Bollywood Lofi'))),
        Card(color: _card, child: ListTile(title: const Text('❤️ Dil Se Dil Tak', style: TextStyle(color: Colors.white)), subtitle: const Text('Host: Simran 👑 • 210 Online', style: TextStyle(color: Colors.greenAccent)), onTap: () => _room('❤️ Dil Se Dil Tak'))),
      ]));
    }
    if (widget.tabIndex == 3) {
      return Container(color: _bg, child: ListView(padding: const EdgeInsets.all(10), children: [
        const Card(color: _card, child: ListTile(title: Text('🔔 Toki Official Notice', style: TextStyle(color: Colors.amber)), subtitle: Text('Welcome to Toki Lite Dark VIP!', style: TextStyle(color: Colors.white70)))),
        Card(color: _card, child: ListTile(leading: const Text('🌸', style: TextStyle(fontSize: 24)), title: const Text('Riya Sharma 🟢', style: TextStyle(color: Colors.white)), subtitle: const Text('Live room me aa rahe ho kya?', style: TextStyle(color: Colors.white60)), onTap: () => _chat('Riya Sharma', '🌸'))),
        Card(color: _card, child: ListTile(leading: const Text('👑', style: TextStyle(fontSize: 24)), title: const Text('Simran Kaur 🟢', style: TextStyle(color: Colors.white)), subtitle: const Text('Tumhari shayari mast thi ❤️', style: TextStyle(color: Colors.white60)), onTap: () => _chat('Simran Kaur', '👑'))),
      ]));
    }
    if (widget.tabIndex == 4) {
      return Container(color: _bg, child: ListView(padding: const EdgeInsets.all(12), children: [
        Card(color: _card, child: ListTile(leading: Text(_vip ? '👑' : widget.userEmoji, style: const TextStyle(fontSize: 30)), title: Text(_name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text('Wealth Lv.${(widget.coins ~/ 100) + 1} • $_bio', style: const TextStyle(color: Colors.amber)), trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () { final b = TextEditingController(text: _bio); showDialog(context: context, builder: (c) => AlertDialog(content: TextField(controller: b), actions: [ElevatedButton(onPressed: () { setState(() => _bio = b.text); Navigator.pop(c); }, child: const Text('Save'))])); }))),
        Card(color: _card, child: const ListTile(title: Text('128 Followers  •  64 Following  •  42 Visitors 👀', style: TextStyle(color: Colors.white, fontSize: 13)))),
        Card(color: _card, child: ListTile(title: Text('🪙 ${widget.coins} Coins  |  💎 120 Diamonds', style: const TextStyle(color: Colors.amber)), trailing: ElevatedButton(onPressed: () => _pay('500 Coins', '₹49', '49'), child: const Text('Topup')))),
        Card(color: _card, child: ListTile(title: const Text('👑 Admin Payment Panel (PIN)', style: TextStyle(color: Colors.white)), onTap: _admin)),
      ]));
    }
    return Container(color: _bg, child: ListView(padding: const EdgeInsets.all(12), children: [
      Card(color: const Color(0xFFFF7A30), child: ListTile(title: const Text('⚡ Quick Voice Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), trailing: ElevatedButton(onPressed: () => _room('⚡ Quick Voice Match'), child: const Text('Call')))),
      Card(color: const Color(0xFF2B1E16), child: ListTile(title: Text(_vip ? 'Royal VIP Active 👑' : 'Buy Royal VIP (₹99)', style: const TextStyle(color: Colors.amber)), trailing: ElevatedButton(onPressed: () => _pay('VIP', '₹99', '99'), child: const Text('₹99')))),
      Card(color: _card, child: ListTile(title: const Text('🎁 Daily Bonus (+50 🪙)', style: TextStyle(color: Colors.white)), trailing: ElevatedButton(onPressed: _claimed ? null : () { setState(() => _claimed = true); widget.onCoins(widget.coins + 50); }, child: Text(_claimed ? '✅' : 'Claim')))),
      Card(color: _card, child: ListTile(leading: const Text('🌸', style: TextStyle(fontSize: 24)), title: const Text('Riya Sharma, 21 🟢', style: TextStyle(color: Colors.white)), trailing: ElevatedButton(onPressed: () => _chat('Riya Sharma', '🌸'), child: const Text('Say Hi')))),
      Card(color: _card, child: ListTile(leading: const Text('👑', style: TextStyle(fontSize: 24)), title: const Text('Simran Kaur, 22 🟢', style: TextStyle(color: Colors.white)), trailing: ElevatedButton(onPressed: () => _chat('Simran Kaur', '👑'), child: const Text('Say Hi')))),
    ]));
  }
}
