import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_tabs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch (_) {}
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: AuthGate()));
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _name;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _name = p.getString('user_name') ?? 'Pravin');
  }
  @override
  Widget build(BuildContext context) => _name == null ? const Scaffold() : MainShell(userName: _name!);
}

class MainShell extends StatefulWidget {
  final String userName;
  const MainShell({super.key, required this.userName});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0, _coins = 200;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final p = await SharedPreferences.getInstance(); setState(() => _coins = p.getInt('coins') ?? 200); }
  Future<void> _setCoins(int c) async { final p = await SharedPreferences.getInstance(); await p.setInt('coins', c); setState(() => _coins = c); }

  Widget _gradStar(bool active) => active
      ? ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFFF5252)]).createShader(b),
          child: const Icon(Icons.star_outline_rounded, size: 28, color: Colors.white),
        )
      : const Icon(Icons.star_outline_rounded, size: 26, color: Color(0xFF7A7A85));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121218),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181E),
        foregroundColor: Colors.white,
        title: const Text('👑 Toki Lite', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [Padding(padding: const EdgeInsets.only(right: 12), child: Center(child: Text('🪙 $_coins', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))))],
      ),
      body: TokiHomeTabs(tabIndex: _idx, userName: widget.userName, userEmoji: '😎', userBg: 0xFF4B39EF, coins: _coins, lang: 'HI', onCoins: _setCoins),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF18181E),
        selectedItemColor: const Color(0xFFFF8A3D),
        unselectedItemColor: const Color(0xFF7A7A85),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(icon: _gradStar(false), activeIcon: _gradStar(true), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.language_outlined, size: 26), label: 'Moments'),
          const BottomNavigationBarItem(icon: Icon(Icons.graphic_eq_rounded, size: 26), label: 'Rooms'),
          BottomNavigationBarItem(
            icon: Stack(clipBehavior: Clip.none, children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 25),
              Positioned(right: -8, top: -4, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(10)), child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ]),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded, size: 27), label: 'Me'),
        ],
      ),
    );
  }
}
