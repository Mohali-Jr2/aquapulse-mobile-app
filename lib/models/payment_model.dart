class BillModel {
  final int id;
  final String meterCode;
  final String billingPeriod;
  final double usageLitres;
  final double amount;
  final String status;
  final String dueDate;

  BillModel({
    required this.id,
    required this.meterCode,
    required this.billingPeriod,
    required this.usageLitres,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      meterCode: (json['meter_code'] ?? '').toString(),
      billingPeriod: (json['billing_period'] ?? '').toString(),
      usageLitres: double.parse(json['usage_litres'].toString()),
      amount: double.parse(json['amount'].toString()),
      status: (json['status'] ?? '').toString(),
      dueDate: (json['due_date'] ?? '').toString(),
    );
  }
}

class PaymentModel {
  final String title;
  final String amount;
  final String status;
  final String date;

  PaymentModel({
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      title: (json['title'] ?? json['payment_method'] ?? 'Payment').toString(),
      amount: json['amount'].toString(),
      status: (json['status'] ?? json['payment_status'] ?? '').toString(),
      date: (json['date'] ?? json['paid_at'] ?? '').toString(),
    );
  }
}
