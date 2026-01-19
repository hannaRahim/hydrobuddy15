import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart'; // <--- IMPORT THIS
import 'auth/cubit/auth_cubit.dart';
import 'profile/cubit/profile_cubit.dart';
import 'profile/data/profile_repository.dart';
import 'hydration/cubit/hydration_cubit.dart';
import 'hydration/data/hydration_repository.dart';
import 'auth/ui/splash_screen.dart';
import 'auth/ui/login_screen.dart';
import 'auth/ui/signup_screen.dart';
import 'auth/ui/onboarding_screen.dart';
import 'hydration/ui/dashboard_screen.dart';
import 'profile/ui/profile_setup_screen.dart';
import 'settings/ui/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseService = SupabaseService();
  
  try {
    await supabaseService.initialize();
  } catch (e) {
    debugPrint("Supabase failed to initialize: $e");
  }

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
      
      // --- FIX: Use your custom light blue theme here ---
      theme: AppTheme.lightTheme, 
      // -------------------------------------------------

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileSetupScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}