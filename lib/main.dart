import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'services/storage.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PixMultiApp());
}

class PixMultiApp extends StatefulWidget {
  const PixMultiApp({super.key});

  @override State<PixMultiApp> createState() => _PixMultiAppState();
}

class _PixMultiAppState extends State<PixMultiApp> {
  int _themeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final index = await Storage().selectedTheme;
    if (mounted) {
      setState(() => _themeIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aplicar tema selecionado
    final theme = AppConfig.themes[_themeIndex % AppConfig.themes.length];
    final primaryColor = theme['primary'] as Color;
    final accentColor = theme['accent'] as Color;

    return MaterialApp(
      title: 'PIX Multi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: SplashScreen(onThemeChanged: _loadTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}
