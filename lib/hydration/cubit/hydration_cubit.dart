import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hydration_repository.dart';
import 'hydration_state.dart';

class HydrationCubit extends Cubit<HydrationState> {
  final HydrationRepository _hydrationRepository;

  HydrationCubit(this._hydrationRepository) : super(HydrationInitial());

  /// Loads the total intake for the specific user for today
  Future<void> loadDailyIntake(String userId) async {
    emit(HydrationLoading());
    try {
      final total = await _hydrationRepository.getTodayTotalIntake(userId);
      emit(HydrationLoaded(total));
    } catch (e) {
      emit(HydrationError("Failed to load intake: $e"));
    }
  }

  /// Logs a specific amount of water and refreshes the state
  Future<void> logIntake(String userId, int amountMl) async {
    try {
      // 1. Send data to repository
      await _hydrationRepository.logIntake(userId, amountMl);

      // 2. Reload total to ensure consistency with DB
      await loadDailyIntake(userId);
    } catch (e) {
      emit(HydrationError("Failed to log water: $e"));
    }
  }

  /// Resets the daily counter
  Future<void> resetIntake(String userId) async {
    try {
      await _hydrationRepository.resetTodayIntake(userId);
      emit(const HydrationLoaded(0));
    } catch (e) {
      emit(HydrationError("Failed to reset intake: $e"));
    }
  }
}
