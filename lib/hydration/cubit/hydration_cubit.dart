import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hydration_repository.dart';
import 'hydration_state.dart';

class HydrationCubit extends Cubit<HydrationState> {
  final HydrationRepository _hydrationRepository;

  HydrationCubit(this._hydrationRepository) : super(HydrationInitial());

  Future<void> loadDailyIntake(String userId) async {
    emit(HydrationLoading());
    try {
      final total = await _hydrationRepository.getTodayTotalIntake(userId);
      final history = await _hydrationRepository.getTodayIntakes(userId); // --- Load History
      final hasUnsynced = await _hydrationRepository.hasUnsyncedData(userId);
      
      emit(HydrationLoaded(total, history, hasUnsyncedData: hasUnsynced));
    } catch (e) {
      emit(HydrationError("Failed to load intake: $e"));
    }
  }

  Future<void> logIntake(String userId, int amountMl) async {
    try {
      await _hydrationRepository.logIntake(userId, amountMl);
      await loadDailyIntake(userId); // Reloads both total and history
      syncData(userId);
    } catch (e) {
      emit(HydrationError("Failed to log water: $e"));
    }
  }
  
  Future<void> syncData(String userId) async {
    try {
      await _hydrationRepository.syncPendingLogs(userId);
      
      // Refresh state
      final total = await _hydrationRepository.getTodayTotalIntake(userId);
      final history = await _hydrationRepository.getTodayIntakes(userId); // --- Load History
      
      emit(HydrationLoaded(total, history, hasUnsyncedData: false));
    } catch (e) {
      final total = await _hydrationRepository.getTodayTotalIntake(userId);
      final history = await _hydrationRepository.getTodayIntakes(userId); // --- Load History
      emit(HydrationLoaded(total, history, hasUnsyncedData: true));
    }
  }

  Future<void> resetIntake(String userId) async {
    try {
      await _hydrationRepository.resetTodayIntake(userId);
      emit(const HydrationLoaded(0, [], hasUnsyncedData: false)); // Empty history
    } catch (e) {
      emit(HydrationError("Failed to reset intake: $e"));
    }
  }
}