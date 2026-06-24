import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(colors: [AppColors.deepBlue, AppColors.blue, AppColors.sky]),
                ),
                child: const Center(
                  child: Icon(Icons.sensors_rounded, color: Colors.white, size: 100),
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'Control your water from anywhere',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, color: AppColors.dark),
              ),
              const SizedBox(height: 12),
              const Text(
                'Monitor usage, detect leakage, pay bills and control your smart valve in real time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
