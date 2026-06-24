import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const String baseUrl = 'http://192.168.1.78:8000/api';

  Future<void> openReport(String type, String format) async {
    final url = Uri.parse('$baseUrl/reports/$type/$format/');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not open report');
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = [
      {'title': 'Daily Usage Report', 'type': 'daily'},
      {'title': 'Weekly Usage Report', 'type': 'weekly'},
      {'title': 'Monthly Usage Report', 'type': 'monthly'},
      {'title': 'Annual Usage Report', 'type': 'annual'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Download Reports',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate PDF or Excel reports from simulated dynamic meter data.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          ...reports.map((report) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            openReport(report['type']!, 'pdf');
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            openReport(report['type']!, 'excel');
                          },
                          icon: const Icon(Icons.table_chart),
                          label: const Text('Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mint,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}