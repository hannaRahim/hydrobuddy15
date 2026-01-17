import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import '../../../core/services/supabase_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SupabaseService _supabaseService;

  AuthCubit(this._supabaseService) : super(AuthInitial());

  /// Check if a user is already logged in (Persistent Session)
  Future<void> checkSession() async {
    try {
      final session = _supabaseService.client.auth.currentSession;
      if (session != null && session.user.id.isNotEmpty) {
        emit(AuthAuthenticated(session.user.id));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Login with email and password
  /// Note: For this prototype, if Login fails, we try to Sign Up automatically.
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      // 1. Try to Login
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        emit(AuthAuthenticated(response.user!.id));
      }
    } on AuthException catch (loginError) {
      // 2. If Login fails (likely user doesn't exist), Try to Sign Up
      try {
        final response = await _supabaseService.client.auth.signUp(
          email: email,
          password: password,
        );
        if (response.user != null) {
          emit(AuthAuthenticated(response.user!.id));
        }
      } catch (signUpError) {
        // If both fail, show the original login error
        emit(AuthError(loginError.message));
      }
    } catch (e) {
      emit(AuthError("An unexpected error occurred: $e"));
    }
  }

  Future<void> logout() async {
    await _supabaseService.client.auth.signOut();
    emit(AuthUnauthenticated());
  }
}
