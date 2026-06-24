import 'package:flutter/material.dart';
import '../alerts/alerts_screen.dart';
import '../billing/bills_screen.dart';
import '../profile/profile_screen.dart';
import '../usage/usage_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final screens = const [
    HomeScreen(),
    UsageScreen(),
    BillsScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.show_chart_rounded), label: 'Usage'),
          NavigationDestination(icon: Icon(Icons.water_drop_rounded), label: 'Units'),
          NavigationDestination(icon: Icon(Icons.inbox_rounded), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
