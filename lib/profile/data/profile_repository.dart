import '../../../core/services/supabase_service.dart';
import 'profile_model.dart';

class ProfileRepository {
  final SupabaseService _supabaseService;

  ProfileRepository(this._supabaseService);

  /// Fetch profile from Supabase
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle(); // Returns null if no row found

      if (response == null) return null;

      return ProfileModel.fromJson(response);
    } catch (e) {
      // In a real app, log this error
      return null;
    }
  }

  /// Save or Update profile to Supabase
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      await _supabaseService.client
          .from('profiles')
          .upsert(profile.toJson()); // Upsert handles both Insert and Update
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }
}
