import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/profile_repository.dart';
import '../data/profile_model.dart';
import 'profile_state.dart';

// FIX: This class must extend Cubit<ProfileState> to be used in BlocProvider
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(ProfileInitial());

  /// Load the user's profile from the repository
  Future<void> loadProfile(String userId) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getProfile(userId);
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileNotSet());
      }
    } catch (e) {
      emit(ProfileError("Failed to load profile: $e"));
    }
  }

  /// Save a new or updated profile
  Future<void> saveProfile(ProfileModel profile) async {
    emit(ProfileLoading());
    try {
      await _repository.saveProfile(profile);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError("Failed to save profile: $e"));
    }
  }
}
