import 'package:flutter/material.dart';
import 'core/services/supabase_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase Service
  // This creates the single instance we will pass around the app
  final supabaseService = SupabaseService();
  await supabaseService.initialize();

  // 2. Auth Guard Logic
  // We check if a user session already exists before the app starts UI.
  String initialRoute = '/';

  // Note: Since supabaseService.client might be null in your current placeholder,
  // we add a safety check. In production, 'client' should be the SupabaseClient.
  try {
    final currentUser = supabaseService.client?.auth.currentUser;
    if (currentUser != null) {
      // User is already logged in, skip login screen
      // Ideally, check here if they have a profile, if not -> '/profile'
      initialRoute = '/dashboard';
    }
  } catch (e) {
    // If Supabase isn't configured, default to Login
    debugPrint("Auth check failed: $e");
  }

  // 3. Run App
  runApp(
    HydroBuddyApp(supabaseService: supabaseService, initialRoute: initialRoute),
  );
}
