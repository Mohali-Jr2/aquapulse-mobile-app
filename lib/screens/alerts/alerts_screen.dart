import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../models/alert_model.dart';
import '../../models/notification_model.dart';
import '../../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<AlertModel>> alertsFuture;
  Future<List<NotificationModel>>? notificationsFuture;
  String meterCode = '';

  @override
  void initState() {
    super.initState();
    alertsFuture = ApiService().fetchAlerts();
    loadInbox();
  }

  Future<void> loadInbox() async {
    final prefs = await SharedPreferences.getInstance();
    meterCode = prefs.getString('meter_code') ?? '';
    if (!mounted) return;
    setState(() {
      notificationsFuture = ApiService().fetchNotifications(meterCode);
    });
  }

  Future<void> refreshAll() async {
    setState(() {
      alertsFuture = ApiService().fetchAlerts();
      if (meterCode.isNotEmpty) {
        notificationsFuture = ApiService().fetchNotifications(meterCode);
      }
    });
    await alertsFuture;
    await notificationsFuture;
  }

  Widget emptyList(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 90),
        const Icon(Icons.inbox_outlined, size: 52, color: Colors.black26),
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget alertsTab() {
    return FutureBuilder<List<AlertModel>>(
      future: alertsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return emptyList('Failed to load meter alerts.');
        }
        final alerts = snapshot.data ?? [];
        if (alerts.isEmpty) return emptyList('No meter alerts available.');

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            final color = alert.severity == 'Warning'
                ? AppColors.warning
                : AppColors.mint;
            return inboxCard(
              icon: Icons.warning_amber_rounded,
              color: color,
              title: alert.title,
              message: alert.message,
              trailing: alert.time,
            );
          },
        );
      },
    );
  }

  Widget messagesTab() {
    final future = notificationsFuture;
    if (future == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<NotificationModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return emptyList('Failed to load regulator messages.');
        }
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return emptyList('No messages from the regulator yet.');
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final item = messages[index];
            return inboxCard(
              icon: Icons.mark_email_read_rounded,
              color: AppColors.blue,
              title: item.subject,
              message: item.message,
              trailing: DateFormat('d MMM, HH:mm').format(item.createdAt.toLocal()),
            );
          },
        );
      },
    );
  }

  Widget inboxCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  trailing,
                  style: const TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Inbox'),
          actions: [
            IconButton(
              onPressed: refreshAll,
              tooltip: 'Refresh inbox',
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.warning_amber_rounded), text: 'Meter Alerts'),
              Tab(icon: Icon(Icons.mail_rounded), text: 'Messages'),
            ],
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: refreshAll,
            child: TabBarView(
              children: [
                alertsTab(),
                messagesTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
