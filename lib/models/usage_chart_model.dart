class UsageChartItem {
  final String label;
  final double usage;

  UsageChartItem({
    required this.label,
    required this.usage,
  });

  factory UsageChartItem.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return UsageChartItem(
        label: json['label'].toString(),
        usage: double.parse(json['usage'].toString()),
      );
    } else if (json is List) {
      return UsageChartItem(
        label: json[0].toString(),
        usage: double.parse(json[1].toString()),
      );
    } else {
      throw Exception("Invalid chart item format");
    }
  }
}

class UsageChartModel {
  final List<UsageChartItem> daily;
  final List<UsageChartItem> weekly;
  final List<UsageChartItem> monthly;
  final List<UsageChartItem> annual;

  UsageChartModel({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.annual,
  });

  factory UsageChartModel.fromJson(Map<String, dynamic> json) {
    return UsageChartModel(
      daily: (json['daily'] as List? ?? [])
          .map((item) => UsageChartItem.fromJson(item))
          .toList(),

      weekly: (json['weekly'] as List? ?? [])
          .map((item) => UsageChartItem.fromJson(item))
          .toList(),

      monthly: (json['monthly'] as List? ?? [])
          .map((item) => UsageChartItem.fromJson(item))
          .toList(),

      annual: (json['annual'] as List? ?? [])
          .map((item) => UsageChartItem.fromJson(item))
          .toList(),
    );
  }
}