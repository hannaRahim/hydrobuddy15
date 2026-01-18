import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/supabase_service.dart';
import 'auth/cubit/auth_cubit.dart';
import 'profile/cubit/profile_cubit.dart';
import 'profile/data/profile_repository.dart';
import 'hydration/cubit/hydration_cubit.dart';
import 'hydration/data/hydration_repository.dart';
import 'auth/ui/splash_screen.dart';
import 'auth/ui/login_screen.dart';
import 'auth/ui/signup_screen.dart';
import 'hydration/ui/dashboard_screen.dart';
import 'profile/ui/profile_setup_screen.dart';
import 'settings/ui/settings_screen.dart';

void main() async {
  // Ensure Flutter framework is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase Service
  final supabaseService = SupabaseService();
  
  try {
    await supabaseService.initialize();
    debugPrint("Supabase Initialized Successfully");
  } catch (e) {
    debugPrint("CRITICAL ERROR: Supabase failed to initialize: $e");
    // You could potentially show a "No Internet" screen here if initialization fails
  }

  // 2. Initialize Repositories
  final profileRepo = ProfileRepository(supabaseService);
  final hydrationRepo = HydrationRepository(supabaseService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(supabaseService)),
        BlocProvider(create: (_) => ProfileCubit(profileRepo)),
        BlocProvider(create: (_) => HydrationCubit(hydrationRepo)),
      ],
      child: const HydroBuddyApp(),
    ),
  );
}

class HydroBuddyApp extends StatelessWidget {
  const HydroBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydro Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Always start at Splash
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileSetupScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}