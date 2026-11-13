import 'package:flutter/material.dart';

class PrivateChatScreen extends StatefulWidget {
  final String peerName;
  final String peerEmoji;
  final VoidCallback onJoinVoiceRoom;

  const PrivateChatScreen({
    super.key,
    required this.peerName,
    required this.peerEmoji,
    required this.onJoinVoiceRoom,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final List _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'me': false,
      'text': 'Hi! Kaise ho? Aao voice party room mein baat karte hain 😊',
    });
  }

  void _send() {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;
    _msgCtrl.clear();
    setState(() {
      _messages.add({'me': true, 'text': txt});
      _messages.add({
        'me': false,
        'text': 'Bilkul! Upar "Voice Room" button dabao, main wahin hoon 🎙️✨',
      });
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        title: Row(
          children: [
            Text(widget.peerEmoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.peerName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: widget.onJoinVoiceRoom,
            icon: const Icon(Icons.mic, color: Color(0xFFFF7A30), size: 18),
            label: const Text('Voice Room',
                style: TextStyle(
                    color: Color(0xFFFF7A30), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length,
              itemBuilder: (_, idx) {
                final m = _messages[idx];
                final isMe = m['me'] == true;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFFF7A30) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      m['text'].toString(),
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: const TextStyle(color: Colors.black87),
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Message likhein...',
                      filled: true,
                      fillColor: const Color(0xFFF6F6F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF7A30),
                  child: IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
