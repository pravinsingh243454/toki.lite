import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TokiMeScreen extends StatefulWidget {
  final String userName, phone, lang;
  final int coins, selectedAvatar;
  final Function(String name) onNameChanged;
  final Function(int avatarIdx) onAvatarChanged;
  final Function(int newCoins) onCoinsChanged;
  final Function(String newLang) onLangChanged;
  final VoidCallback onLogout;

  const TokiMeScreen({
    super.key,
    required this.userName,
    required this.phone,
    required this.lang,
    required this.coins,
    required this.selectedAvatar,
    required this.onNameChanged,
    required this.onAvatarChanged,
    required this.onCoinsChanged,
    required this.onLangChanged,
    required this.onLogout,
  });

  @override
  State<TokiMeScreen> createState() => _TokiMeScreenState();
}

class _TokiMeScreenState extends State<TokiMeScreen> {
  static const String _phonePeUpi = 'pravinsingh231224@ybl';
  static const String _paytmUpi = 'pravin.3525@ptyes';
  static const String _adminPhone = '9303323525';

  final List _avatars = const [
    {'e': '😎', 'bg': 0xFFFFB74D},
    {'e': '👑', 'bg': 0xFFF48FB1},
    {'e': '🎧', 'bg': 0xFF90CAF9},
    {'e': '🔥', 'bg': 0xFFFF8A65},
    {'e': '🌸', 'bg': 0xFFCE93D8},
    {'e': '🦁', 'bg': 0xFFA5D6A7},
  ];

  bool get isHindi => widget.lang == 'Hindi';
  bool get isAdmin => widget.phone.trim() == _adminPhone;

  void _copyUpi(String upiId, String appName) {
    Clipboard.setData(ClipboardData(text: upiId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ $appName UPI Copied: $upiId')),
    );
  }

  void _openUpiPaymentDialog(String amount, int coinsToAdd) {
    final utrCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isHindi ? '$amount का UPI पेमेंट करें' : 'Pay $amount via UPI'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                tileColor: const Color(0xFFF3E5F5),
                title: const Text('PhonePe: $_phonePeUpi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                trailing: TextButton(onPressed: () => _copyUpi(_phonePeUpi, 'PhonePe'), child: const Text('Copy')),
              ),
              const SizedBox(height: 6),
              ListTile(
                tileColor: const Color(0xFFE1F5FE),
                title: const Text('Paytm: $_paytmUpi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                trailing: TextButton(onPressed: () => _copyUpi(_paytmUpi, 'Paytm'), child: const Text('Copy')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: utrCtrl,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: InputDecoration(
                  labelText: isHindi ? '12 अंकों का UTR नंबर' : '12-Digit UTR Number',
                  counterText: '',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A30), foregroundColor: Colors.white),
            onPressed: () async {
              final utr = utrCtrl.text.trim();
              if (utr.length < 8) return;
              await FirebaseFirestore.instance.collection('payments').add({
                'userName': widget.userName,
                'phone': widget.phone,
                'amount': amount,
                'coins': coinsToAdd,
                'utr': utr,
                'status': 'pending',
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('⏳ Request Sent! Admin approve karte hi +$coinsToAdd Coins milenge')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _openRechargeSheet() {
    final packs = [
      {'rs': '₹10', 'coins': 100},
      {'rs': '₹50', 'coins': 550},
      {'rs': '₹100', 'coins': 1200},
      {'rs': '₹500', 'coins': 6500},
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: packs.map((p) => ListTile(
            leading: const Text('🪙', style: TextStyle(fontSize: 22)),
            title: Text('${p['coins']} Coins', style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F259F), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                _openUpiPaymentDialog(p['rs'].toString(), p['coins'] as int);
              },
              child: Text(p['rs'].toString()),
            ),
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final curAv = _avatars[widget.selectedAvatar % _avatars.length];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF7A30), Color(0xFF4B39EF)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Color(curAv['bg'] as int),
                child: Text(curAv['e'].toString(), style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.userName, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                    Text(
                      isAdmin ? 'ID: ${widget.phone} • 👑 SUPER ADMIN' : 'ID: ${widget.phone} • 👑 VIP 1',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isAdmin) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF6F00)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('👑', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ADMIN PANEL (Owner Control)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('UPI UTR Approve • Users • Complaints', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_avatars.length, (i) => GestureDetector(
            onTap: () => widget.onAvatarChanged(i),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Color(_avatars[i]['bg'] as int),
              child: Text(_avatars[i]['e'].toString(), style: const TextStyle(fontSize: 20)),
            ),
          )),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🪙 मेरा वॉलेट', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('${widget.coins} Coins', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF7A30))),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _openRechargeSheet,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F259F), foregroundColor: Colors.white),
                child: const Text('रिचार्ज (UPI)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFF4B39EF)),
                title: const Text('भाषा (Language)'),
                trailing: Text(widget.lang, style: const TextStyle(color: Color(0xFFFF7A30), fontWeight: FontWeight.bold)),
                onTap: () => widget.onLangChanged(isHindi ? 'English' : 'Hindi'),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('लॉगआउट (Logout)', style: TextStyle(color: Colors.red)),
                onTap: widget.onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4B39EF),
          foregroundColor: Colors.white,
          title: const Text('👑 Admin Control Panel'),
          bottom: const TabBar(
            labelColor: Colors.white,
            tabs: [Tab(text: '💰 UPI UTR'), Tab(text: '👥 Users')],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('payments').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('Abhi koi UPI request nahi hai'));
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i];
                    final m = d.data() as Map<String, dynamic>;
                    final status = (m['status'] ?? 'pending').toString();
                    return Card(
                      child: ListTile(
                        title: Text('${m['userName']} (${m['phone']}) • ${m['amount']}'),
                        subtitle: Text('UTR: ${m['utr']} • +${m['coins']} Coins\nStatus: $status'),
                        trailing: status == 'pending'
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection('users').doc(m['phone'].toString()).set({
                                    'coins': FieldValue.increment((m['coins'] ?? 0) as int),
                                  }, SetOptions(merge: true));
                                  await d.reference.update({'status': 'approved'});
                                },
                                child: const Text('Approve'),
                              )
                            : const Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final u = docs[i].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text('${u['name'] ?? 'User'} (${docs[i].id})'),
                        subtitle: Text('🪙 Coins: ${u['coins'] ?? 0}'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
