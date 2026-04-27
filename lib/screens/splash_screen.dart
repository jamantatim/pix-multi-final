import 'package:flutter/material.dart';
import 'dart:async';
import '../services/storage.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  const SplashScreen({super.key, this.onThemeChanged});
  
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    // Recarregar tema se mudou
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!();
    }
    
    final storage = Storage();
    final isPremium = await storage.isPremium;
    
    if (isPremium) {
      final exp = await storage.expiry;
      if (exp != null) {
        final expiry = DateTime.tryParse(exp);
        if (expiry != null && DateTime.now().isBefore(expiry)) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          return;
        }
      }
    }
    
    final lastLogin = await storage.getLastLogin();
    if (!storage.needsLogin(lastLogin)) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF00C853), const Color(0xFF2979FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code, size: 100, color: Colors.white),
              SizedBox(height: 24),
              Text('PIX Multi', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              Text('Gerador de QR Code Profissional', style: TextStyle(fontSize: 16, color: Colors.white70)),
              SizedBox(height: 32),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
