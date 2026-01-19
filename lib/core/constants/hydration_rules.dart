import 'dart:math';

class HydrationRules {
  // --- Dropdown Options ---

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

  // Updated Health Conditions based on the provided chart
  static const List<String> healthConditions = [
    'Normal healthy adult',
    'Kidney stones',
    'Urinary tract infection (UTI)',
    'Constipation',
    'High blood pressure (controlled)',
    'Liver disease (fluid retention)',
    'Heart problems / heart failure',
    'Kidney disease',
  ];

  // --- Rule-Based Calculation ---

  /// Determines the daily water intake goal (in ml) based on profile selections.
  static int getDailyGoal({
    required String ageRange,
    required String weightRange,
    required String activityLevel,
    required String healthCondition,
  }) {
    // 1. Calculate the "Standard" metabolic need first
    int baseCalculation = 2000; // Base: 2 Liters

    // Weight Adjustment
    switch (weightRanges.indexOf(weightRange)) {
      case 0: baseCalculation += 0; break;    // <50kg
      case 1: baseCalculation += 500; break;  // 50-70kg
      case 2: baseCalculation += 750; break;  // 71-90kg
      case 3: baseCalculation += 1000; break; // >90kg
    }

    // Activity Adjustment
    if (activityLevel == 'Moderately Active') {
      baseCalculation += 500;
    } else if (activityLevel == 'Active') {
      baseCalculation += 1000;
    }

    // Age Adjustment (Metabolism slows with age)
    if (ageRange == '65+') {
      baseCalculation -= 250;
    }

    // 2. Apply Health Condition Rules
    
    // CASE A: Strict Medical Restrictions (Safety First)
    // These conditions require fluid restriction regardless of weight/activity.
    // We use the upper bound of the recommended range to be safe but sufficient.
    
    if (healthCondition == 'Kidney disease') {
      return 1000; // Range: 500-1000 ml
    }
    
    if (healthCondition == 'Heart problems / heart failure') {
      return 1500; // Range: 1000-1500 ml
    }
    
    if (healthCondition == 'Liver disease (fluid retention)') {
      return 1500; // Range: 1000-1500 ml
    }

    // CASE B: Controlled Limits
    if (healthCondition == 'High blood pressure (controlled)') {
      // Range: 1500-2000 ml. We cap strictly at 2000.
      return 2000;
    }

    // CASE C: High Intake Requirements
    // For these, we ensure the intake is AT LEAST the recommended amount.
    // If the user's calculated need is higher (e.g. big athlete), we keep the higher value.
    
    if (healthCondition == 'Constipation') {
      // Range: 2500-3000 ml. Minimum target 3000.
      return max(baseCalculation, 3000); 
    }
    
    if (healthCondition == 'Urinary tract infection (UTI)') {
      // Range: 2500-3000 ml. Minimum target 3000.
      return max(baseCalculation, 3000);
    }
    
    if (healthCondition == 'Kidney stones') {
      // Range: 3000-3500 ml. Minimum target 3500 to help flush stones.
      return max(baseCalculation, 3500);
    }

    // CASE D: Normal Healthy Adult
    // Range: 2000-2500 ml. 
    // We use the calculated metabolic need (baseCalculation) but ensure it's at least 2000.
    // This allows active/heavier users to get more than 2500 if needed.
    return max(baseCalculation, 2000);
  }
}