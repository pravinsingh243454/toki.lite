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
  String _postTag = '#Shayari', _bio = 'Music, Shayari & Live Party 🎙️✨';
  bool _claimed = false, _isVip = false;
  int _diamonds = 120;
  final _postCtrl = TextEditingController();
  static const _upi1 = 'Pravinsingh231224@ybl', _upi2 = 'pravin.3525@ptyes';

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
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 12),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('💳 Scan & Pay $amt ($item)', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Image.network(qr, height: 140, width: 140),
        ListTile(dense: true, title: const Text('PhonePe: $_upi1'), trailing: IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () => Clipboard.setData(const ClipboardData(text: _upi1)))),
        ListTile(dense: true, title: const Text('Paytm: $_upi2'), trailing: IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () => Clipboard.setData(const ClipboardData(text: _upi2)))),
        TextField(controller: utr, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '12-digit UTR No...', border: OutlineInputBorder())),
        ElevatedButton(onPressed: () async {
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
      title: const Text('🔐 Admin PIN'),
      content: TextField(controller: pin, obscureText: true, keyboardType: TextInputType.number),
      actions: [ElevatedButton(onPressed: () {
        if (pin.text.trim() != '3525' && pin.text.trim() != '9303323525') return;
        Navigator.pop(d);
        showModalBottomSheet(context: context, builder: (_) => StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('upi_orders').snapshots(),
          builder: (_, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            return ListView(children: s.data!.docs.map((doc) {
              final m = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('${m['user']} - ${m['item']} (${m['amount']})'),
                subtitle: Text('UTR: ${m['utr']} | ${m['status']}'),
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
      appBar: AppBar(backgroundColor: const Color(0xFF1E1E2C), foregroundColor: Colors.white, title: Text('$emoji $name 🟢'), actions: [IconButton(icon: const Icon(Icons.call, color: Colors.greenAccent), onPressed: () => _openRoom('📞 Call: $name'))]),
      body: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('dm_$id').orderBy('ts', descending: true).snapshots(),
          builder: (_, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            return ListView(reverse: true, padding: const EdgeInsets.all(10), children: s.data!.docs.map((d) {
              final m = d.data() as Map<String, dynamic>;
              return Card(child: ListTile(title: Text('${m['sender']}: ${m['text']}')));
            }).toList());
          },
        )),
        Row(children: [
          IconButton(icon: const Text('🌹', style: TextStyle(fontSize: 22)), onPressed: () async {
            if (widget.coins < 10) return;
            widget.onCoins(widget.coins - 10);
            await FirebaseFirestore.instance.collection('dm_$id').add({'sender': _vipName, 'text': '🎁 Sent 🌹 Rose (-10 🪙)', 'ts': FieldValue.serverTimestamp()});
          }),
          Expanded(child: TextField(controller: c, decoration: const InputDecoration(hintText: 'Message...'))),
          IconButton(icon: const Icon(Icons.send, color: Color(0xFFFF7A30)), onPressed: () async {
            if (c.text.trim().isEmpty) return;
            await FirebaseFirestore.instance.collection('dm_$id').add({'sender': _vipName, 'text': c.text.trim(), 'ts': FieldValue.serverTimestamp()});
            c.clear();
          }),
        ]),
      ]),
    )));
  }

  Widget _buildHome() {
    final users = [{'name': 'Riya Sharma', 'emoji': '🌸'}, {'name': 'Simran Kaur', 'emoji': '👑'}, {'name': 'Ananya Verma', 'emoji': '🦋'}];
    return ListView(padding: const EdgeInsets.all(12), children: [
      Card(color: const Color(0xFFFF7A30), child: ListTile(title: const Text('⚡ Quick Voice Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), trailing: ElevatedButton(onPressed: () => _openRoom('⚡ Quick Voice Match'), child: const Text('Call')))),
      Card(color: const Color(0xFF2B1E16), child: ListTile(leading: const Text('👑', style: TextStyle(fontSize: 26)), title: Text(_isVip ? 'Royal VIP Active 👑' : 'Buy Royal VIP (₹99)', style: const TextStyle(color: Colors.amber)), trailing: ElevatedButton(onPressed: () => _openUpiPay('VIP', '₹99', '99'), child: const Text('₹99')))),
      Card(color: const Color(0xFF1E1E2C), child: ListTile(leading: const Text('🪙', style: TextStyle(fontSize: 24)), title: const Text('Buy 500 Coins (₹49)', style: TextStyle(color: Colors.white)), trailing: ElevatedButton(onPressed: () => _openUpiPay('500 Coins', '₹49', '49'), child: const Text('₹49')))),
      Card(color: const Color(0xFF1E1E2C), child: ListTile(leading: const Text('🎁', style: TextStyle(fontSize: 24)), title: const Text('Daily Bonus (+50 🪙)', style: TextStyle(color: Colors.white)), trailing: ElevatedButton(onPressed: _claimed ? null : () { setState(() => _claimed = true); widget.onCoins(widget.coins + 50); }, child: Text(_claimed ? '✅' : 'Claim')))),
      TextButton.icon(onPressed: _openAdmin, icon: const Icon(Icons.lock), label: const Text('👑 Admin: Verify Payments')),
      ...users.map((u) => Card(child: ListTile(leading: CircleAvatar(child: Text(u['emoji']!)), title: Text('${u['name']} 🟢'), trailing: ElevatedButton(onPressed: () => _openChat(u['name']!, u['emoji']!), child: const Text('Say Hi 👋'))))),
    ]);
  }

  Widget _buildMoments() {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [
        Expanded(child: TextField(controller: _postCtrl, decoration: const InputDecoration(hintText: 'Shayari...'))),
        DropdownButton<String>(value: _postTag, items: ['#Shayari', '#Love', '#Party'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _postTag = v ?? '#Shayari')),
        ElevatedButton(onPressed: () async {
          if (_postCtrl.text.trim().isEmpty) return;
          await FirebaseFirestore.instance.collection('moments').add({'user': _vipName, 'emoji': _isVip ? '👑' : widget.userEmoji, 'text': _postCtrl.text.trim(), 'tag': _postTag, 'likes': 1});
          _postCtrl.clear();
        }, child: const Text('Post')),
      ])),
      Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('moments').snapshots(), builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(children: s.data!.docs.map((d) {
          final m = d.data() as Map<String, dynamic>;
          return Card(child: ListTile(leading: CircleAvatar(child: Text('${m['emoji'] ?? '😎'}')), title: Text('${m['user']} (${m['tag']})'), subtitle: Text('${m['text']}'), trailing: TextButton.icon(onPressed: () => d.reference.update({'likes': FieldValue.increment(1)}), icon: const Icon(Icons.favorite, color: Colors.red), label: Text('${m['likes'] ?? 0}'))));
        }).toList());
      })),
    ]);
  }

  Widget _buildRooms() {
    final rooms = [{'title': '🔥 Desi Adda Night', 'host': 'Riya 🌸'}, {'title': '🎵 Bollywood Lofi', 'host': 'Aarav 🎧'}, {'title': '❤️ Dil Se Dil Tak', 'host': 'Simran 👑'}];
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFFFF7A30), onPressed: () {
        final c = TextEditingController();
        showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('🎙️ New Room'), content: TextField(controller: c), actions: [ElevatedButton(onPressed: () async {
          final t = c.text.trim().isEmpty ? '$_vipName Room' : c.text.trim();
          await FirebaseFirestore.instance.collection('rooms').add({'title': t, 'host': _vipName});
          if (ctx.mounted) Navigator.pop(ctx);
          _openRoom(t);
        }, child: const Text('Start'))]));
      }, child: const Icon(Icons.mic, color: Colors.white)),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        ...rooms.map((r) => Card(child: ListTile(title: Text(r['title']!), subtitle: Text('Host: ${r['host']}'), trailing: const Text('🟢 Join'), onTap: () => _openRoom(r['title']!)))),
        StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('rooms').snapshots(), builder: (_, s) {
          if (!s.hasData) return const SizedBox();
          return Column(children: s.data!.docs.map((d) {
            final m = d.data() as Map<String, dynamic>;
            return Card(child: ListTile(title: Text('${m['title']}'), subtitle: Text('Host: ${m['host']}'), onTap: () => _openRoom('${m['title']}')));
          }).toList());
        }),
      ]),
    );
  }

  Widget _buildMessages() {
    final friends = [{'name': 'Riya Sharma', 'emoji': '🌸', 'msg': 'Live room me aao 🎙️'}, {'name': 'Simran Kaur', 'emoji': '👑', 'msg': 'Mast shayari thi ❤️'}];
    return ListView(padding: const EdgeInsets.all(12), children: [
      const Card(color: Color(0xFF1E1E2C), child: ListTile(title: Text('🔔 Toki Official Notice', style: TextStyle(color: Colors.white)), subtitle: Text('Welcome to Toki Lite VIP!', style: TextStyle(color: Colors.white70)))),
      ...friends.map((f) => Card(child: ListTile(leading: CircleAvatar(child: Text(f['emoji']!)), title: Text('${f['name']} 🟢'), subtitle: Text(f['msg']!), onTap: () => _openChat(f['name']!, f['emoji']!)))),
    ]);
  }

  Widget _buildMe() {
    final lv = (widget.coins ~/ 100) + 1;
    return ListView(padding: const EdgeInsets.all(12), children: [
      Card(color: const Color(0xFF1E1E2C), child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
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
            showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('✏️ Edit Bio'), content: TextField(controller: b), actions: [ElevatedButton(onPressed: () { setState(() => _bio = b.text.trim()); Navigator.pop(ctx); }, child: const Text('Save'))]));
          }),
        ]),
        const Divider(color: Colors.white24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
          Text('128\nFollowers', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
          Text('64\nFollowing', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
          Text('42 👀\nVisitors', textAlign: TextAlign.center, style: TextStyle(color: Colors.amber, fontSize: 12)),
        ]),
      ]))),
      Row(children: [
        Expanded(child: Card(child: ListTile(title: Text('🪙 ${widget.coins}', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('My Coins'), onTap: () => _openUpiPay('500 Coins', '₹49', '49')))),
        Expanded(child: Card(child: ListTile(title: Text('💎 $_diamonds', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Withdraw'), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💎 Min 500 Diamonds par UPI Withdraw khulega!')))))),
      ]),
      Card(child: ListTile(leading: const Text('🎒', style: TextStyle(fontSize: 22)), title: const Text('My Backpack & VIP Frame'), subtitle: Text(_isVip ? '👑 Royal VIP Frame Equipped' : 'Buy VIP to unlock Royal Frame'), onTap: () => _openUpiPay('VIP', '₹99', '99'))),
      Card(child: ListTile(leading: const Text('🎁', style: TextStyle(fontSize: 22)), title: const Text('Invite Friends (+100 🪙)'), subtitle: const Text('Share Toki Lite & earn free coins'), onTap: () { widget.onCoins(widget.coins + 100); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Referral Link Copied! +100 Coins Added'))); })),
      Card(child: ListTile(leading: const Icon(Icons.admin_panel_settings, color: Colors.amber), title: const Text('👑 Admin Payment Panel (PIN)'), onTap: _openAdmin)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabIndex == 1) return _buildMoments();
    if (widget.tabIndex == 2) return _buildRooms();
    if (widget.tabIndex == 3) return _buildMessages();
    if (widget.tabIndex == 4) return _buildMe();
    return _buildHome();
  }
}
