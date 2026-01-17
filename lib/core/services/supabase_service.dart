import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Your Project Credentials
  static const String _url = 'https://qllhdgmrinuekrmqozzp.supabase.co';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsbGhkZ21yaW51ZWtybXFvenpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2MDEyOTQsImV4cCI6MjA4MDE3NzI5NH0.kAY2QCtg5cohjEDG91jiXAuMK-otAv1rJ-A5ccCeedM';

  Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  // Getter to access the client anywhere in the app
  // This will throw an error if accessed before initialize() is done.
  SupabaseClient get client => Supabase.instance.client;
}
