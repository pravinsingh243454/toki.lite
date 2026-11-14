import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_tabs.dart';
import 'me_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TokiLiteApp());
}

class TokiLiteApp extends StatelessWidget {
  const TokiLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toki Lite',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4B39EF),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _phone, _name;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _phone = p.getString('phone');
      _name = p.getString('name');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_phone == null) {
      return LoginScreen(onLogin: (phone, name) async {
        final p = await SharedPreferences.getInstance();
        await p.setString('phone', phone);
        await p.setString('name', name);
        await FirebaseFirestore.instance.collection('users').doc(phone).set({
          'name': name,
          'coins': FieldValue.increment(0),
        }, SetOptions(merge: true));
        setState(() {
          _phone = phone;
          _name = name;
        });
      });
    }
    return MainShell(
      phone: _phone!,
      initialName: _name ?? 'Toki User',
      onLogout: () async {
        final p = await SharedPreferences.getInstance();
        await p.clear();
        setState(() {
          _phone = null;
          _name = null;
        });
      },
    );
  }
}
class LoginScreen extends StatefulWidget {
  final Function(String phone, String name) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('👑', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 8),
            const Text('Toki Lite', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4B39EF))),
            const SizedBox(height: 20),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Apna Naam', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, maxLength: 10, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF), foregroundColor: Colors.white),
                onPressed: () {
                  if (_phoneCtrl.text.trim().length < 10) return;
                  widget.onLogin(_phoneCtrl.text.trim(), _nameCtrl.text.trim().isEmpty ? 'Pravin' : _nameCtrl.text.trim());
                },
                child: const Text('Login / Start Party', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final String phone, initialName;
  final VoidCallback onLogout;
  const MainShell({super.key, required this.phone, required this.initialName, required this.onLogout});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0, _avatar = 0;
  String _lang = 'Hindi';
  final _emojis = ['😎', '👑', '🎧', '🔥', '🌸', '🦁'];
  final _bgs = [0xFFFFB74D, 0xFFF48FB1, 0xFF90CAF9, 0xFFFF8A65, 0xFFCE93D8, 0xFFA5D6A7];

  @override
  Widget build(BuildContext context) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.phone);
    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (context, snap) {
        final data = (snap.data?.data() as Map<String, dynamic>?) ?? {};
        final name = (data['name'] ?? widget.initialName).toString();
        final coins = (data['coins'] ?? 500) as int;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF4B39EF),
            foregroundColor: Colors.white,
            title: const Text('👑 Toki Lite', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              Center(child: Padding(padding: const EdgeInsets.only(right: 14), child: Text('🪙 $coins', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)))),
            ],
          ),
          body: _tab == 4
              ? TokiMeScreen(
                  userName: name,
                  phone: widget.phone,
                  lang: _lang,
                  coins: coins,
                  selectedAvatar: _avatar,
                  onNameChanged: (n) => userDoc.set({'name': n}, SetOptions(merge: true)),
                  onAvatarChanged: (i) => setState(() => _avatar = i),
                  onCoinsChanged: (c) => userDoc.set({'coins': c}, SetOptions(merge: true)),
                  onLangChanged: (l) => setState(() => _lang = l),
                  onLogout: widget.onLogout,
                )
              : TokiHomeTabs(
                  tabIndex: _tab,
                  userName: name,
                  userEmoji: _emojis[_avatar],
                  userBg: _bgs[_avatar],
                  coins: coins,
                  lang: _lang,
                  onCoins: (c) => userDoc.set({'coins': c}, SetOptions(merge: true)),
                ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _tab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF4B39EF),
            onTap: (i) => setState(() => _tab = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Moments'),
              BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Rooms'),
              BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Ranking'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
            ],
          ),
        );
      },
    );
  }
}
