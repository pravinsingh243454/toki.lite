import 'package:flutter/material.dart';

class PartyRoomScreen extends StatefulWidget {
  final String roomTitle;
  final String userName;
  final String userEmoji;
  final int userBg;
  final int coins;
  final Function(int newCoins) onCoins;

  const PartyRoomScreen({
    super.key,
    required this.roomTitle,
    required this.userName,
    required this.userEmoji,
    required this.userBg,
    required this.coins,
    required this.onCoins,
  });

  @override
  State<PartyRoomScreen> createState() => _PartyRoomScreenState();
}

class _PartyRoomScreenState extends State<PartyRoomScreen> {
  late int _coins;
  bool _micOn = true;
  int _mySeat = 0;
  final _msgCtrl = TextEditingController();
  final List _msgs = [
    {'user': 'System', 'text': '🎉 Party Room mein aapka swagat hai!'},
  ];

  final List _seats = [
    {'name': 'Host', 'e': '👑', 'bg': 0xFFFFB74D},
    {'name': 'Riya', 'e': '🌸', 'bg': 0xFFF48FB1},
    {'name': 'Empty', 'e': '🎙️', 'bg': 0xFF333344},
    {'name': 'Empty', 'e': '🎙️', 'bg': 0xFF333344},
    {'name': 'Empty', 'e': '🎙️', 'bg': 0xFF333344},
    {'name': 'Empty', 'e': '🎙️', 'bg': 0xFF333344},
    {'name': 'Empty', 'e': '🎙️', 'bg': 0xFF333344},
    {'name': 'Empty', 'e': '🎙️', 'bg': 0xFF333344},
    {'name': 'Empty', 'e': '🎙️', 'bg': 0xFF333344},
  ];

  @override
  void initState() {
    super.initState();
    _coins = widget.coins;
    _seats[0] = {
      'name': widget.userName,
      'e': widget.userEmoji,
      'bg': widget.userBg,
    };
  }

  void _takeSeat(int idx) {
    setState(() {
      if (_mySeat != -1) {
        _seats[_mySeat] = {'name': 'Empty', 'e': '🎙️', 'bg': 0xFF333344};
      }
      _mySeat = idx;
      _seats[idx] = {
        'name': widget.userName,
        'e': widget.userEmoji,
        'bg': widget.userBg,
      };
    });
  }

  void _sendMsg() {
    final t = _msgCtrl.text.trim();
    if (t.isEmpty) return;
    _msgCtrl.clear();
    setState(() => _msgs.add({'user': widget.userName, 'text': t}));
  }

  void _sendGift(String giftName, int cost) {
    if (_coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Coins kam hain! Me tab se recharge karein')),
      );
      return;
    }
    setState(() {
      _coins -= cost;
      _msgs.add({'user': widget.userName, 'text': '🎁 Sent $giftName (-$cost 🪙)'});
    });
    widget.onCoins(_coins);
    Navigator.pop(context);
  }

  void _openGifts() {
    final gifts = [
      {'name': '🌹 Rose', 'cost': 10},
      {'name': '🎂 Cake', 'cost': 50},
      {'name': '🏎️ Sports Car', 'cost': 200},
      {'name': '👑 Royal Crown', 'cost': 500},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎁 Send Gift (🪙 $_coins)',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: gifts.map((g) => GestureDetector(
                onTap: () => _sendGift(g['name'].toString(), g['cost'] as int),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    Text(g['name'].toString(), style: const TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('🪙 ${g['cost']}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                  ]),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141422),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        foregroundColor: Colors.white,
        title: Text(widget.roomTitle, style: const TextStyle(fontSize: 16)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('🪙 $_coins', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.05,
            ),
            itemCount: 9,
            itemBuilder: (_, i) {
              final s = _seats[i];
              return GestureDetector(
                onTap: () => _takeSeat(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(s['bg'] as int),
                      child: Text(s['e'].toString(), style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${i + 1}. ${s['name']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _msgs.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${_msgs[i]['user']}: ${_msgs[i]['text']}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF1E1E2C),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _micOn = !_micOn),
                  icon: Icon(_micOn ? Icons.mic : Icons.mic_off,
                      color: _micOn ? Colors.greenAccent : Colors.redAccent),
                ),
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _sendMsg(),
                    decoration: const InputDecoration(
                      hintText: 'Say hi...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _openGifts,
                  icon: const Icon(Icons.card_giftcard, color: Colors.amber),
                ),
                IconButton(
                  onPressed: _sendMsg,
                  icon: const Icon(Icons.send, color: Color(0xFFFF7A30)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
