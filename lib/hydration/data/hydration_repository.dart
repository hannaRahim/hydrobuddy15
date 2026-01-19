import '../../../core/services/supabase_service.dart';
import '../../../core/services/local_database_service.dart';
import 'intake_model.dart';

class HydrationRepository {
  final SupabaseService _supabaseService;
  final LocalDatabaseService _localDb = LocalDatabaseService();

  HydrationRepository(this._supabaseService);

  Future<void> logIntake(String userId, int amountMl) async {
    try {
      final intake = IntakeModel(
        id: '',
        userId: userId,
        amountMl: amountMl,
        timestamp: DateTime.now(),
        isSynced: false,
      );
      await _localDb.insertIntake(intake);
    } catch (e) {
      throw Exception('Failed to log intake locally: $e');
    }
  }

  Future<int> getTodayTotalIntake(String userId) async {
    return await _localDb.getTodayTotal(userId);
  }

  // --- NEW: Get List ---
  Future<List<IntakeModel>> getTodayIntakes(String userId) async {
    return await _localDb.getTodayLogs(userId);
  }

  Future<bool> hasUnsyncedData(String userId) async {
    final unsynced = await _localDb.getUnsyncedIntakes(userId);
    return unsynced.isNotEmpty;
  }

  Future<void> syncPendingLogs(String userId) async {
    try {
      final unsyncedLogs = await _localDb.getUnsyncedIntakes(userId);
      for (var log in unsyncedLogs) {
        final response = await _supabaseService.client
            .from('intake_logs')
            .insert(log.toJson())
            .select()
            .single();

        final newSupabaseId = response['id'] as String;
        if (log.localId != null) {
          await _localDb.markAsSynced(log.localId!, newSupabaseId);
        }
      }
    } catch (e) {
      print("Sync failed: $e");
      rethrow;
    }
  }

  Future<void> resetTodayIntake(String userId) async {
    try {
      await _localDb.deleteTodayIntakes(userId);
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      await _supabaseService.client
          .from('intake_logs')
          .delete()
          .eq('user_id', userId)
          .gte('timestamp', startOfDay)
          .lte('timestamp', endOfDay);
    } catch (e) {
      print("Remote delete failed (likely offline): $e");
    }
  }
}