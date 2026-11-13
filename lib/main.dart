import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

void main() {
  runApp(const TokiLiteApp());
}

class TokiLiteApp extends StatelessWidget {
  const TokiLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'toki.lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4B39EF),
        scaffoldBackgroundColor: const Color(0xFF0E0B1F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4B39EF),
          secondary: Color(0xFFFF4081),
        ),
      ),
      home: const LobbyScreen(),
    );
  }
}

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _appIdController =
      TextEditingController(text: '7d9fb3e0517840d38e246fbb98315d22');
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _roomController =
      TextEditingController(text: 'toki_party_1');
  final TextEditingController _nameController =
      TextEditingController(text: 'Pravin');

  final List _hotRooms = const [
    {'name': 'toki_party_1', 'title': 'Masti & Singing Party Room', 'tag': 'LIVE'},
    {'name': 'toki_friends', 'title': 'Late Night Adda & Games', 'tag': 'HOT'},
    {'name': 'toki_vip', 'title': 'VIP Golden Mic Club', 'tag': 'VIP'},
  ];

  void _enterRoom([String? customRoom]) {
    final roomName = customRoom ?? _roomController.text.trim();
    if (_appIdController.text.trim().isEmpty || roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App ID aur Room Name zaroori hai!')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveRoomScreen(
          appId: _appIdController.text.trim(),
          token: _tokenController.text.trim(),
          channelName: roomName,
          userName: _nameController.text.trim().isEmpty
              ? 'User'
              : _nameController.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _tokenController.dispose();
    _roomController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('toki.lite • Voice Party'),
        backgroundColor: const Color(0xFF4B39EF),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4B39EF), Color(0xFF9B51E0)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(Icons.headset_mic, size: 46, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'toki.lite Live Voice Chat',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '9 Mic Seats • Real Live Voice • Gifts • Party Games',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Trending Party Rooms (Tap to Join)',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ..._hotRooms.map(
              (room) => Card(
                color: const Color(0xFF1A1533),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF4B39EF),
                    child: Icon(Icons.graphic_eq, color: Colors.white),
                  ),
                  title: Text(room['title'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: ${room['name']}'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(room['tag'].toString(),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => _enterRoom(room['name'].toString()),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Aapka Naam (Your Name)',
                prefixIcon: const Icon(Icons.person),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: 'Custom Room Name',
                prefixIcon: const Icon(Icons.meeting_room),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _appIdController,
              decoration: InputDecoration(
                labelText: 'Agora App ID',
                prefixIcon: const Icon(Icons.vpn_key),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Temp Token (Optional)',
                prefixIcon: const Icon(Icons.lock_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _enterRoom(),
              icon: const Icon(Icons.mic),
              label: const Text(
                'Create / Join Live Room',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B39EF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class LiveRoomScreen extends StatefulWidget {
  final String appId;
  final String token;
  final String channelName;
  final String userName;

  const LiveRoomScreen({
    super.key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.userName,
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  RtcEngine? _engine;
  int? _streamId;
  bool _isJoined = false;
  bool _isMuted = false;
  int _localUid = 0;
  int _coins = 5000;
  String? _bannerText;
  Timer? _bannerTimer;

  final List _seats = List.filled(9, null);
  final Set _speakingUids = {};
  final List _messages = [];
  final TextEditingController _chatController = TextEditingController();

  final List _truthDares = const [
    'Apna favourite gaana 2 line gaakar sunao!',
    'Apne best friend ka secret batao!',
    'Ek funny dialogue bolkar dikhao!',
    'Sabko ek pyara compliment do!',
  ];

  @override
  void initState() {
    super.initState();
    _setupAgora();
  }

  Future<void> _setupAgora() async {
    final engine = createAgoraRtcEngine();
    _engine = engine;
    await engine.initialize(RtcEngineContext(
      appId: widget.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    await engine.enableAudio();
    await engine.enableAudioVolumeIndication(
      interval: 250,
      smooth: 3,
      reportVad: true,
    );

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          if (!mounted) return;
          setState(() {
            _isJoined = true;
            _localUid = connection.localUid ?? 0;
            _messages.add({
              'sender': 'toki.lite',
              'text': 'Welcome to "${widget.channelName}"!'
            });
          });
          try {
            _streamId = await engine.createDataStream(
              const DataStreamConfig(syncWithAudio: false, ordered: true),
            );
          } catch (_) {}
          final emptyIdx = _seats.indexWhere((s) => s == null);
          if (emptyIdx != -1) _takeSeat(emptyIdx);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          if (!mounted) return;
          setState(() {
            _messages.add({
              'sender': 'toki.lite',
              'text': 'Friend (ID: $remoteUid) entered the party!'
            });
          });
          _broadcast({'type': 'sync_seats', 'seats': _seats});
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          if (!mounted) return;
          setState(() {
            for (int i = 0; i < 9; i++) {
              if (_seats[i] != null && _seats[i]['uid'] == remoteUid) {
                _seats[i] = null;
              }
            }
          });
        },
        onAudioVolumeIndication: (RtcConnection connection,
            List<AudioVolumeInfo> speakers,
            int speakerNumber,
            int totalVolume) {
          final Set active = {};
          for (final s in speakers) {
            if ((s.volume ?? 0) > 15) {
              active.add(s.uid == 0 ? _localUid : (s.uid ?? 0));
            }
          }
          if (mounted) {
            setState(() {
              _speakingUids
                ..clear()
                ..addAll(active);
            });
          }
        },
        onStreamMessage: (RtcConnection connection, int remoteUid, int streamId,
            Uint8List data, int length, int sentTs) {
          try {
            final map = jsonDecode(utf8.decode(data)) as Map;
            _onRemoteData(map);
          } catch (_) {}
        },
      ),
    );

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
      ),
    );
  }

  Future<void> _broadcast(Map data) async {
    if (_streamId == null || !_isJoined || _engine == null) return;
    try {
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(data)));
      await _engine!.sendStreamMessage(
        streamId: _streamId!,
        data: bytes,
        length: bytes.length,
      );
    } catch (_) {}
  }

  void _onRemoteData(Map data) {
    if (!mounted) return;
    setState(() {
      switch (data['type']) {
        case 'chat':
          _messages.add({
            'sender': (data['sender'] ?? 'User').toString(),
            'text': (data['text'] ?? '').toString(),
          });
          break;
        case 'seat':
          final idx = data['index'] as int;
          _seats[idx] = data['user'] == null ? null : Map.from(data['user']);
          break;
        case 'sync_seats':
          final list = data['seats'] as List;
          for (int i = 0; i < 9 && i < list.length; i++) {
            if (list[i] != null && _seats[i] == null) {
              _seats[i] = Map.from(list[i]);
            }
          }
          break;
        case 'gift':
          final msg = '${data['sender']} sent ${data['gift']}!';
          _messages.add({'sender': 'Gift', 'text': msg});
          _showBanner(msg);
          break;
        case 'game':
          final msg = '${data['sender']}: ${data['result']}';
          _messages.add({'sender': 'Party Game', 'text': msg});
          _showBanner(msg);
          break;
      }
    });
  }

  void _showBanner(String text) {
    _bannerTimer?.cancel();
    setState(() => _bannerText = text);
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _bannerText = null);
    });
  }

  void _takeSeat(int index) {
    for (int i = 0; i < 9; i++) {
      if (_seats[i] != null && _seats[i]['uid'] == _localUid) {
        _seats[i] = null;
        _broadcast({'type': 'seat', 'index': i, 'user': null});
      }
    }
    final userObj = {'uid': _localUid, 'name': widget.userName};
    setState(() => _seats[index] = userObj);
    _broadcast({'type': 'seat', 'index': index, 'user': userObj});
  }

  void _leaveSeat(int index) {
    setState(() => _seats[index] = null);
    _broadcast({'type': 'seat', 'index': index, 'user': null});
  }

  void _sendChat() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();
    setState(() => _messages.add({'sender': widget.userName, 'text': text}));
    _broadcast({'type': 'chat', 'sender': widget.userName, 'text': text});
  }

  void _sendGift(String gift, int cost) {
    if (_coins < cost) return;
    setState(() {
      _coins -= cost;
      _messages.add({
        'sender': 'Gift',
        'text': '${widget.userName} sent $gift!',
      });
    });
    _showBanner('${widget.userName} sent $gift!');
    _broadcast({'type': 'gift', 'sender': widget.userName, 'gift': gift});
    Navigator.pop(context);
  }

  void _playDice() {
    final dice = Random().nextInt(6) + 1;
    final result = 'Ludo Dice: $dice';
    setState(() {
      _messages.add({
        'sender': 'Party Game',
        'text': '${widget.userName}: $result',
      });
    });
    _showBanner('${widget.userName}: $result');
    _broadcast({'type': 'game', 'sender': widget.userName, 'result': result});
  }

  void _playTruthDare() {
    final task = _truthDares[Random().nextInt(_truthDares.length)];
    final result = 'Dare: $task';
    setState(() {
      _messages.add({
        'sender': 'Party Game',
        'text': '${widget.userName} -> $result',
      });
    });
    _showBanner('${widget.userName}: $result');
    _broadcast({'type': 'game', 'sender': widget.userName, 'result': result});
  }

  void _openGifts() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1533),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Toki Gifts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Coins: $_coins',
                    style: const TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _giftButton('Rose', 10),
                _giftButton('Crown', 100),
                _giftButton('Car', 500),
                _giftButton('Rocket', 1000),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _giftButton(String label, int cost) {
    return GestureDetector(
      onTap: () => _sendGift(label, cost),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF28204D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF4B39EF)),
        ),
        child: Column(
          children: [
            const Icon(Icons.card_giftcard, color: Colors.pinkAccent, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
            Text('$cost',
                style: const TextStyle(fontSize: 11, color: Colors.amber)),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _engine?.muteLocalAudioStream(_isMuted);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _chatController.dispose();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B39EF),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.channelName, style: const TextStyle(fontSize: 16)),
            Text(
              _isJoined ? 'Live Voice Connected' : 'Connecting...',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _playDice,
            icon: const Icon(Icons.casino),
            tooltip: 'Ludo Dice',
          ),
          IconButton(
            onPressed: _playTruthDare,
            icon: const Icon(Icons.celebration),
            tooltip: 'Truth & Dare',
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('$_coins',
                  style: const TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_bannerText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF4081), Color(0xFF4B39EF)],
                ),
              ),
              child: Text(
                _bannerText!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.05,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final occupant = _seats[index];
                final isOccupied = occupant != null;
                final uid = isOccupied ? occupant['uid'] : null;
                final isSpeaking = uid != null && _speakingUids.contains(uid);
                final isMe = uid == _localUid;
                final isHostSeat = index == 0;

                return GestureDetector(
                  onTap: () {
                    if (!isOccupied) {
                      _takeSeat(index);
                    } else if (isMe) {
                      _leaveSeat(index);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1533),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSpeaking
                            ? Colors.greenAccent
                            : (isHostSeat
                                ? Colors.amber
                                : (isOccupied
                                    ? const Color(0xFF4B39EF)
                                    : Colors.white12)),
                        width: isSpeaking ? 2.5 : 1.3,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isHostSeat
                              ? Colors.amber.shade700
                              : (isOccupied
                                  ? const Color(0xFF4B39EF)
                                  : Colors.white10),
                          child: Icon(
                            isHostSeat
                                ? Icons.star
                                : (isOccupied ? Icons.person : Icons.mic_none),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isOccupied
                              ? occupant['name'].toString()
                              : (isHostSeat ? 'Host Seat' : 'Seat ${index + 1}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOccupied
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isOccupied ? Colors.white : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1533),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${msg['sender']}: ',
                            style: const TextStyle(
                              color: Color(0xFF9D8DF1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: msg['text'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF15112B),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Say something in party...',
                      filled: true,
                      fillColor: const Color(0xFF231D42),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendChat(),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: _sendChat,
                  icon: const Icon(Icons.send, color: Color(0xFF4B39EF)),
                ),
                IconButton(
                  onPressed: _toggleMute,
                  icon: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.redAccent : Colors.greenAccent,
                  ),
                ),
                IconButton(
                  onPressed: _openGifts,
                  icon: const Icon(Icons.card_giftcard,
                      color: Colors.pinkAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
