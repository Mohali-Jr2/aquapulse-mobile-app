class AlertModel {
  final String title;
  final String message;
  final String severity;
  final String time;

  AlertModel({
    required this.title,
    required this.message,
    required this.severity,
    required this.time,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      title: json['title'],
      message: json['message'],
      severity: json['severity'],
      time: json['time'],
    );
  }
}