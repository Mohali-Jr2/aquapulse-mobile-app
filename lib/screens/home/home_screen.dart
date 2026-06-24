import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../models/meter_model.dart';
import '../../services/api_service.dart';

import '../../widgets/action_tile.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/stat_card.dart';

import '../billing/bills_screen.dart';
import '../reports/reports_screen.dart';
import '../support/support_screen.dart';
import '../valve/valve_control_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<MeterModel> meterFuture;

  String fullName = 'User';
  String meterCode = '';

  @override
  void initState() {
    super.initState();

    meterFuture = loadUserName();
  }

  Future<MeterModel> loadUserName() async {

    final prefs =
        await SharedPreferences.getInstance();

    final savedFullName =
        prefs.getString('full_name') ??
        'User';

    final savedMeterCode =
        prefs.getString('meter_code') ??
        'MTR-0001';

    setState(() {

      fullName =
          savedFullName;

      meterCode =
          savedMeterCode;
    });

    return ApiService().fetchLatestMeter(
      meterCode: savedMeterCode,
    );
  }

  Future<void> refreshMeter() async {

    setState(() {

      meterFuture =
          ApiService().fetchLatestMeter(
        meterCode: meterCode.isEmpty
            ? 'MTR-0001'
            : meterCode,
      );
    });

    await meterFuture;
  }

  @override
  Widget build(BuildContext context) {

    return Container(

  color: Colors.grey.shade100,

    child: SafeArea(

        child: FutureBuilder<MeterModel>(

          future: meterFuture,

          builder: (context, snapshot) {

            // LOADING
            if (snapshot.connectionState ==
                ConnectionState.waiting) {

              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ERROR
            if (snapshot.hasError) {

              return Center(

                child: Padding(

                  padding: const EdgeInsets.all(20),

                  child: Column(

                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Failed to load meter data\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: refreshMeter,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // NULL CHECK
            if (!snapshot.hasData) {

              return const Center(
                child: Text('No meter data found'),
              );
            }

            final meter = snapshot.data!;

            return RefreshIndicator(

              onRefresh: refreshMeter,

              child: SingleChildScrollView(

                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  20,
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // HEADER
                    Row(

                      children: [

                        const CircleAvatar(

                          radius: 25,

                          backgroundColor:
                              AppColors.blue,

                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              const Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),

                              Text(

                                fullName,

                                maxLines: 1,

                                overflow:
                                    TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // USAGE CARD
                    GradientCard(

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(

                            '$meterCode • ${meter.status}',

                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(

                            "Today's Water Usage",

                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(

                            '${meter.todayUsage.toStringAsFixed(3)} Litres',

                            style: const TextStyle(

                              color: Colors.white,

                              fontSize: 36,

                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const LinearProgressIndicator(

                            value: .68,

                            color: Colors.white,

                            backgroundColor:
                                Colors.white24,
                          ),

                          const SizedBox(height: 8),

                          const Text(

                            'Pull down to refresh live reading',

                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // STATS
                    Row(

                      children: [

                        Expanded(

                          child: StatCard(

                            icon:
                                Icons.water_drop_rounded,

                            title: 'Flow Rate',

                            value:
                                '${meter.flowRate} L/min',
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(

                          child: StatCard(

                            icon:
                                Icons.lock_open_rounded,

                            title: 'Valve',

                            value: meter.valveOpen
                                ? 'Open'
                                : 'Closed',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // QUICK ACTION TITLE
                    Row(

                      children: [

                        const Expanded(

                          child: Text(

                            'Quick Actions',

                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),

                        IconButton(

                          onPressed: refreshMeter,

                          icon: const Icon(
                            Icons.refresh_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // QUICK ACTIONS GRID
                    GridView(

                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(

                        crossAxisCount: 2,

                        crossAxisSpacing: 12,

                        mainAxisSpacing: 12,

                        childAspectRatio: 1.25,
                      ),

                      children: [

                        ActionTile(

                          icon:
                              Icons.power_settings_new_rounded,

                          title: 'Valve Control',

                          subtitle:
                              'Open or close water',

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    const ValveControlScreen(),
                              ),
                            );
                          },
                        ),

                        ActionTile(

                          icon:
                              Icons.picture_as_pdf_rounded,

                          title: 'Reports',

                          subtitle:
                              'PDF and Excel',

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    const ReportsScreen(),
                              ),
                            );
                          },
                        ),

                        ActionTile(

                          icon:
                              Icons.support_agent_rounded,

                          title: 'Support',

                          subtitle:
                              'Report a problem',

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    const SupportScreen(),
                              ),
                            );
                          },
                        ),

                        ActionTile(

                          icon:
                              Icons.payment_rounded,

                          title: 'Mobile Money',

                          subtitle:
                              'MTN and Airtel',

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    const BillsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
