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
  int _mySeat = 0;
  String? _bannerText;
  final _msgCtrl = TextEditingController();
  final List _msgs = ['👑 Welcome to Toki Party Room!'];
  final List _seats = List.generate(9, (i) => i == 1 ? '🌸 Riya' : '🎙️ Seat ${i + 1}');

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
        if (mounted) setState(() { _joined = true; _msgs.add('✅ Live Voice Connected!'); });
      },
      onUserJoined: (c, uid, e) {
        if (mounted) setState(() => _msgs.add('✨ User $uid joined'));
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

  void _sendGift(String name, int cost) {
    if (_coins < cost) return;
    setState(() { _coins -= cost; _msgs.add('🎁 ${widget.userName} sent $name (-$cost 🪙)'); });
    widget.onCoins(_coins);
    if (cost >= 50) _showBanner('🔥 ${widget.userName} ne $name bheja! 🔥');
  }

  void _openGifts() {
    final list = [{'n': '🌹 Rose', 'c': 10}, {'n': '💍 Ring', 'c': 50}, {'n': '🏎️ Car', 'c': 200}, {'n': '👑 Crown', 'c': 500}];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      builder: (ctx) => Wrap(
        children: list.map((g) => ListTile(
          title: Text('${g['n']} (${g['c']} 🪙)', style: const TextStyle(color: Colors.white)),
          onTap: () { Navigator.pop(ctx); _sendGift(g['n'].toString(), g['c'] as int); },
        )).toList(),
      ),
    );
  }

  void _openSpin() {
    if (_coins < 20) return;
    final win = [0, 10, 30, 50, 100][Random().nextInt(5)];
    setState(() {
      _coins = _coins - 20 + win;
      _msgs.add('🎰 ${widget.userName} spun Lucky Wheel & won +$win 🪙!');
    });
    widget.onCoins(_coins);
    if (win >= 50) _showBanner('🎉 JACKPOT! ${widget.userName} won +$win 🪙!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141422),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        foregroundColor: Colors.white,
        title: Row(children: [
          Icon(Icons.circle, size: 10, color: _joined ? Colors.greenAccent : Colors.amber),
          const SizedBox(width: 6),
          Expanded(child: Text(widget.roomTitle, style: const TextStyle(fontSize: 15))),
        ]),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 12), child: Text('🪙 $_coins', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))))],
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
            onTap: () => setState(() {
              if (_mySeat != -1) _seats[_mySeat] = '🎙️ Seat ${_mySeat + 1}';
              _mySeat = i;
              _seats[i] = '${widget.userEmoji} ${widget.userName}';
            }),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 22, backgroundColor: i == _mySeat ? Color(widget.userBg) : Colors.white12, child: Text(_seats[i].toString().split(' ').first)),
              const SizedBox(height: 4),
              Text(i == 0 ? '👑 ${_seats[i]}' : _seats[i].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: i == 0 ? Colors.amber : Colors.white70, fontSize: 11)),
            ]),
          ),
        ),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _msgs.length, itemBuilder: (_, i) => Text(_msgs[i].toString(), style: const TextStyle(color: Colors.white, fontSize: 13)))),
        Container(
          padding: const EdgeInsets.all(6),
          color: const Color(0xFF1E1E2C),
          child: Row(children: [
            IconButton(onPressed: _toggleMic, icon: Icon(_micOn ? Icons.mic : Icons.mic_off, color: _micOn ? Colors.greenAccent : Colors.red)),
            Expanded(child: TextField(controller: _msgCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Baat karein...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none))),
            IconButton(onPressed: _openSpin, icon: const Text('🎰', style: TextStyle(fontSize: 20))),
            IconButton(onPressed: _openGifts, icon: const Text('🎁', style: TextStyle(fontSize: 20))),
            IconButton(onPressed: () { if (_msgCtrl.text.trim().isNotEmpty) { setState(() => _msgs.add('👑 ${widget.userName}: ${_msgCtrl.text.trim()}')); _msgCtrl.clear(); } }, icon: const Icon(Icons.send, color: Color(0xFFFF7A30))),
          ]),
        ),
      ]),
    );
  }
}
