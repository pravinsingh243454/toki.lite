import 'package:flutter/material.dart';
import 'room_screen.dart';

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
