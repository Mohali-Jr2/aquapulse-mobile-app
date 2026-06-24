import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../models/meter_model.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  String fullName = '';
  String meterCode = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {

    final prefs =
        await SharedPreferences.getInstance();

    setState(() {

      fullName =
          prefs.getString('full_name') ?? '';

      meterCode =
          prefs.getString('meter_code') ?? '';
    });
  }

  Future<void> showMeterInfo() async {
    final selectedMeter = meterCode.isEmpty
        ? 'MTR-0001'
        : meterCode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final meter = await ApiService().fetchLatestMeter(
        meterCode: selectedMeter,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      showMeterInfoSheet(meter);
    } catch (error) {
      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load meter information: $error',
          ),
        ),
      );
    }
  }

  void showMeterInfoSheet(MeterModel meter) {
    final valveStatus =
        meter.valveOpen ? 'Open' : 'Closed';
    final waterSupply =
        meter.valveOpen ? 'Running Normally' : 'Shut Off';

    showInfoSheet(
      context,
      'Meter Information',
      'Meter Code: ${meter.meterCode}\n\n'
      'Valve Status: $valveStatus\n'
      'Meter Status: ${meter.status}\n'
      'Water Supply: $waterSupply\n'
      'Connection Status: Connected\n'
      'Registered Owner: $fullName\n'
      'Location: ${meter.location}',
      Icons.speed,
    );
  }

  Future<void> logoutUser(BuildContext context) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),

      (route) => false,
    );
  }

  void showInfoSheet(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {

    showModalBottomSheet(

      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      builder: (context) {

        return Padding(

          padding: const EdgeInsets.all(24),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              Icon(
                icon,
                size: 48,
                color: AppColors.blue,
              ),

              const SizedBox(height: 12),

              Text(

                title,

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              Text(

                content,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  onPressed: () =>
                      Navigator.pop(context),

                  child: const Text('Close'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void showLogoutDialog(BuildContext context) {

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text('Logout'),

          content: const Text(
            'Are you sure you want to logout?',
          ),

          actions: [

            TextButton(

              onPressed: () =>
                  Navigator.pop(context),

              child: const Text('Cancel'),
            ),

            ElevatedButton(

              onPressed: () async {

                Navigator.pop(context);

                await logoutUser(context);
              },

              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget option(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {

    return InkWell(

      borderRadius: BorderRadius.circular(22),

      onTap: onTap,

      child: Container(

        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),

        child: Row(

          children: [

            Icon(
              icon,
              color: AppColors.blue,
            ),

            const SizedBox(width: 14),

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    title,

                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  Text(

                    subtitle,

                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: SingleChildScrollView(

        padding:
            const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          100,
        ),

        child: Column(

          children: [

            Container(

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(28),
              ),

              child: Column(

                children: [

                  const CircleAvatar(

                    radius: 46,

                    backgroundColor:
                        AppColors.blue,

                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(

                    fullName,

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  Text(

                    meterCode,

                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            option(

  context,

  Icons.speed,

  'Meter Information',

  'View your registered meter',

  showMeterInfo,
),

            option(

              context,

              Icons.security,

              'Security Settings',

              'Password and account safety',

              () {

                showInfoSheet(

                  context,

                  'Security Settings',

                  'Security options will appear here.',

                  Icons.security,
                );
              },
            ),

            option(

              context,

              Icons.logout,

              'Logout',

              'Sign out of the app',

              () {
                showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
