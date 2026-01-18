import '../../../core/services/supabase_service.dart';
import '../../../core/services/local_database_service.dart';
import 'intake_model.dart';

class HydrationRepository {
  final SupabaseService _supabaseService;
  final LocalDatabaseService _localDb = LocalDatabaseService();

  HydrationRepository(this._supabaseService);

  /// Logs a water intake entry to Local DB first (Offline support).
  /// The UI will reflect this immediately.
  Future<void> logIntake(String userId, int amountMl) async {
    try {
      final intake = IntakeModel(
        id: '', // Empty initially, will be filled when synced to Supabase
        userId: userId,
        amountMl: amountMl,
        timestamp: DateTime.now(),
        isSynced: false, // Mark as unsynced
      );

      // Save to local SQLite
      await _localDb.insertIntake(intake);
    } catch (e) {
      throw Exception('Failed to log intake locally: $e');
    }
  }

  /// Calculates the total water intake for the current day from Local DB.
  /// This acts as the Single Source of Truth for the UI.
  Future<int> getTodayTotalIntake(String userId) async {
    return await _localDb.getTodayTotal(userId);
  }

  /// Checks if there are any logs in the local DB that haven't been sent to Supabase yet.
  Future<bool> hasUnsyncedData(String userId) async {
    final unsynced = await _localDb.getUnsyncedIntakes(userId);
    return unsynced.isNotEmpty;
  }

  /// Syncs pending local logs to Supabase.
  /// This should be called by the Cubit (e.g., on app start or after logging).
  Future<void> syncPendingLogs(String userId) async {
    try {
      // 1. Get logs marked as isSynced = 0 (false)
      final unsyncedLogs = await _localDb.getUnsyncedIntakes(userId);

      for (var log in unsyncedLogs) {
        // 2. Push to Supabase
        // We use .select() to get back the generated ID from Supabase
        final response = await _supabaseService.client
            .from('intake_logs')
            .insert(log.toJson()) // toJson only includes Supabase fields
            .select()
            .single();

        // 3. If success, update Local DB with the new Supabase ID and set isSynced = 1
        final newSupabaseId = response['id'] as String;
        
        if (log.localId != null) {
          await _localDb.markAsSynced(log.localId!, newSupabaseId);
        }
      }
    } catch (e) {
      // If sync fails (e.g., no internet), we rethrow so the UI can show an error or remain in "unsynced" state.
      // The data remains safe in the local DB.
      print("Sync failed: $e");
      rethrow;
    }
  }

  /// Resets (deletes) today's logs from both Local DB and Supabase.
  Future<void> resetTodayIntake(String userId) async {
    try {
      // 1. Delete locally immediately
      await _localDb.deleteTodayIntakes(userId);
      
      // 2. Try to delete from Supabase if online (Best Effort)
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
      // If network fails, we at least cleared it locally.
      // In a more complex app, you might queue a "delete job", but this is usually sufficient.
      print("Remote delete failed (likely offline): $e");
    }
  }
}