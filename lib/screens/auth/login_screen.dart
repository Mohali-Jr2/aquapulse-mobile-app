import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

import '../home/main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController meterController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool loading = false;

  Future<void> loginUser() async {

    if (phoneController.text.trim().isEmpty ||
        meterController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all fields',
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
          await ApiService().mobileLogin(

        phoneNumber:
            phoneController.text.trim(),

        meterCode:
            meterController.text.trim(),

        password:
            passwordController.text.trim(),
      );

      setState(() {
        loading = false;
      });

      if (result['success']) {

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setString(
    'full_name',
    result['full_name'] ?? '',
  );

  await prefs.setString(
    'meter_code',
    result['meter_code'] ?? '',
  );

  await prefs.setString(
    'phone_number',
    phoneController.text.trim(),
  );

  if (!mounted) return;
  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder: (_) => const MainShell(),
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

  void showForgotPasswordDialog() {

    final emailController =
        TextEditingController();

    final codeController =
        TextEditingController();

    final passwordController =
        TextEditingController();

    bool codeSent = false;

    showDialog(

      context: context,

      builder: (context) {

        return StatefulBuilder(

          builder: (context, setStateDialog) {

            return AlertDialog(

              title: const Text(
                'Reset Password',
              ),

              content: SingleChildScrollView(

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    TextField(

                      controller: emailController,

                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (codeSent) ...[

                      TextField(

                        controller: codeController,

                        decoration: const InputDecoration(
                          labelText: 'Verification Code',
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(

                        controller: passwordController,

                        obscureText: true,

                        decoration: const InputDecoration(
                          labelText: 'New Password',
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              actions: [

                TextButton(

                  onPressed: () async {

                    if (!codeSent) {

                      final result =
                          await ApiService()
                              .sendResetCode(

                        email:
                            emailController.text.trim(),
                      );

                      if (result['success']) {

                        setStateDialog(() {
                          codeSent = true;
                        });

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          SnackBar(
                            content: Text(
                              result['message'],
                            ),
                          ),
                        );

                      } else {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          SnackBar(
                            content: Text(
                              result['error'],
                            ),
                          ),
                        );
                      }

                    } else {

                      final result =
                          await ApiService()
                              .resetPassword(

                        email:
                            emailController.text.trim(),

                        code:
                            codeController.text.trim(),

                        newPassword:
                            passwordController.text.trim(),
                      );

                      if (result['success']) {

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          SnackBar(
                            content: Text(
                              result['message'],
                            ),
                          ),
                        );

                      } else {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          SnackBar(
                            content: Text(
                              result['error'],
                            ),
                          ),
                        );
                      }
                    }
                  },

                  child: Text(
                    codeSent
                        ? 'Reset Password'
                        : 'Send Code',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
        title: const Text('Mobile Login'),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(22),

        child: Column(

          children: [

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
              label: 'Password',
              icon: Icons.lock,
              controller: passwordController,
              obscure: true,
            ),

            Align(

              alignment: Alignment.centerRight,

              child: TextButton(

                onPressed:
                    showForgotPasswordDialog,

                child: const Text(
                  'Forgot Password?',
                ),
              ),
            ),

            const SizedBox(height: 10),

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
                    loading ? null : loginUser,

                child: loading

                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )

                    : const Text(
                        'Login',
                      ),
              ),
            ),

            const SizedBox(height: 18),

            TextButton(

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const RegisterScreen(),
                  ),
                );
              },

              child: const Text(
                'Create Mobile Account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
