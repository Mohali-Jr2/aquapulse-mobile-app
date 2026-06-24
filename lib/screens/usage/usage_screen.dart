import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../models/daily_usage_model.dart';
import '../../models/usage_chart_model.dart';
import '../../models/usage_insight_model.dart';
import '../../services/api_service.dart';
import '../../widgets/page_header.dart';

class UsageScreen extends StatefulWidget {
  const UsageScreen({super.key});

  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  late Future<UsageInsightModel> insightsFuture;
  late Future<UsageChartModel> chartFuture;
  late Future<DailyUsageModel> dailyUsageFuture;
  String meterCode = 'MTR-0001';

  @override
  void initState() {
    super.initState();
    refreshData();
    loadMeterAndRefresh();
  }

  void refreshData() {
    setState(() {
      insightsFuture = ApiService().fetchUsageInsights(
        meterCode: meterCode,
      );
      chartFuture = ApiService().fetchUsageChart(
        meterCode: meterCode,
      );
      dailyUsageFuture = ApiService().fetchDailyUsage(
        meterCode: meterCode,
      );
    });
  }

  Future<void> loadMeterAndRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    meterCode = prefs.getString('meter_code') ?? 'MTR-0001';
    refreshData();
  }

  Widget buildChart(
    String title,
    List<UsageChartItem> data,
  ) {
    if (data.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          '$title readings will appear here after the meter sends data.',
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    final maxUsage = data
        .map((e) => e.usage)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        data[i].usage.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        height: maxUsage == 0
                            ? 4
                            : 140 * (data[i].usage / maxUsage),
                        width: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.blue,
                              AppColors.aqua,
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        data[i].label,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget insight(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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

                const SizedBox(height: 4),

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
        ],
      ),
    );
  }

  Widget buildInsights() {
    return FutureBuilder<UsageInsightModel>(
      future: insightsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Failed to load insights: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final insights = snapshot.data!;

        return Column(
          children: [
            insight(
              Icons.trending_down,
              'Consumption Analysis',
              insights.percentageMessage,
            ),

            insight(
              Icons.nightlight_round,
              'Night Flow Monitoring',
              insights.leakageMessage,
            ),

            insight(
              Icons.water_damage,
              'Predicted Monthly Usage',
              insights.predictionMessage,
            ),
          ],
        );
      },
    );
  }

  Widget buildDailyUsage() {
    return FutureBuilder<DailyUsageModel>(
      future: dailyUsageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Failed to load daily usage: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final usage = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.blue,
                AppColors.aqua,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usage.meterCode,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${usage.usageLitres.toStringAsFixed(3)} Litres',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Today's usage for this meter",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCharts() {
    return FutureBuilder<UsageChartModel>(
      future: chartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Failed to load charts: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final chart = snapshot.data!;

        return Column(
          children: [
            buildChart('Daily Usage', chart.daily),
            buildChart('Weekly Usage', chart.weekly),
            buildChart('Monthly Usage', chart.monthly),
            buildChart('Annual Usage', chart.annual),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      appBar: AppBar(
        title: const Text('Usage Analytics'),
        actions: [
          IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await loadMeterAndRefresh();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              100,
            ),
            children: [
              const PageHeader(
                title: 'Usage Analytics',
                subtitle:
                    'Daily, weekly, monthly and annual usage',
              ),

              const SizedBox(height: 20),

              buildDailyUsage(),

              const SizedBox(height: 20),

              buildCharts(),

              const SizedBox(height: 10),

              const Text(
                'Smart Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              buildInsights(),
            ],
          ),
        ),
      ),
    );
  }
}
