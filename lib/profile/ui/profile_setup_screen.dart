import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/hydration_rules.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../data/profile_model.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // Default Values based on your HydrationRules constants
  String _selectedAge = HydrationRules.ageRanges[0];
  String _selectedWeight = HydrationRules.weightRanges[1];
  String _selectedActivity = HydrationRules.activityLevels[1];
  String _selectedHealth = HydrationRules.healthConditions[0];

  void _onSavePressed() {
    // 1. Get the current User ID
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error: No user logged in")));
      return;
    }

    // 2. Calculate the Goal using your Logic Class
    final calculatedGoal = HydrationRules.getDailyGoal(
      ageRange: _selectedAge,
      weightRange: _selectedWeight,
      activityLevel: _selectedActivity,
      healthCondition: _selectedHealth,
    );

    // 3. Create the Model
    final profile = ProfileModel(
      userId: authState.userId,
      ageRange: _selectedAge,
      weightRange: _selectedWeight,
      activityLevel: _selectedActivity,
      healthCondition: _selectedHealth,
      dailyGoal: calculatedGoal,
    );

    // 4. Save via Cubit
    context.read<ProfileCubit>().saveProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            // If save success, go to Dashboard
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Let's personalize your hydration goal.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              _buildDropdown(
                "Age Range",
                HydrationRules.ageRanges,
                _selectedAge,
                (val) {
                  setState(() => _selectedAge = val!);
                },
              ),

              _buildDropdown(
                "Weight Range",
                HydrationRules.weightRanges,
                _selectedWeight,
                (val) {
                  setState(() => _selectedWeight = val!);
                },
              ),

              _buildDropdown(
                "Activity Level",
                HydrationRules.activityLevels,
                _selectedActivity,
                (val) {
                  setState(() => _selectedActivity = val!);
                },
              ),

              _buildDropdown(
                "Health Condition",
                HydrationRules.healthConditions,
                _selectedHealth,
                (val) {
                  setState(() => _selectedHealth = val!);
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onSavePressed,
                  child: const Text("Calculate & Save Goal"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String currentValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: currentValue,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
