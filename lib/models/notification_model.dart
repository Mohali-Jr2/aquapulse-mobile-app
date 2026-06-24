class NotificationModel {
  final int id;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subject: (json['subject'] ?? 'Notification').toString(),
      message: (json['message'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
