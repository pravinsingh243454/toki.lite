import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TokiMeScreen extends StatefulWidget {
  final String userName;
  final String phone;
  final String lang;
  final int coins;
  final int selectedAvatar;
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

  final List _avatars = const [
    {'e': '😎', 'bg': 0xFFFFB74D},
    {'e': '👑', 'bg': 0xFFF48FB1},
    {'e': '🎧', 'bg': 0xFF90CAF9},
    {'e': '🔥', 'bg': 0xFFFF8A65},
    {'e': '🌸', 'bg': 0xFFCE93D8},
    {'e': '🦁', 'bg': 0xFFA5D6A7},
  ];

  bool get isHindi => widget.lang == 'Hindi';

  void _copyUpi(String upiId, String appName) {
    Clipboard.setData(ClipboardData(text: upiId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isHindi
            ? '✅ $appName UPI कॉपी हो गया: $upiId'
            : '✅ $appName UPI Copied: $upiId'),
      ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHindi
                    ? 'नीचे दी गई UPI ID पर $amount भेजें और 12 अंकों का UTR नंबर डालें:'
                    : 'Send $amount to any UPI ID below and enter 12-digit UTR:',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'PhonePe:\n$_phonePeUpi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _copyUpi(_phonePeUpi, 'PhonePe'),
                      child: const Text('Copy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Paytm:\n$_paytmUpi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _copyUpi(_paytmUpi, 'Paytm'),
                      child: const Text('Copy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: utrCtrl,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: InputDecoration(
                  labelText: isHindi ? '12 अंकों का UTR / Ref नंबर' : '12-Digit UTR Number',
                  counterText: '',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A30),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (utrCtrl.text.trim().length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isHindi
                        ? '⚠️ कृपया सही UTR नंबर डालें'
                        : '⚠️ Please enter valid UTR number'),
                  ),
                );
                return;
              }
              widget.onCoinsChanged(widget.coins + coinsToAdd);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHindi
                      ? '🎉 पेमेंट सबमिट! +$coinsToAdd कॉइन्स जुड़ गए'
                      : '🎉 Payment Submitted! +$coinsToAdd Coins added'),
                ),
              );
            },
            child: Text(isHindi ? 'पेमेंट कन्फ़र्म करें' : 'Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _openRechargeSheet() {
    final packs = [
      {'rs': '₹10', 'coins': 100, 'bonus': '+10 Free'},
      {'rs': '₹50', 'coins': 550, 'bonus': '+50 Free'},
      {'rs': '₹100', 'coins': 1200, 'bonus': '+200 Free'},
      {'rs': '₹500', 'coins': 6500, 'bonus': '+1500 Free'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHindi ? '🪙 कॉइन रिचार्ज (PhonePe / Paytm)' : '🪙 Coin Recharge (UPI)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...packs.map((p) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF3E0),
                      child: Text('🪙', style: TextStyle(fontSize: 20)),
                    ),
                    title: Text('${p['coins']} Coins (${p['bonus']})',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('PhonePe • Paytm UPI'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F259F),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openUpiPaymentDialog(
                            p['rs'].toString(), p['coins'] as int);
                      },
                      child: Text(p['rs'].toString()),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _openEditName() {
    final ctrl = TextEditingController(text: widget.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isHindi ? 'अपना नाम बदलें' : 'Edit Your Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A30),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                widget.onNameChanged(ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: Text(isHindi ? 'सेव करें' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _openHelpDialog() {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isHindi ? '📩 सहायता और शिकायत' : '📩 Help & Complaint'),
        content: TextField(
          controller: msgCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: isHindi
                ? 'अपनी समस्या या शिकायत यहाँ लिखें...'
                : 'Write your issue or feedback here...',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isHindi ? 'बंद करें' : 'Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A30),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHindi
                      ? '✅ आपकी शिकायत दर्ज हो गई है!'
                      : '✅ Your complaint has been submitted!'),
                ),
              );
            },
            child: Text(isHindi ? 'भेजें' : 'Submit'),
          ),
        ],
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
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A30), Color(0xFF4B39EF)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Color(curAv['bg'] as int),
                child: Text(curAv['e'].toString(),
                    style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _openEditName,
                          icon: const Icon(Icons.edit,
                              color: Colors.white70, size: 18),
                        ),
                      ],
                    ),
                    Text(
                      'ID: ${widget.phone}  •  👑 VIP 1',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isHindi ? 'अपना अवतार चुनें:' : 'Select Your Avatar:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_avatars.length, (i) {
            final sel = widget.selectedAvatar == i;
            return GestureDetector(
              onTap: () => widget.onAvatarChanged(i),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: sel
                      ? Border.all(color: const Color(0xFFFF7A30), width: 3)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(_avatars[i]['bg'] as int),
                  child: Text(_avatars[i]['e'].toString(),
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isHindi ? '🪙 मेरा वॉलेट' : '🪙 My Wallet',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${widget.coins} Coins',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7A30))),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openRechargeSheet,
                icon: const Icon(Icons.account_balance_wallet, size: 18),
                label: Text(isHindi ? 'रिचार्ज (UPI)' : 'Recharge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F259F),
                  foregroundColor: Colors.white,
                ),
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
                title: Text(isHindi ? 'भाषा (Language)' : 'Language'),
                trailing: Text(widget.lang,
                    style: const TextStyle(
                        color: Color(0xFFFF7A30), fontWeight: FontWeight.bold)),
                onTap: () =>
                    widget.onLangChanged(isHindi ? 'English' : 'Hindi'),
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(Icons.support_agent, color: Color(0xFFFF7A30)),
                title: Text(
                    isHindi ? 'सहायता और शिकायत (Help)' : 'Help & Complaint'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openHelpDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(isHindi ? 'लॉगआउट (Logout)' : 'Logout',
                    style: const TextStyle(color: Colors.red)),
                onTap: widget.onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
