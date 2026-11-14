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
  String _postTag = '#Shayari';
  bool _claimed = false, _isVip = false;
  final _postCtrl = TextEditingController();

  static const String _upi1 = 'Pravinsingh231224@ybl';
  static const String _upi2 = 'pravin.3525@ptyes';

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

  void _openUpiPay(String item, String amount, String numAmt) {
    final utrCtrl = TextEditingController();
    final upiUri = Uri.encodeComponent(
      'upi://pay?pa=$_upi1&pn=TokiLite&am=$numAmt&cu=INR',
    );
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=$upiUri';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 14,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '💳 Scan & Pay $amount ($item)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Image.network(qrUrl, height: 150, width: 150),
              ),
              const SizedBox(height: 4),
              const Text(
                'PhonePe / Paytm / GPay se QR Scan karein',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              ListTile(
                dense: true,
                title: const Text('PhonePe: $_upi1'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: _upi1));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied: $_upi1')),
                    );
                  },
                ),
              ),
              ListTile(
                dense: true,
                title: const Text('Paytm: $_upi2'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: _upi2));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied: $_upi2')),
                    );
                  },
                ),
              ),
              TextField(
                controller: utrCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '12-digit UTR / Ref No. dalein...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A30),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (utrCtrl.text.trim().length < 6) return;
                  await FirebaseFirestore.instance.collection('upi_orders').add({
                    'user': widget.userName,
                    'item': item,
                    'amount': amount,
                    'utr': utrCtrl.text.trim(),
                    'status': 'Pending',
                    'ts': FieldValue.serverTimestamp(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ UTR Submitted! Admin verify karega.'),
                      ),
                    );
                  }
                },
                child: const Text('Submit UTR for Verification'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _openAdminPayments() {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('🔐 Enter Admin PIN'),
        content: TextField(
          controller: pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Admin PIN dalein...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinCtrl.text.trim() != '3525' &&
                  pinCtrl.text.trim() != '9303323525') {
                return;
              }
              Navigator.pop(dCtx);
              _showOrdersSheet();
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _showOrdersSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('upi_orders').snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Koi payment request nahi hai'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final m = d.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('${m['user']} - ${m['item']} (${m['amount']})'),
                subtitle: Text('UTR: ${m['utr']} | ${m['status']}'),
                trailing: m['status'] == 'Pending'
                    ? ElevatedButton(
                        onPressed: () {
                          d.reference.update({'status': 'Approved ✅'});
                          if (m['user'] == widget.userName) {
                            if (m['item'] == 'VIP') {
                              setState(() => _isVip = true);
                            } else {
                              widget.onCoins(widget.coins + 500);
                            }
                          }
                        },
                        child: const Text('Approve'),
                      )
                    : const Text('✅'),
              );
            },
          );
        },
      ),
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
              _isVip ? 'Royal VIP Active 👑' : 'Buy Royal VIP (₹99)',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'QR Scan / UPI se VIP banein!',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () => _openUpiPay('VIP', '₹99', '99'),
              child: const Text('Pay ₹99'),
            ),
          ),
        ),
        Card(
          color: const Color(0xFF1E1E2C),
          child: ListTile(
            leading: const Text('🪙', style: TextStyle(fontSize: 26)),
            title: const Text(
              'Buy 500 Coins (₹49)',
              style: TextStyle(color: Colors.white),
            ),
            trailing: ElevatedButton(
              onPressed: () => _openUpiPay('500 Coins', '₹49', '49'),
              child: const Text('Pay ₹49'),
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
        TextButton.icon(
          onPressed: _openAdminPayments,
          icon: const Icon(Icons.lock),
          label: const Text('👑 Admin: Verify Payments (PIN)'),
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
      {'title': '🔥 Desi Adda Night', 'host': 'Riya 🌸'},
      {'title': '🎵 Bollywood Lofi', 'host': 'Aarav 🎧'},
      {'title': '❤️ Dil Se Dil Tak', 'host': 'Simran 👑'},
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
              if (!snap.hasData) return const SizedB
