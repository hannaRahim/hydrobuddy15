class ProfileModel {
  final String userId;
  final String ageRange;
  final String weightRange;
  final String activityLevel;
  final String healthCondition;
  final int dailyGoal; // Calculated value

  ProfileModel({
    required this.userId,
    required this.ageRange,
    required this.weightRange,
    required this.activityLevel,
    required this.healthCondition,
    required this.dailyGoal,
  });

  // Convert from Supabase (JSON) to Dart Object
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] as String,
      ageRange: json['age_range'] as String,
      weightRange: json['weight_range'] as String,
      activityLevel: json['activity_level'] as String,
      healthCondition: json['health_condition'] as String,
      dailyGoal: json['daily_goal'] as int,
    );
  }

  // Convert from Dart Object to Supabase (JSON)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'age_range': ageRange,
      'weight_range': weightRange,
      'activity_level': activityLevel,
      'health_condition': healthCondition,
      'daily_goal': dailyGoal,
    };
  }
}
