import 'package:flutter/material.dart';

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
  final List _avatars = const [
    {'e': '😎', 'bg': 0xFFFFB74D},
    {'e': '👑', 'bg': 0xFFF48FB1},
    {'e': '🎧', 'bg': 0xFF90CAF9},
    {'e': '🔥', 'bg': 0xFFFF8A65},
    {'e': '🌸', 'bg': 0xFFCE93D8},
    {'e': '🦁', 'bg': 0xFFA5D6A7},
  ];

  bool get isHindi => widget.lang == 'Hindi';

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
              isHindi ? '🪙 कॉइन रिचार्ज (PhonePe / UPI)' : '🪙 Coin Recharge (PhonePe / UPI)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isHindi
                  ? 'PhonePe, GPay या Paytm से तुरंत कॉइन जोड़ें'
                  : 'Instant recharge via PhonePe, GPay or Paytm',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 14),
            ...packs.map((p) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF3E0),
                      child: Text('🪙', style: TextStyle(fontSize: 20)),
                    ),
                    title: Text('${p['coins']} Coins (${p['bonus']})',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('PhonePe • Google Pay • Paytm UPI'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F259F),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final add = p['coins'] as int;
                        widget.onCoinsChanged(widget.coins + add);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isHindi
                                ? '✅ ${p['rs']} पेमेंट सफल! +$add कॉइन्स जुड़ गए'
                                : '✅ ${p['rs']} Payment Success! +$add Coins added'),
                          ),
                        );
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
                      ? '✅ आपकी शिकायत दर्ज हो गई है! टीम जल्द मदद करेगी।'
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
