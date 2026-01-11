class IntakeModel {
  final String id;
  final String userId;
  final int amountMl;
  final DateTime timestamp;

  IntakeModel({
    required this.id,
    required this.userId,
    required this.amountMl,
    required this.timestamp,
  });

  factory IntakeModel.fromJson(Map<String, dynamic> json) {
    return IntakeModel(
      id: json['id'] as String? ?? '', // Handle potential nulls safely
      userId: json['user_id'] as String,
      amountMl: json['amount_ml'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'amount_ml': amountMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
