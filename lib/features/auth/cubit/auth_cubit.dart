import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/supabase_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SupabaseService _supabaseService;

  AuthCubit(this._supabaseService) : super(AuthInitial());

  /// Check if a user is already logged in (Persistent Session)
  Future<void> checkSession() async {
    try {
      final user = _supabaseService.client?.auth.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user.id));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // If something breaks, assume logged out
      emit(AuthUnauthenticated());
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      // Simulate network delay for better UX feel
      await Future.delayed(const Duration(seconds: 1));

      // REAL LOGIN LOGIC:
      // final response = await _supabaseService.client.auth.signInWithPassword(email: email, password: password);
      // if (response.user != null) ...

      // For prototype, we use a fixed ID
      emit(const AuthAuthenticated('dummy_user_id_123'));
    } catch (e) {
      emit(AuthError("Login failed: ${e.toString()}"));
    }
  }

  Future<void> logout() async {
    await _supabaseService.client?.auth.signOut();
    emit(AuthUnauthenticated());
  }
}
