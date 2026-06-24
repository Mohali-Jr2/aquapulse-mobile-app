import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  runApp(const AquaPulseApp());
}

class AquaPulseApp extends StatelessWidget {
  const AquaPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
