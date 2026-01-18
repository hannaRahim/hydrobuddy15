import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // When logout happens, remove all history and go to Splash
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
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text("Goal: ${state.profile.dailyGoal} ml"),
                      subtitle: Text("Activity: ${state.profile.activityLevel}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Let user re-do assessment
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
            const Text("Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
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