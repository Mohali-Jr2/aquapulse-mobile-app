class UsageInsightModel {
  final String percentageMessage;
  final String leakageMessage;
  final String predictionMessage;

  UsageInsightModel({
    required this.percentageMessage,
    required this.leakageMessage,
    required this.predictionMessage,
  });

  factory UsageInsightModel.fromJson(Map<String, dynamic> json) {
    return UsageInsightModel(
      percentageMessage:
          (json['percentage_message'] ?? '').toString(),
      leakageMessage:
          (json['leakage_message'] ?? '').toString(),
      predictionMessage:
          (json['prediction_message'] ?? '').toString(),
    );
  }
}