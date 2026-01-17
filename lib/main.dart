import 'package:flutter/material.dart';
import 'core/services/supabase_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase Service FIRST
  final supabaseService = SupabaseService();

  try {
    // We MUST await this. If this fails, the app cannot start.
    await supabaseService.initialize();
    debugPrint("Supabase Initialized Successfully");
  } catch (e) {
    debugPrint("CRITICAL ERROR: Supabase failed to initialize: $e");
    // In a real app, you might show a fatal error screen here.
  }

  // 2. Auth Guard Logic
  String initialRoute = '/';

  try {
    // Now it is safe to access .client because we waited for initialize()
    final currentUser = supabaseService.client.auth.currentUser;
    if (currentUser != null) {
      initialRoute = '/dashboard';
    }
  } catch (e) {
    debugPrint("Auth check failed (User might be logged out): $e");
  }

  // 3. Run App
  runApp(
    HydroBuddyApp(supabaseService: supabaseService, initialRoute: initialRoute),
  );
}
