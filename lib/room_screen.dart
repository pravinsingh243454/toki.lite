import 'package:flutter/material.dart';

class PartyRoomScreen extends StatefulWidget {
  final String roomTitle, userName, userEmoji;
  final int userBg, coins;
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
  final List _msgs = ['🎉 Party Room mein swagat hai!'];
  final List _seats = List.generate(9, (i) => i == 1 ? '🌸 Riya' : '🎙️ Empty');

  @override
  void initState() {
    super.initState();
    _coins = widget.coins;
    _seats[0] = '${widget.userEmoji} ${widget.userName}';
  }

  void _sendGift(String name, int cost) {
    if (_coins < cost) return;
    setState(() {
      _coins -= cost;
      _msgs.add('🎁 ${widget.userName} sent $name (-$cost 🪙)');
    });
    widget.onCoins(_coins);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141422),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        foregroundColor: Colors.white,
        title: Text(widget.roomTitle, style: const TextStyle(fontSize: 15)),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 12), child: Text('🪙 $_coins', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))))],
      ),
      body: Column(children: [
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.2),
          itemCount: 9,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => setState(() {
              if (_mySeat != -1) _seats[_mySeat] = '🎙️ Empty';
              _mySeat = i;
              _seats[i] = '${widget.userEmoji} ${widget.userName}';
            }),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 22, backgroundColor: i == _mySeat ? Color(widget.userBg) : Colors.white12, child: Text(_seats[i].toString().split(' ').first)),
              const SizedBox(height: 4),
              Text(_seats[i].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ),
        ),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _msgs.length, itemBuilder: (_, i) => Text(_msgs[i].toString(), style: const TextStyle(color: Colors.white, fontSize: 13)))),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFF1E1E2C),
          child: Row(children: [
            IconButton(onPressed: () => setState(() => _micOn = !_micOn), icon: Icon(_micOn ? Icons.mic : Icons.mic_off, color: _micOn ? Colors.greenAccent : Colors.red)),
            Expanded(child: TextField(controller: _msgCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Say hi...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none))),
            IconButton(onPressed: () => _sendGift('🌹 Rose', 10), icon: const Icon(Icons.card_giftcard, color: Colors.amber)),
            IconButton(onPressed: () { if (_msgCtrl.text.trim().isNotEmpty) { setState(() => _msgs.add('${widget.userName}: ${_msgCtrl.text.trim()}')); _msgCtrl.clear(); } }, icon: const Icon(Icons.send, color: Color(0xFFFF7A30))),
          ]),
        ),
      ]),
    );
  }
}
