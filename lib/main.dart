import 'dart:math';
import 'package:flutter/material.dart';

class PartyRoomScreen extends StatefulWidget {
  final String roomId;
  final String userName;
  final String userEmoji;
  final int userBg;

  const PartyRoomScreen({
    super.key,
    required this.roomId,
    required this.userName,
    required this.userEmoji,
    required this.userBg,
  });

  @override
  State<PartyRoomScreen> createState() => _PartyRoomScreenState();
}

class _PartyRoomScreenState extends State<PartyRoomScreen> {
  int _mySeat = 0;
  bool _muted = false;
  bool _locked = false;
  int _themeIdx = 0;
  int _coins = 500;
  int _dice = 1;
  int _p1 = 0;
  int _p2 = 0;
  final TextEditingController _chatCtrl = TextEditingController();

  final List _themes = const [
    [0xFF1E1B4B, 0xFF4B39EF],
    [0xFF3B0764, 0xFFDB2777],
    [0xFF064E3B, 0xFF0D9488],
  ];

  final List _seats = [
    {'name': 'Riya (Host)', 'emoji': '🌸', 'bg': 0xFFF48FB1, 'taken': true},
    {'name': 'Seat 2', 'emoji': '🎙️', 'bg': 0xFF334155, 'taken': false},
    {'name': 'Aarav', 'emoji': '🎧', 'bg': 0xFF90CAF9, 'taken': true},
    {'name': 'Seat 4', 'emoji': '🎙️', 'bg': 0xFF334155, 'taken': false},
    {'name': 'Seat 5', 'emoji': '🎙️', 'bg': 0xFF334155, 'taken': false},
    {'name': 'Ananya', 'emoji': '👑', 'bg': 0xFFCE93D8, 'taken': true},
    {'name': 'Seat 7', 'emoji': '🎙️', 'bg': 0xFF334155, 'taken': false},
    {'name': 'Seat 8', 'emoji': '🎙️', 'bg': 0xFF334155, 'taken': false},
    {'name': 'Seat 9', 'emoji': '🎙️', 'bg': 0xFF334155, 'taken': false},
  ];

  final List _roomMsgs = [
    '🎉 Welcome to Toki Live Voice Party!',
    '🌸 Riya (Host): Sabhi doston ka swagat hai!',
  ];

  void _tapSeat(int idx) {
    if (_locked && _mySeat != idx) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔒 Room abhi lock hai')),
      );
      return;
    }
    setState(() {
      if (_mySeat == idx) {
        _seats[idx] = {
          'name': 'Seat ${idx + 1}',
          'emoji': '🎙️',
          'bg': 0xFF334155,
          'taken': false,
        };
        _mySeat = -1;
      } else if (_seats[idx]['taken'] == false) {
        if (_mySeat >= 0) {
          _seats[_mySeat] = {
            'name': 'Seat ${_mySeat + 1}',
            'emoji': '🎙️',
            'bg': 0xFF334155,
            'taken': false,
          };
        }
        _seats[idx] = {
          'name': widget.userName,
          'emoji': widget.userEmoji,
          'bg': widget.userBg,
          'taken': true,
        };
        _mySeat = idx;
      }
    });
  }

  void _rollLudo() {
    final r = Random().nextInt(6) + 1;
    final bot = Random().nextInt(6) + 1;
    setState(() {
      _dice = r;
      _p1 = (_p1 + r).clamp(0, 30);
      _p2 = (_p2 + bot).clamp(0, 30);
      _roomMsgs.add('🎲 ${widget.userName} rolled $r (Pos: $_p1/30)');
      if (_p1 >= 30) {
        _coins += 100;
        _roomMsgs.add('🏆 ${widget.userName} won Ludo Race! +100 Coins');
        _p1 = 0;
        _p2 = 0;
      }
    });
  }

  void _sendGift(String gift, int cost) {
    if (_coins < cost) return;
    setState(() {
      _coins -= cost;
      _roomMsgs.add('🎁 ${widget.userName} ne $gift bheja! (-$cost 🪙)');
    });
  }

  void _sendChat() {
    final t = _chatCtrl.text.trim();
    if (t.isEmpty) return;
    _chatCtrl.clear();
    setState(() {
      _roomMsgs.add('${widget.userName}: $t');
    });
  }

  @override
  void dispose() {
    _chatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _themes[_themeIdx] as List;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(colors[0] as int), Color(colors[1] as int)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text('🎙️ ${widget.roomId}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('🪙 $_coins',
                          style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => setState(
                          () => _themeIdx = (_themeIdx + 1) % _themes.length),
                      icon: const Icon(Icons.palette, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _locked = !_locked),
                      icon: Icon(_locked ? Icons.lock : Icons.lock_open,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _seats.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (_, idx) {
                    final s = _seats[idx];
                    final isMe = _mySeat == idx;
                    return GestureDetector(
                      onTap: () => _tapSeat(idx),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(14),
                          border: isMe
                              ? Border.all(color: Colors.amber, width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(s['bg'] as int),
                              child: Text(s['emoji'].toString(),
                                  style: const TextStyle(fontSize: 20)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s['name'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🎲 Toki Ludo Race (30 Steps)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('You: $_p1/30   •   Riya: $_p2/30',
                              style: const TextStyle(
                                  color: Colors.amberAccent, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _rollLudo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A30),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Roll ($_dice)'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _roomMsgs.length,
                  itemBuilder: (_, idx) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_roomMsgs[idx].toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _muted = !_muted),
                      icon: Icon(_muted ? Icons.mic_off : Icons.mic,
                          color: _muted ? Colors.redAccent : Colors.greenAccent),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _chatCtrl,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _sendChat(),
                        decoration: InputDecoration(
                          hintText: 'Say something...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _sendChat,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () => _sendGift('🌹 Rose', 20),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('🌹', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _sendGift('👑 Crown', 100),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('👑', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
