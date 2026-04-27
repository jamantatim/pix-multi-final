import 'package:flutter/material.dart';
import '../services/storage.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite um email')));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    await Storage().setLastLogin();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_clock, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text('Login Semanal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Free users: login uma vez por semana', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('ENTRAR'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _showPremiumInfo(),
                child: const Text('Quero remover esta obrigação → Seja Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Seja Premium'),
        content: const Text('Premium remove login semanal e desbloqueia:\n\n✅ Temas personalizados\n✅ Logo no QR Code\n✅ Multi-contas\n✅ Timeout configurável'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}
