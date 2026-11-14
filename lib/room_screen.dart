import 'dart:math';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

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
  static const String _appId = '9536ab4655bd4c20830e12442dbe5fb5';
  late RtcEngine _engine;
  bool _joined = false, _micOn = true;
  late int _coins;
  int _mySeat = 0, _topGiftCoins = 0;
  String _topGifter = 'None', _roomPin = '';
  String? _bannerText;
  final _msgCtrl = TextEditingController();
  final List<String> _msgs = ['👑 Welcome to Toki Official Party Room!'];
  final List<String> _seats = List.generate(9, (i) => i == 1 ? '🌸 Riya' : '🎙️ Seat ${i + 1}');
  final List<bool> _locked = List.generate(9, (_) => false);

  @override
  void initState() {
    super.initState();
    _coins = widget.coins;
    _seats[0] = '${widget.userEmoji} ${widget.userName}';
    _initAgora();
  }

  Future<void> _initAgora() async {
    await Permission.microphone.request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: _appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (c, e) {
        if (mounted) setState(() { _joined = true; _msgs.add('✅ Live Voice Connected! 🎤'); });
      },
      onUserJoined: (c, uid, e) {
        if (mounted) setState(() => _msgs.add('✨ User $uid joined the room'));
      },
    ));
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableAudio();
    final ch = widget.roomTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    await _engine.joinChannel(token: '', channelId: ch.isEmpty ? 'tokiroom1' : ch, uid: 0, options: const ChannelMediaOptions());
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _toggleMic() async {
    setState(() => _micOn = !_micOn);
    await _engine.muteLocalAudioStream(!_micOn);
  }

  void _showBanner(String t) {
    setState(() => _bannerText = t);
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _bannerText = null); });
  }

  void _setRoomLock() {
    final pinCtrl = TextEditingController(text: _roomPin);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: const Text('🔒 Room Password Lock', style: TextStyle(color: Colors.amber)),
      content: TextField(controller: pinCtrl, keyboardType: TextInputType.number, maxLength: 4, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: '4-digit PIN (khali = unlock)', hintStyle: TextStyle(color: Colors.white38))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          setState(() {
            _roomPin = pinCtrl.text.trim();
            _msgs.add(_roomPin.isEmpty ? '🔓 Room Unlocked!' : '🔒 Host ne Room Lock ($_roomPin) lagaya!');
          });
          Navigator.pop(ctx);
        }, child: const Text('Save')),
      ],
    ));
  }
    void _onSeatTap(int i) {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF1E1E2C), builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(
        leading: const Icon(Icons.event_seat, color: Colors.amber),
        title: Text(_mySeat == i ? 'Leave Seat (Utrein)' : 'Take Seat ${i + 1}', style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(ctx);
          if (_locked[i] && _mySeat != i) return;
          setState(() {
            if (_mySeat == i) {
              _seats[i] = '🎙️ Seat ${i + 1}';
              _mySeat = -1;
            } else {
              if (_mySeat != -1) _seats[_mySeat] = '🎙️ Seat ${_mySeat + 1}';
              _mySeat = i;
              _seats[i] = '${widget.userEmoji} ${widget.userName}';
            }
          });
        },
      ),
      if (i > 0)
        ListTile(
          leading: Icon(_locked[i] ? Icons.lock_open : Icons.lock, color: Colors.orangeAccent),
          title: Text(_locked[i] ? 'Unlock Seat ${i + 1}' : 'Lock Seat ${i + 1}', style: const TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(ctx);
            setState(() {
              _locked[i] = !_locked[i];
              _seats[i] = _locked[i] ? '🔒 Locked' : '🎙️ Seat ${i + 1}';
            });
          },
        ),
    ]));
  }

  void _sendGift(String name, int cost) {
    if (_coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Kam Coins! Pehle Recharge karein')));
      return;
    }
    setState(() {
      _coins -= cost;
      _topGiftCoins += cost;
      _topGifter = widget.userName;
      _msgs.add('🎁 ${widget.userName} sent $name (-$cost 🪙)');
    });
    widget.onCoins(_coins);
    if (cost >= 50) _showBanner('🔥 ${widget.userName} ne $name bheja! 🔥');
  }

  void _openGifts() {
    final list = [{'n': '🌹 Rose', 'c': 10}, {'n': '💍 Ring', 'c': 50}, {'n': '🏎️ Car', 'c': 200}, {'n': '👑 Crown', 'c': 500}];
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF1E1E2C), builder: (ctx) => Wrap(
      children: list.map((g) => ListTile(
        title: Text('${g['n']} (${g['c']} 🪙)', style: const TextStyle(color: Colors.white)),
        onTap: () { Navigator.pop(ctx); _sendGift(g['n'].toString(), g['c'] as int); },
      )).toList(),
    ));
  }

  void _openGames() {
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF1E1E2C), builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.all(12), child: Text('🎮 Toki Party Games', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16))),
      ListTile(
        leading: const Text('🎲', style: TextStyle(fontSize: 24)),
        title: const Text('Roll Ludo Dice (Free)', style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(ctx);
          final d = Random().nextInt(6) + 1;
          setState(() => _msgs.add('🎲 ${widget.userName} rolled Dice: [ $d ]'));
        },
      ),
      ListTile(
        leading: const Text('🎭', style: TextStyle(fontSize: 24)),
        title: const Text('Truth & Dare Spin (Free)', style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(ctx);
          final tasks = ['Truth: Apna pehla crush batao! ❤️', 'Dare: Room mein ek gaana gaao! 🎤', 'Truth: Sabse best friend kaun hai?', 'Dare: Host ko ek Rose bhejo! 🌹'];
          setState(() => _msgs.add('🎭 ${widget.userName} -> ${tasks[Random().nextInt(tasks.length)]}'));
        },
      ),
      ListTile(
        leading: const Text('🎰', style: TextStyle(fontSize: 24)),
        title: const Text('Lucky Jackpot Wheel (20 🪙)', style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(ctx);
          if (_coins < 20) return;
          final win = [0, 10, 30, 50, 100][Random().nextInt(5)];
          setState(() {
            _coins = _coins - 20 + win;
            _msgs.add('🎰 ${widget.userName} won +$win 🪙 in Lucky Wheel!');
          });
          widget.onCoins(_coins);
          if (win >= 50) _showBanner('🎉 JACKPOT! ${widget.userName} won +$win 🪙!');
        },
      ),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141422),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        foregroundColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.circle, size: 10, color: _joined ? Colors.greenAccent : Colors.amber),
            const SizedBox(width: 6),
            Expanded(child: Text(widget.roomTitle, style: const TextStyle(fontSize: 14))),
          ]),
          Text('🏆 Top: $_topGifter ($_topGiftCoins 🪙)', style: const TextStyle(color: Colors.amber, fontSize: 11)),
        ]),
        actions: [
          IconButton(onPressed: _setRoomLock, icon: Icon(_roomPin.isEmpty ? Icons.lock_open : Icons.lock, color: _roomPin.isEmpty ? Colors.white70 : Colors.amber, size: 20)),
          Center(child: Padding(padding: const EdgeInsets.only(right: 10), child: Text('🪙 $_coins', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)))),
        ],
      ),
      body: Column(children: [
        if (_bannerText != null)
          Container(width: double.infinity, color: Colors.deepOrange, padding: const EdgeInsets.all(8), child: Text(_bannerText!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.2),
          itemCount: 9,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _onSeatTap(i),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 22, backgroundColor: i == _mySeat ? Color(widget.userBg) : (_locked[i] ? Colors.red.withOpacity(0.25) : Colors.white12), child: Text(_seats[i].split(' ').first)),
              const SizedBox(height: 4),
              Text(i == 0 ? '👑 ${_seats[i]}' : _seats[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: i == 0 ? Colors.amber : Colors.white70, fontSize: 11)),
            ]),
          ),
        ),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _msgs.length, itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(_msgs[i], style: const TextStyle(color: Colors.white, fontSize: 13))))),
        Container(
          padding: const EdgeInsets.all(6),
          color: const Color(0xFF1E1E2C),
          child: Row(children: [
            IconButton(onPressed: _toggleMic, icon: Icon(_micOn ? Icons.mic : Icons.mic_off, color: _micOn ? Colors.greenAccent : Colors.red)),
            Expanded(child: TextField(controller: _msgCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Baat karein...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none))),
            IconButton(onPressed: _openGames, icon: const Text('🎮', style: TextStyle(fontSize: 22))),
            IconButton(onPressed: _openGifts, icon: const Text('🎁', style: TextStyle(fontSize: 22))),
            IconButton(onPressed: () { if (_msgCtrl.text.trim().isNotEmpty) { setState(() => _msgs.add('👑 ${widget.userName}: ${_msgCtrl.text.trim()}')); _msgCtrl.clear(); } }, icon: const Icon(Icons.send, color: Color(0xFFFF7A30))),
          ]),
        ),
      ]),
    );
  }
}
