import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // FIX: Navigate directly to /login.
            // Navigating to '/' (Splash) would cause a loop/hang because the 
            // state is already Unauthenticated, so the Splash listener wouldn't fire.
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Text("My Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            // Profile Card
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoaded) {
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 28),
                      ),
                      title: Text("${state.profile.dailyGoal} ml", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      subtitle: Text("Daily Goal • ${state.profile.activityLevel}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  );
                }
                return const Card(child: Padding(padding: EdgeInsets.all(20), child: Text("Loading Profile...")));
              },
            ),

            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Text("Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            // Settings Group
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(Icons.notifications_active_outlined, color: Colors.orange.shade400),
                    title: const Text("Hydration Reminders"),
                    subtitle: const Text("Get notified to drink water"),
                    value: _remindersEnabled,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (bool value) {
                      setState(() {
                        _remindersEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Text("Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            Card(
              clipBehavior: Clip.hardEdge,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: () {
                  context.read<AuthCubit>().logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}