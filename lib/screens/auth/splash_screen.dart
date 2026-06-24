import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.deepBlue, AppColors.blue, AppColors.sky]),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop_rounded, color: Colors.white, size: 78),
              SizedBox(height: 18),
              Text('AquaPulse', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
              SizedBox(height: 6),
              Text('Smart Water Metering System', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
