import '../../../core/services/supabase_service.dart';

class ProfileRepository {
  final SupabaseService _supabaseService;

  ProfileRepository(this._supabaseService);

  Future<dynamic> getProfile() async {
    return null;
  }

  Future<void> saveProfile(dynamic profile) async {}
}
