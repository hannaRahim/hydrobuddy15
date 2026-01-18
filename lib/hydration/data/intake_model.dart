class IntakeModel {
  final String id;
  final int? localId;
  final String userId;
  final int amountMl;
  final DateTime timestamp;
  final bool isSynced;

  IntakeModel({
    required this.id,
    this.localId,
    required this.userId,
    required this.amountMl,
    required this.timestamp,
    this.isSynced = true,
  });

  factory IntakeModel.fromJson(Map<String, dynamic> json) {
    return IntakeModel(
      id: json['id'] as String? ?? '', // Handle potential nulls safely
      userId: json['user_id'] as String,
      amountMl: json['amount_ml'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'amount_ml': amountMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  // --- SQLite Helpers ---

  factory IntakeModel.fromLocalJson(Map<String, dynamic> json) {
    return IntakeModel(
      id: json['supabase_id'] as String? ?? '',
      localId: json['local_id'] as int?,
      userId: json['user_id'] as String,
      amountMl: json['amount_ml'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSynced: (json['is_synced'] as int) == 1,
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'supabase_id': id.isEmpty ? null : id, // Store null if no supabase ID yet
      'user_id': userId,
      'amount_ml': amountMl,
      'timestamp': timestamp.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }
}
