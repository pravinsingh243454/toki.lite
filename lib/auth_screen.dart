import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  final Function(String name, String phone, String lang) onLoginSuccess;

  const AuthScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = false;
  String _lang = 'Hindi';
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _submit() {
    final name = _nameCtrl.text.trim().isEmpty ? 'Pravin' : _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_lang == 'Hindi'
              ? 'कृपया 10 अंकों का सही मोबाइल नंबर डालें'
              : 'Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }
    widget.onLoginSuccess(name, phone, _lang);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = _lang == 'Hindi';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF7A30), Color(0xFF4B39EF)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ChoiceChip(
                    label: const Text('हिंदी'),
                    selected: isHindi,
                    selectedColor: Colors.amber,
                    onSelected: (_) => setState(() => _lang = 'Hindi'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('English'),
                    selected: !isHindi,
                    selectedColor: Colors.amber,
                    onSelected: (_) => setState(() => _lang = 'English'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Text('🎙️', style: TextStyle(fontSize: 42)),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'toki.lite',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  isHindi
                      ? 'लाइव वॉयस पार्टी, गेम्स और नए दोस्त'
                      : 'Live Voice Party, Games & New Friends',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isLogin
                                    ? const Color(0xFFFF7A30)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                isHindi ? 'नया अकाउंट (Sign Up)' : 'Sign Up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !_isLogin ? Colors.white : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isLogin
                                    ? const Color(0xFFFF7A30)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                isHindi ? 'लॉगिन (Login)' : 'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isLogin ? Colors.white : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isLogin) ...[
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: isHindi ? 'आपका नाम' : 'Your Name',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_android),
                        labelText: isHindi ? 'मोबाइल नंबर' : 'Mobile Number',
                        counterText: '',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: isHindi ? 'पासवर्ड' : 'Password',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B39EF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _isLogin
                              ? (isHindi ? 'लॉगिन करें ➔' : 'Login Now ➔')
                              : (isHindi
                                  ? 'अकाउंट बनाएँ (+500 फ्री कॉइन) ➔'
                                  : 'Create Account (+500 Free Coins) ➔'),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
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
