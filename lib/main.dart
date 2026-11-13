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

  int _selectedAvatar = 0;

  final List _avatars = const [
    {'emoji': '😎', 'bg': 0xFF4B39EF},
    {'emoji': '👑', 'bg': 0xFFD97706},
    {'emoji': '🦊', 'bg': 0xFFEA580C},
    {'emoji': '🎧', 'bg': 0xFF7C3AED},
    {'emoji': '🦋', 'bg': 0xFFDB2777},
    {'emoji': '🦁', 'bg': 0xFFCA8A04},
    {'emoji': '🚀', 'bg': 0xFF0284C7},
    {'emoji': '💖', 'bg': 0xFFE11D48},
  ];

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
          avatarIndex: _selectedAvatar,
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
        title: const Text('toki.lite • VIP Voice Party'),
        backgroundColor: const Color(0xFF4B39EF),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4B39EF), Color(0xFF9B51E0)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(Icons.headset_mic, size: 42, color: Colors.white),
                  SizedBox(height: 6),
                  Text(
                    'toki.lite Live Voice Chat',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Avatars • Themes • Emojis • Gifts • Sound Board',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Apna Profile Avatar Chunein:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 58,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _avatars.length,
                itemBuilder: (context, idx) {
                  final item = _avatars[idx];
                  final isSel = _selectedAvatar == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = idx),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSel ? Colors.amber : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: Color(item['bg'] as int),
                        child: Text(item['emoji'].toString(),
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 12),
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
                'Enter VIP Live Room',
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
  final int avatarIndex;

  const LiveRoomScreen({
    super.key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.userName,
    required this.avatarIndex,
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
  int _themeIndex = 0;
  String? _bannerText;
  Timer? _bannerTimer;

  final List _seats = List.filled(9, null);
  final Map _seatEmojis = {};
  final Set _speakingUids = {};
  final List _messages = [];
  final TextEditingController _chatController = TextEditingController();

  final List _avatars = const [
    {'emoji': '😎', 'bg': 0xFF4B39EF},
    {'emoji': '👑', 'bg': 0xFFD97706},
    {'emoji': '🦊', 'bg': 0xFFEA580C},
    {'emoji': '🎧', 'bg': 0xFF7C3AED},
    {'emoji': '🦋', 'bg': 0xFFDB2777},
    {'emoji': '🦁', 'bg': 0xFFCA8A04},
    {'emoji': '🚀', 'bg': 0xFF0284C7},
    {'emoji': '💖', 'bg': 0xFFE11D48},
  ];

  final List _themes = const [
    {'name': 'Neon Party', 'c1': 0xFF0E0B1F, 'c2': 0xFF281859},
    {'name': 'Royal Gold', 'c1': 0xFF1C1408, 'c2': 0xFF4A3208},
    {'name': 'Galaxy Night', 'c1': 0xFF071526, 'c2': 0xFF163A5F},
    {'name': 'Love Lounge', 'c1': 0xFF240B1C, 'c2': 0xFF57163E},
  ];

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
              'sender': 'VIP Entry',
              'text': '👑 ${widget.userName} entered "${widget.channelName}"!'
            });
          });
          _showBanner('👑 ${widget.userName} entered the VIP Party!');
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
              'text': '✨ Friend (ID: $remoteUid) joined the party!'
            });
          });
          _broadcast({
            'type': 'sync_state',
            'seats': _seats,
            'theme': _themeIndex,
          });
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
        case 'sync_state':
          final list = data['seats'] as List;
          for (int i = 0; i < 9 && i < list.length; i++) {
            if (list[i] != null && _seats[i] == null) {
              _seats[i] = Map.from(list[i]);
            }
          }
          if (data['theme'] != null) {
            _themeIndex = (data['theme'] as int) % _themes.length;
          }
          break;
        case 'theme':
          _themeIndex = (data['index'] as int) % _themes.length;
          _showBanner('🎨 Theme changed to ${_themes[_themeIndex]['name']}!');
          break;
        case 'emoji':
          final sIdx = data['seat'] as int;
          final emo = data['emoji'].toString();
          _triggerSeatEmoji(sIdx, emo);
          break;
        case 'gift':
          final msg = '🎁 ${data['sender']} sent ${data['gift']}!';
          _messages.add({'sender': 'Gift', 'text': msg});
          _showBanner(msg);
          break;
        case 'game':
          final msg = '${data['sender']}: ${data['result']}';
          _messages.add({'sender': 'Party', 'text': msg});
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

  void _triggerSeatEmoji(int seatIdx, String emoji) {
    setState(() => _seatEmojis[seatIdx] = emoji);
    Timer(const Duration(seconds: 3), () {
      if (mounted && _seatEmojis[seatIdx] == emoji) {
        setState(() => _seatEmojis.remove(seatIdx));
      }
    });
  }

  void _sendReaction(String emoji) {
    int mySeat = -1;
    for (int i = 0; i < 9; i++) {
      if (_seats[i] != null && _seats[i]['uid'] == _localUid) {
        mySeat = i;
        break;
      }
    }
    if (mySeat == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pehle kisi Mic Seat par baithein!')),
      );
      return;
    }
    _triggerSeatEmoji(mySeat, emoji);
    _broadcast({'type': 'emoji', 'seat': mySeat, 'emoji': emoji});
  }

  void _playSoundEffect(String label) {
    final msg = '🔊 ${widget.userName} played $label';
    setState(() => _messages.add({'sender': 'Sound', 'text': msg}));
    _showBanner(msg);
    _broadcast({'type': 'game', 'sender': widget.userName, 'result': label});
  }

  void _changeTheme() {
    setState(() {
      _themeIndex = (_themeIndex + 1) % _themes.length;
    });
    _showBanner('🎨 Room Theme: ${_themes[_themeIndex]['name']}');
    _broadcast({'type': 'theme', 'index': _themeIndex});
  }

  void _takeSeat(int index) {
    for (int i = 0; i < 9; i++) {
      if (_seats[i] != null && _seats[i]['uid'] == _localUid) {
        _seats[i] = null;
        _broadcast({'type': 'seat', 'index': i, 'user': null});
      }
    }
    final userObj = {
      'uid': _localUid,
      'name': widget.userName,
      'avatar': widget.avatarIndex,
    };
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
        'text': '🎁 ${widget.userName} sent $gift!',
      });
    });
    _showBanner('🎁 ${widget.userName} sent $gift!');
    _broadcast({'type': 'gift', 'sender': widget.userName, 'gift': gift});
    Navigator.pop(context);
  }

  void _playDice() {
    final dice = Random().nextInt(6) + 1;
    final result = '🎲 Ludo Dice: $dice';
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
    final result = '🎯 Dare: $task';
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
                const Text('Toki VIP Gifts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('🪙 $_coins',
                    style: const TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _giftButton('🌹 Rose', 10),
                _giftButton('👑 Crown', 100),
                _giftButton('🏎️ Car', 500),
                _giftButton('🚀 Rocket', 1000),
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
            const Icon(Icons.card_giftcard, color: Colors.pinkAccent, size: 26),
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
    final currentTheme = _themes[_themeIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B39EF),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.channelName, style: const TextStyle(fontSize: 15)),
            Text(
              _isJoined
                  ? '${currentTheme['name']} • Live'
                  : 'Connecting...',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _changeTheme,
            icon: const Icon(Icons.palette),
            tooltip: 'Change Room Theme',
          ),
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
              padding: const EdgeInsets.only(right: 10),
              child: Text('🪙$_coins',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(currentTheme['c1'] as int),
              Color(currentTheme['c2'] as int),
            ],
          ),
        ),
        child: Column(
          children: [
            if (_bannerText != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF4081), Color(0xFF4B39EF)],
                  ),
                ),
                child: Text(
                  _bannerText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.08,
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
                  final avIdx = isOccupied
                      ? ((occupant['avatar'] ?? 0) as int) % _avatars.length
                      : 0;
                  final avData = _avatars[avIdx];
                  final activeEmoji = _seatEmojis[index];

                  return GestureDetector(
                    onTap: () {
                      if (!isOccupied) {
                        _takeSeat(index);
                      } else if (isMe) {
                        _leaveSeat(index);
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSpeaking
                                  ? Colors.greenAccent
                                  : (isHostSeat
                                      ? Colors.amber
                                      : (isOccupied
                                          ? const Color(0xFF4B39EF)
                                          : Colors.white12)),
                              width: isSpeaking ? 2.8 : 1.4,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: isOccupied
                                    ? Color(avData['bg'] as int)
                                    : (isHostSeat
                                        ? Colors.amber.shade800
                                        : Colors.white10),
                                child: isOccupied
                                    ? Text(avData['emoji'].toString(),
                                        style: const TextStyle(fontSize: 22))
                                    : Icon(
                                        isHostSeat
                                            ? Icons.star
                                            : Icons.mic_none,
                                        color: Colors.white70,
                                      ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isOccupied
                                    ? occupant['name'].toString()
                                    : (isHostSeat
                                        ? '👑 Host'
                                        : 'Seat ${index + 1}'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isOccupied
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isOccupied
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (activeEmoji != null)
       
