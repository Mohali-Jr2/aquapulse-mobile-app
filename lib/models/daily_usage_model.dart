class DailyUsageModel {
  final String meterCode;
  final String date;
  final double usageLitres;
  final String message;

  DailyUsageModel({
    required this.meterCode,
    required this.date,
    required this.usageLitres,
    required this.message,
  });

  factory DailyUsageModel.fromJson(Map<String, dynamic> json) {
    return DailyUsageModel(
      meterCode: (json['meter_code'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      usageLitres: double.tryParse(
            (json['daily_usage'] ?? json['usage_litres'] ?? 0).toString(),
          ) ??
          0,
      message: (json['message'] ?? '').toString(),
    );
  }
}
