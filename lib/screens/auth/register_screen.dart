import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController meterController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool loading = false;

  Future<void> registerUser() async {

    if (phoneController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        meterController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all fields',
          ),
        ),
      );

      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match',
          ),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {

      final result =
          await ApiService().mobileRegister(

        phoneNumber:
            phoneController.text.trim(),

        meterCode:
            meterController.text.trim(),

        email:
            emailController.text.trim(),

        password:
            passwordController.text.trim(),
      );

      setState(() {
        loading = false;
      });

      if (result['success']) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'],
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'],
            ),
          ),
        );
      }

    } catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connection error: $e',
          ),
        ),
      );
    }
  }

  Widget field({

    required String label,
    required IconData icon,
    required TextEditingController controller,

    bool obscure = false,

    TextInputType keyboardType =
        TextInputType.text,

  }) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 14),

      child: TextField(

        controller: controller,

        obscureText: obscure,

        keyboardType: keyboardType,

        decoration: InputDecoration(

          labelText: label,

          prefixIcon: Icon(icon),

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Create Mobile Account',
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(22),

        child: Column(

          children: [

            const Text(

              'Register using the phone number and meter number already registered by the regulator.',

              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            field(
              label: 'Phone Number',
              icon: Icons.phone,
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),

            field(
              label: 'Meter Number',
              icon: Icons.speed,
              controller: meterController,
            ),

            field(
              label: 'Email Address',
              icon: Icons.email,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            field(
              label: 'Password',
              icon: Icons.lock,
              controller: passwordController,
              obscure: true,
            ),

            field(
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              controller:
                  confirmPasswordController,
              obscure: true,
            ),

            const SizedBox(height: 16),

            SizedBox(

              width: double.infinity,
              height: 56,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                      AppColors.blue,

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),

                onPressed:
                    loading ? null : registerUser,

                child: loading

                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )

                    : const Text(
                        'Register',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}