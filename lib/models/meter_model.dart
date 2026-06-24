class MeterModel {
  final String meterCode;
  final String location;
  final String status;
  final double todayUsage;
  final double flowRate;
  final bool valveOpen;

  MeterModel({
    required this.meterCode,
    required this.location,
    required this.status,
    required this.todayUsage,
    required this.flowRate,
    required this.valveOpen,
  });

factory MeterModel.fromJson(Map<String, dynamic> json) {
  return MeterModel(
    meterCode: (json['meter_code'] ?? '').toString(),
    location: (json['location'] ?? '').toString(),
    status: (json['status'] ?? 'Offline').toString(),
    todayUsage: double.tryParse(
            json['today_usage']?.toString() ?? '0') ??
        0,
    flowRate: double.tryParse(
            json['flow_rate']?.toString() ?? '0') ??
        0,
    valveOpen: json['valve_open'] == true,
  );
}
}