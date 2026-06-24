import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../models/payment_model.dart';
import '../../services/api_service.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen>
    with WidgetsBindingObserver {
  late Future<BillModel> billFuture;
  late Future<List<PaymentModel>> paymentHistoryFuture;
  late Future<Map<String, dynamic>> waterCreditFuture;
  String meterCode = 'MTR-0001';
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refreshData();
    loadMeterAndRefresh();
    refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        if (mounted) refreshData();
      },
    );
  }

  void refreshData() {
    if (!mounted) return;
    setState(() {
      billFuture = ApiService().fetchCurrentBill(meterCode);
      paymentHistoryFuture = ApiService().fetchPaymentHistory(meterCode);
      waterCreditFuture = ApiService().fetchWaterCredit(meterCode);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadMeterAndRefresh();
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> loadMeterAndRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    meterCode = prefs.getString('meter_code') ?? 'MTR-0001';
    refreshData();
  }

  void showPaymentForm(BuildContext context, BillModel bill) {
    final amountController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 22,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 22,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Buy Water Units',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount to Pay',
                    prefixText: 'UGX ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Money Number',
                    hintText: 'e.g. 0771234567',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          submitPayment(
                            sheetContext: sheetContext,
                            bill: bill,
                            method: 'MTN Mobile Money',
                            amount: amountController.text,
                            phone: phoneController.text,
                          );
                        },
                        child: const Text('MTN'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          submitPayment(
                            sheetContext: sheetContext,
                            bill: bill,
                            method: 'Airtel Money',
                            amount: amountController.text,
                            phone: phoneController.text,
                          );
                        },
                        child: const Text('Airtel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> submitPayment({
    required BuildContext sheetContext,
    required BillModel bill,
    required String method,
    required String amount,
    required String phone,
  }) async {
    if (amount.trim().isEmpty || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter amount and phone number'),
        ),
      );
      return;
    }

    if (method == 'MTN Mobile Money') {
      await submitMtnPayment(
        sheetContext: sheetContext,
        bill: bill,
        amount: amount.trim(),
        phone: phone.trim(),
      );
      return;
    }

    final result = await ApiService().payBill(
      billId: bill.id,
      amount: amount.trim(),
      phoneNumber: phone.trim(),
      paymentMethod: method,
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    final data = result['data'];

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment successful. You bought ${data['litres_bought']} litres.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      showPaymentSuccessDialog(data);
      refreshData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['error'] ?? 'Payment failed'),
        ),
      );
    }
  }

  Future<void> submitMtnPayment({
    required BuildContext sheetContext,
    required BillModel bill,
    required String amount,
    required String phone,
  }) async {
    Navigator.of(sheetContext).pop();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text('Connecting to MTN'),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 18),
            Expanded(child: Text('Sending the payment request...')),
          ],
        ),
      ),
    );

    Map<String, dynamic> result;
    try {
      result = await ApiService().requestMtnPayment(
        billId: bill.id,
        amount: amount,
        phoneNumber: phone,
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await showMtnError(
        'Could not contact the payment server.\n\n$error',
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    final data = result['data'] as Map<String, dynamic>;
    if (result['success'] != true) {
      final configurationRequired = data['configuration_required'] == true;
      await showMtnError(
        configurationRequired
            ? 'MTN sandbox is not activated on the server yet. Add the Collections subscription key, API user and API key, then restart Django.'
            : (data['error'] ?? 'MTN payment request failed').toString(),
      );
      return;
    }

    final referenceId = data['reference_id'].toString();
    final sandbox = data['sandbox'] == true;
    final waitingMessage = sandbox
        ? 'MTN sandbox accepted the request and is simulating the payment response. No real money will be charged.'
        : 'Approve the payment request on your MTN Mobile Money phone.';
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(sandbox ? 'MTN Sandbox Payment' : 'Approve MTN Payment'),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 18),
            Expanded(
              child: Text(waitingMessage),
            ),
          ],
        ),
      ),
    );

    Map<String, dynamic>? statusData;
    for (var attempt = 0; attempt < 20; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      final statusResult = await ApiService().fetchMtnPaymentStatus(referenceId);
      if (!mounted) return;
      if (statusResult['success'] != true) {
        statusData = statusResult['data'] as Map<String, dynamic>;
        break;
      }

      statusData = statusResult['data'] as Map<String, dynamic>;
      final status = statusData['status']?.toString().toUpperCase();
      if (status == 'SUCCESSFUL' || status == 'FAILED') break;
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    final status = statusData?['status']?.toString().toUpperCase();
    if (status == 'SUCCESSFUL') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MTN payment confirmed successfully.')),
      );
      showPaymentSuccessDialog(statusData!);
      refreshData();
    } else if (status == 'FAILED') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            statusData?['message']?.toString().isNotEmpty == true
                ? statusData!['message'].toString()
                : 'MTN declined the payment.',
          ),
        ),
      );
    } else if (statusData?['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(statusData!['error'].toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment is still pending. Refresh payment history shortly.',
          ),
        ),
      );
    }
  }

  Future<void> showMtnError(String message) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('MTN Payment Unavailable'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showPaymentSuccessDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Water Units Added'),
          content: Text(
            'You bought: ${data['litres_bought']} litres\n'
            'Available balance: ${data['available_litres']} litres\n'
            'Valve status: ${data['valve_open'] == true ? "Opened" : "Closed"}\n'
            'Rate: ${data['rate']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildWaterCreditCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: waterCreditFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Failed to load water balance: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final credit = snapshot.data!;
        final litres = credit['available_litres'];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.mint,
                child: Icon(Icons.water_drop, color: Colors.white),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Water Units',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$litres litres remaining',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: refreshData,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildBillCard(BillModel bill) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.mint, AppColors.blue],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Bill', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),

          FittedBox(
            child: Text(
              'UGX ${bill.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Due: ${bill.dueDate}',
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 6),

          Text(
            'Status: ${bill.status} • Usage: ${bill.usageLitres.toStringAsFixed(0)} L',
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                showPaymentForm(context, bill);
              },
              icon: const Icon(Icons.phone_android),
              label: const Text(
                'Buy Water Units',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentHistoryTile(PaymentModel payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.mint),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              '${payment.title}\n${payment.date}',
              style: const TextStyle(height: 1.4),
            ),
          ),

          Text(
            'UGX ${payment.amount}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildBuyUnitsSection() {
    return FutureBuilder<BillModel>(
      future: billFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Unable to prepare payment: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final bill = snapshot.data!;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.blue,
                child: Icon(Icons.phone_android, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buy Water Units',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Choose an amount and pay with mobile money.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => showPaymentForm(context, bill),
                tooltip: 'Buy water units',
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPaymentHistory() {
    return FutureBuilder<List<PaymentModel>>(
      future: paymentHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Failed to load payment history: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final payments = snapshot.data ?? [];

        if (payments.isEmpty) {
          return const Text(
            'No payments yet.',
            style: TextStyle(color: Colors.black54),
          );
        }

        return Column(
          children: payments.map(paymentHistoryTile).toList(),
        );
      },
    );
  }

  Widget buildBillSection() {
    return FutureBuilder<BillModel>(
      future: billFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Failed to load bill: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        return buildBillCard(snapshot.data!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      appBar: AppBar(
        title: const Text('Water Units'),
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
            padding: const EdgeInsets.all(20),
            children: [
              buildWaterCreditCard(),

              buildBuyUnitsSection(),

              const SizedBox(height: 22),

              const Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              buildPaymentHistory(),
            ],
          ),
        ),
      ),
    );
  }
}
