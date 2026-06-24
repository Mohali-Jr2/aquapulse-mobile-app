import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../models/valve_model.dart';
import '../../services/api_service.dart';

class ValveControlScreen extends StatefulWidget {
  const ValveControlScreen({super.key});

  @override
  State<ValveControlScreen> createState() =>
      _ValveControlScreenState();
}

class _ValveControlScreenState
    extends State<ValveControlScreen> {
  late Future<ValveModel> valveFuture;

  bool valveOpen = false;
  bool loading = false;
  String meterCode = 'MTR-0001';

  @override
  void initState() {
    super.initState();
    valveFuture = ApiService().fetchValveStatus(meterCode);
    loadMeterAndValveStatus();
  }

  Future<void> loadMeterAndValveStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    meterCode = prefs.getString('meter_code') ?? 'MTR-0001';
    loadValveStatus();
  }

  void loadValveStatus() {
    valveFuture =
    ApiService().fetchValveStatus(meterCode);

    valveFuture.then((value) {
      if (mounted) {
        setState(() {
          valveOpen = value.valveOpen;
        });
      }
    });
  }

  Future<void> toggleValve(bool value) async {
    setState(() {
      loading = true;
    });

    final success =
        await ApiService().controlValve(
  meterCode,
  value,
);

    if (!mounted) return;

    setState(() {
      loading = false;

      if (success) {
        valveOpen = value;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? value
                    ? 'Valve opened successfully'
                    : 'Valve closed successfully'
              : 'Failed to control valve',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      appBar: AppBar(
        title: const Text('Valve Control'),
        actions: [
          IconButton(
            onPressed: loadMeterAndValveStatus,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: FutureBuilder<ValveModel>(
        future: valveFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load valve status\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      colors: valveOpen
                          ? [
                              AppColors.mint,
                              AppColors.blue,
                            ]
                          : [
                              AppColors.danger,
                              AppColors.deepBlue,
                            ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        valveOpen
                            ? Icons.lock_open
                            : Icons.lock,
                        color: Colors.white,
                        size: 90,
                      ),

                      const SizedBox(height: 18),

                      Text(
                        valveOpen
                            ? 'Valve is Open'
                            : 'Valve is Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Control water supply remotely through the relay and solenoid valve.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SwitchListTile(
                    value: valveOpen,

                    onChanged: loading
                        ? null
                        : (value) {
                            toggleValve(value);
                          },

                    title: const Text(
                      'Water Valve Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      valveOpen
                          ? 'Water supply currently active'
                          : 'Water supply currently shut off',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (loading)
                  const CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}
