import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> showSupportForm(
    BuildContext context,
    String issueTitle,
    IconData icon,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final descriptionController = TextEditingController();
    final phoneController = TextEditingController(
      text: prefs.getString('phone_number') ?? '',
    );
    final meterCode = prefs.getString('meter_code') ?? '';

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: AppColors.blue),

                const SizedBox(height: 12),

                Text(
                  issueTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Your Phone Number',
                    hintText: 'e.g. 0771234567',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Describe the issue',
                    hintText: 'Explain what happened...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Submit Request'),

                    onPressed: () async {
                      if (phoneController.text.trim().isEmpty ||
                          descriptionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                          ),
                        );
                        return;
                      }

                      final success =
                          await ApiService().submitSupportRequest(
                        issueType: issueTitle,
                        phoneNumber: phoneController.text.trim(),
                        description:
                            descriptionController.text.trim(),
                        meterCode: meterCode,
                      );

                      if (!context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);

                      if (success) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Support request submitted successfully',
                            ),
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to submit request',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget supportItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        showSupportForm(context, title, icon);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Choose the issue you want to report.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 22),

          supportItem(
            context,
            'Report Leakage',
            'Report suspected pipe or meter leakage',
            Icons.water_damage_rounded,
          ),

          supportItem(
            context,
            'Faulty Meter',
            'Report offline or damaged smart meter',
            Icons.speed_rounded,
          ),

          supportItem(
            context,
            'Wrong Bill',
            'Report incorrect billing or payment issue',
            Icons.receipt_long_rounded,
          ),

          supportItem(
            context,
            'Contact Support',
            'Send a message to customer support',
            Icons.support_agent_rounded,
          ),
        ],
      ),
    );
  }
}
