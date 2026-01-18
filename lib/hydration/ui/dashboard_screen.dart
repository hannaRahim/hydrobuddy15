// ... existing imports ...
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../cubit/hydration_cubit.dart';
import '../cubit/hydration_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ... existing initState and _initializeData ...
  // (Keep them exactly as they were in your uploaded file)
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is! AuthAuthenticated) {
      await authCubit.checkSession();
    }
    final state = authCubit.state;
    if (state is AuthAuthenticated) {
      if (mounted) {
        context.read<ProfileCubit>().loadProfile(state.userId);
        context.read<HydrationCubit>().loadDailyIntake(state.userId);
      }
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          // CHANGED: Settings Icon replaces Logout Icon
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      // ... keep the rest of your body code (MultiBlocListener etc) ...
      body: MultiBlocListener(
        listeners: [
           BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileNotSet) {
                Navigator.pushReplacementNamed(context, '/profile');
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (profileState is ProfileLoaded) {
              return _buildDashboardContent(context, profileState.profile.dailyGoal);
            } else if (profileState is ProfileError) {
              return Center(child: Text("Error: ${profileState.message}"));
            }
            return const Center(child: Text("Initializing..."));
          },
        ),
      ),
    );
  }

  // ... keep _buildDashboardContent and _WaterButton exactly as provided ...
  Widget _buildDashboardContent(BuildContext context, int dailyGoal) {
      // (Use the code you provided in your upload)
      // I am omitting it here for brevity, but make sure to include it!
      return BlocBuilder<HydrationCubit, HydrationState>(
      builder: (context, hydrationState) {
        int currentIntake = 0;
        if (hydrationState is HydrationLoaded) {
          currentIntake = hydrationState.currentIntake;
        }
        double progress = (currentIntake / dailyGoal).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text("Today's Hydration", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text("$currentIntake / $dailyGoal ml", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(value: progress, minHeight: 15, backgroundColor: Colors.white, borderRadius: BorderRadius.circular(10)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text("Quick Add", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _WaterButton(amount: 250, label: "Small Cup\n(250ml)"),
                  _WaterButton(amount: 500, label: "Bottle\n(500ml)"),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _WaterButton(amount: 750, label: "Large Bottle\n(750ml)"),
              ]),
            ],
          ),
        );
      },
    );
  }
}

class _WaterButton extends StatelessWidget {
  final int amount;
  final String label;
  const _WaterButton({required this.amount, required this.label});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final userId = context.read<AuthCubit>().state is AuthAuthenticated
            ? (context.read<AuthCubit>().state as AuthAuthenticated).userId
            : 'dummy_user_id_123';
        context.read<HydrationCubit>().logIntake(userId, amount);
      },
      child: Container(
        width: 120, height: 120,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))], border: Border.all(color: Colors.blue.withOpacity(0.2))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.local_drink, color: Colors.blue, size: 30),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }
}