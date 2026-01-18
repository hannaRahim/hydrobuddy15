import 'package:flutter/material.dart';
import 'core/services/supabase_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  final supabaseService = SupabaseService();
  
  try {
    await supabaseService.initialize();
    debugPrint("Supabase Initialized Successfully");
  } catch (e) {
    debugPrint("CRITICAL ERROR: Supabase failed to initialize: $e");
  }

  // 2. Run App (Always start at '/')
  // We let the SplashScreen (at '/') decide where to go next.
  runApp(
    HydroBuddyApp(
      supabaseService: supabaseService,
      initialRoute: '/', 
    ),
  );
}