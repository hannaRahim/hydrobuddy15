import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
// Import your NotificationService if you want to call it directly here
// import '../../core/services/notification_service.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // In a real app, load this value from SharedPreferences
  bool _remindersEnabled = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("My Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Profile Summary Card
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoaded) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.blue),
                      ),
                      title: Text("Goal: ${state.profile.dailyGoal} ml", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Activity: ${state.profile.activityLevel}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ),
                  );
                }
                return const Card(child: ListTile(title: Text("Loading Profile...")));
              },
            ),

            const SizedBox(height: 30),
            const Text("Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),

            // --- NEW: Scheduled Reminder Section ---
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active, color: Colors.orange),
              ),
              title: const Text("Hydration Reminders"),
              subtitle: const Text("Get notified to drink water"),
              value: _remindersEnabled,
              onChanged: (bool value) {
                setState(() {
                  _remindersEnabled = value;
                });
                // TODO: Call your NotificationService here
                // if (value) {
                //   NotificationService().schedulePeriodicWaterReminder();
                // } else {
                //   NotificationService().cancelNotifications();
                // }
              },
            ),

            const SizedBox(height: 30),
            const Text("Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}