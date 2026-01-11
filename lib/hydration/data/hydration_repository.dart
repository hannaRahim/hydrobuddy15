import '../../../core/services/supabase_service.dart';
import 'intake_model.dart';

class HydrationRepository {
  final SupabaseService _supabaseService;

  HydrationRepository(this._supabaseService);

  /// Logs a water intake entry to Supabase
  Future<void> logIntake(String userId, int amountMl) async {
    try {
      final intake = IntakeModel(
        id: '', // Supabase generates the ID
        userId: userId,
        amountMl: amountMl,
        timestamp: DateTime.now(),
      );

      // We exclude 'id' from the insert payload as it is auto-generated
      final data = intake.toJson();

      await _supabaseService.client.from('intake_logs').insert(data);
    } catch (e) {
      throw Exception('Failed to log intake: $e');
    }
  }

  /// Calculates the total water intake for the current day
  Future<int> getTodayTotalIntake(String userId) async {
    try {
      final now = DateTime.now();
      // Start of day: 00:00:00
      final startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String();
      // End of day: 23:59:59
      final endOfDay = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      ).toIso8601String();

      final response = await _supabaseService.client
          .from('intake_logs')
          .select('amount_ml')
          .eq('user_id', userId)
          .gte('timestamp', startOfDay)
          .lte('timestamp', endOfDay);

      if (response == null) return 0;

      final List<dynamic> data = response;
      if (data.isEmpty) return 0;

      int total = 0;
      for (var row in data) {
        total += (row['amount_ml'] as int);
      }
      return total;
    } catch (e) {
      // In a production app, we might log this error to a service
      return 0;
    }
  }

  /// Optional: Resets (deletes) today's logs
  Future<void> resetTodayIntake(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String();
      final endOfDay = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      ).toIso8601String();

      await _supabaseService.client
          .from('intake_logs')
          .delete()
          .eq('user_id', userId)
          .gte('timestamp', startOfDay)
          .lte('timestamp', endOfDay);
    } catch (e) {
      throw Exception('Failed to reset intake: $e');
    }
  }
}
