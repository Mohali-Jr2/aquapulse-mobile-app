import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/meter_model.dart';
import '../models/daily_usage_model.dart';
import '../models/payment_model.dart';
import '../models/alert_model.dart';
import '../models/usage_insight_model.dart';
import '../models/usage_chart_model.dart';
import '../models/valve_model.dart';
import '../models/notification_model.dart';

class ApiService {

  static const String baseUrl =
      'http://192.168.1.78:8000/api';

  // MOBILE REGISTER
  Future<Map<String, dynamic>> mobileRegister({

    required String phoneNumber,
    required String meterCode,
    required String email,
    required String password,

  }) async {

    final response = await http.post(

      Uri.parse('$baseUrl/mobile/register/'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({

        'phone_number': phoneNumber,
        'meter_code': meterCode,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    return {

      'success': response.statusCode == 200,

      'message': data['message'] ?? '',

      'error': data['error'] ?? '',

      'data': data,
    };
  }

  // MOBILE LOGIN
  Future<Map<String, dynamic>> mobileLogin({

    required String phoneNumber,
    required String meterCode,
    required String password,

  }) async {

    final response = await http.post(

      Uri.parse('$baseUrl/mobile/login/'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({

        'phone_number': phoneNumber,
        'meter_code': meterCode,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    return {

      'success': response.statusCode == 200,

      'message': data['message'] ?? '',

      'error': data['error'] ?? '',

      'full_name': data['full_name'] ?? '',

      'meter_code': data['meter_code'] ?? '',

      'location': data['location'] ?? '',

      'data': data,
    };
  }

  // SEND RESET CODE
  Future<Map<String, dynamic>> sendResetCode({

    required String email,

  }) async {

    final response = await http.post(

      Uri.parse(
        '$baseUrl/mobile/send-reset-code/',
      ),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({

        'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    return {

      'success': response.statusCode == 200,

      'message': data['message'] ?? '',

      'error': data['error'] ?? '',
    };
  }

  // RESET PASSWORD
  Future<Map<String, dynamic>> resetPassword({

    required String email,
    required String code,
    required String newPassword,

  }) async {

    final response = await http.post(

      Uri.parse(
        '$baseUrl/mobile/reset-password/',
      ),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({

        'email': email,

        'code': code,

        'new_password': newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    return {

      'success': response.statusCode == 200,

      'message': data['message'] ?? '',

      'error': data['error'] ?? '',
    };
  }

  // FETCH LIVE METER
  Future<MeterModel> fetchLatestMeter({
    String meterCode = 'MTR-0001',
  }) async {

    final response = await http.get(
      Uri.parse('$baseUrl/meter/latest/?meter_code=$meterCode'),
    );

    if (response.statusCode == 200) {

      return MeterModel.fromJson(
        jsonDecode(response.body),
      );

    } else {

      throw Exception(
        'Failed to load meter data',
      );
    }
  }

  // FETCH DAILY USAGE FOR ONE METER
  Future<DailyUsageModel> fetchDailyUsage({
    String meterCode = 'MTR-0001',
  }) async {

    final response = await http.get(
      Uri.parse('$baseUrl/meter/daily-usage/?meter_code=$meterCode'),
    );

    if (response.statusCode == 200) {

      return DailyUsageModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to load daily usage',
    );
  }

  // FETCH ALERTS
  Future<List<AlertModel>> fetchAlerts() async {

    final response = await http.get(
      Uri.parse('$baseUrl/meter/alerts/'),
    );

    if (response.statusCode == 200) {

      final List<dynamic> data =
          jsonDecode(response.body);

      return data.map((item) {

        return AlertModel.fromJson(item);

      }).toList();

    } else {

      throw Exception(
        'Failed to load alerts',
      );
    }
  }

  // FETCH USAGE INSIGHTS
  Future<UsageInsightModel>
      fetchUsageInsights({
    String meterCode = 'MTR-0001',
  }) async {

    final response = await http.get(

      Uri.parse(
        '$baseUrl/meter/usage-insights/?meter_code=$meterCode',
      ),
    );

    if (response.statusCode == 200) {

      return UsageInsightModel.fromJson(
        jsonDecode(response.body),
      );

    } else {

      throw Exception(
        'Failed to load usage insights',
      );
    }
  }

  // FETCH USAGE CHART
Future<UsageChartModel> fetchUsageChart({
  String meterCode = 'MTR-0001',
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/meter/usage-chart/?meter_code=$meterCode'),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    return UsageChartModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  } else {
    throw Exception('Failed to load usage chart');
  }
}

  // FETCH VALVE STATUS
Future<ValveModel> fetchValveStatus(String meterCode) async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/valve/status/?meter_code=$meterCode',
    ),
  );

  if (response.statusCode == 200) {
    return ValveModel.fromJson(
      jsonDecode(response.body),
    );
  }

  throw Exception(response.body);
}

  // CONTROL VALVE
Future<bool> controlValve(
  String meterCode,
  bool valveOpen,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/valve/control/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'meter_code': meterCode,
      'valve_open': valveOpen,
    }),
  );

  return response.statusCode == 200;
}

  // SUBMIT SUPPORT REQUEST
  Future<bool> submitSupportRequest({

    required String issueType,
    required String phoneNumber,
    required String description,
    required String meterCode,

  }) async {

    final response = await http.post(

      Uri.parse(
        '$baseUrl/support/request/',
      ),

      headers: {
        'Content-Type':
            'application/json',
      },

      body: jsonEncode({

        'issue_type': issueType,

        'phone_number': phoneNumber,

        'description': description,
        'meter_code': meterCode,
      }),
    );

    return response.statusCode == 200;
  }

  Future<List<NotificationModel>> fetchNotifications(
    String meterCode,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/?meter_code=$meterCode'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map(
          (item) => NotificationModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // FETCH CURRENT BILL
Future<BillModel> fetchCurrentBill(String meterCode) async {
  final response = await http.get(
    Uri.parse('$baseUrl/bill/current/?meter_code=$meterCode'),
  );

  if (response.statusCode == 200) {
    return BillModel.fromJson(
      jsonDecode(response.body),
    );
  } else {
    throw Exception(response.body);
  }
}

  // PAY BILL
  Future<Map<String, dynamic>> payBill({

    required int billId,
    required String amount,
    required String phoneNumber,
    required String paymentMethod,

  }) async {

    final response = await http.post(

      Uri.parse('$baseUrl/bill/pay/'),

      headers: {
        'Content-Type':
            'application/json'
      },

      body: jsonEncode({

        'bill_id': billId,

        'amount': amount,

        'phone_number': phoneNumber,

        'payment_method':
            paymentMethod,
      }),
    );

    final data =
        jsonDecode(response.body);

    return {

      'success':
          response.statusCode == 200,

      'data': data,
    };
  }

  Future<Map<String, dynamic>> requestMtnPayment({
    required int billId,
    required String amount,
    required String phoneNumber,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/momo/mtn/request-to-pay/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'bill_id': billId,
            'amount': amount,
            'phone_number': phoneNumber,
          }),
        )
        .timeout(const Duration(seconds: 35));

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{'error': 'The payment server returned no response.'};
    return {
      'success': response.statusCode == 202,
      'data': data,
    };
  }

  Future<Map<String, dynamic>> fetchMtnPaymentStatus(
    String referenceId,
  ) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/momo/mtn/status/$referenceId/'),
        )
        .timeout(const Duration(seconds: 35));
    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{'error': 'The payment server returned no response.'};
    return {
      'success': response.statusCode == 200,
      'data': data,
    };
  }

  // PAYMENT HISTORY
Future<List<PaymentModel>> fetchPaymentHistory(String meterCode) async {
  final response = await http.get(
    Uri.parse('$baseUrl/bill/history/?meter_code=$meterCode'),
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);

    return data.map((json) => PaymentModel.fromJson(json)).toList();
  } else {
    throw Exception("Failed to load payment history");
  }
}
  // FETCH WATER CREDIT
  Future<Map<String, dynamic>>
      fetchWaterCredit(
          String meterCode) async {

    final response = await http.get(

      Uri.parse(
        '$baseUrl/water-credit/$meterCode/',
      ),
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );

    } else {

      throw Exception(
        'Failed to load water credit',
      );
    }
  }
}
