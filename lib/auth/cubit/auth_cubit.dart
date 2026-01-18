import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import '../../core/services/supabase_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SupabaseService _supabaseService;

  AuthCubit(this._supabaseService) : super(AuthInitial());

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

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        emit(AuthAuthenticated(response.user!.id));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError("Login failed: $e"));
    }
  }

  // New: Dedicated Sign Up Method
  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        // Note: Check if email confirmation is enabled in your Supabase dashboard. 
        // If enabled, the user won't be logged in immediately.
        emit(AuthAuthenticated(response.user!.id));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError("Sign up failed: $e"));
    }
  }

  Future<void> logout() async {
    await _supabaseService.client.auth.signOut();
    emit(AuthUnauthenticated());
  }
}