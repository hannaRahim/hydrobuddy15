class HydrationRules {
  // --- Dropdown Options (Strictly Defined) ---

  static const List<String> ageRanges = ['18-30', '31-50', '51-65', '65+'];

  static const List<String> weightRanges = [
    'Below 50kg',
    '50kg - 70kg',
    '71kg - 90kg',
    'Above 90kg',
  ];

  static const List<String> activityLevels = [
    'Inactive', // Sedentary job, little exercise
    'Moderately Active', // Light exercise 1-3 days/week
    'Active', // Intense exercise 4+ days/week
  ];

  static const List<String> healthConditions = [
    'None',
    'Diabetes', // May require specific hydration monitoring
    'Dengue', // Requires increased hydration
  ];

  // --- Rule-Based Calculation ---

  /// Determines the daily water intake goal (in ml) based on profile selections.
  /// This is a deterministic lookup, NOT an AI prediction.
  static int getDailyGoal({
    required String ageRange,
    required String weightRange,
    required String activityLevel,
    required String healthCondition,
  }) {
    int baseIntake = 2000; // Base: 2 Liters

    // 1. Weight Adjustment
    switch (weightRanges.indexOf(weightRange)) {
      case 0:
        baseIntake += 0;
        break; // <50kg
      case 1:
        baseIntake += 500;
        break; // 50-70kg
      case 2:
        baseIntake += 750;
        break; // 71-90kg
      case 3:
        baseIntake += 1000;
        break; // >90kg
    }

    // 2. Activity Adjustment
    if (activityLevel == 'Moderately Active') {
      baseIntake += 500;
    } else if (activityLevel == 'Active') {
      baseIntake += 1000;
    }

    // 3. Age Adjustment (Metabolism slows with age)
    if (ageRange == '65+') {
      baseIntake -= 250;
    }

    // 4. Health Condition Overrides (Critical Rules)
    if (healthCondition == 'Dengue') {
      // Dengue recovery requires significant fluids
      // If calculated is less than 3500, boost it.
      if (baseIntake < 3500) return 3500;
    }

    // Diabetes rule: Standard intake is usually fine, but cap strict upper limits
    // to avoid over-hydration strain if kidney issues exist (simplified rule).
    // For this app scope, we maintain calculated base or cap at 4000ml.
    if (healthCondition == 'Diabetes' && baseIntake > 4000) {
      return 4000;
    }

    return baseIntake;
  }
}
