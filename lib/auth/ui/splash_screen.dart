import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // TRIGGER: Check if user exists as soon as this screen loads
    context.read<AuthCubit>().checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Success -> Go to Dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (state is AuthUnauthenticated) {
          // No User -> Go to Login
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: const Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use a white logo and spinner for a clean look
              Icon(Icons.water_drop, size: 80, color: Colors.white),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}