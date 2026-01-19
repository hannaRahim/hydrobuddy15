import 'package:flutter/material.dart';

import '../auth/ui/login_screen.dart';
import '../auth/ui/signup_screen.dart';
import '../auth/ui/splash_screen.dart';
import '../auth/ui/onboarding_screen.dart'; // <--- Import this
import '../settings/ui/settings_screen.dart';
import '../profile/ui/profile_setup_screen.dart';
import '../hydration/ui/dashboard_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/onboarding': // <--- Add this case
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}