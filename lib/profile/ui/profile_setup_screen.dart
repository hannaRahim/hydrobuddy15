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
  // Controllers
  final TextEditingController _goalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Dropdown Values
  String _selectedAge = HydrationRules.ageRanges[0];
  String _selectedWeight = HydrationRules.weightRanges[1];
  String _selectedActivity = HydrationRules.activityLevels[1];
  String _selectedHealth = HydrationRules.healthConditions[0];

  // Track if user has manually edited the goal to prevent auto-overwriting
  bool _isManualGoal = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  /// Check if we already have profile data (e.g. coming from Settings -> Edit)
  void _loadExistingProfile() {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      final p = profileState.profile;
      setState(() {
        // Safely set dropdowns (checking if value exists in current rules list)
        if (HydrationRules.ageRanges.contains(p.ageRange)) _selectedAge = p.ageRange;
        if (HydrationRules.weightRanges.contains(p.weightRange)) _selectedWeight = p.weightRange;
        if (HydrationRules.activityLevels.contains(p.activityLevel)) _selectedActivity = p.activityLevel;
        if (HydrationRules.healthConditions.contains(p.healthCondition)) _selectedHealth = p.healthCondition;
        
        // Set the goal text
        _goalController.text = p.dailyGoal.toString();
        // Assume if they are editing, they might want to keep the current number initially
        _isManualGoal = true; 
      });
    } else {
      // If new user, calculate initial default
      _recalculateGoal();
    }
  }

  /// Recalculates goal based on dropdowns, unless user manually edited the field
  void _recalculateGoal() {
    if (_isManualGoal) return; // Don't overwrite if user is typing manually

    final calculated = HydrationRules.getDailyGoal(
      ageRange: _selectedAge,
      weightRange: _selectedWeight,
      activityLevel: _selectedActivity,
      healthCondition: _selectedHealth,
    );

    _goalController.text = calculated.toString();
  }

  /// Force recalculation (e.g. if user hits a "Reset" button)
  void _resetToRecommended() {
    setState(() {
      _isManualGoal = false;
      _recalculateGoal();
    });
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No user logged in")),
      );
      return;
    }

    // Parse the goal from the text field (User Customization)
    final finalGoal = int.tryParse(_goalController.text) ?? 2000;

    final profile = ProfileModel(
      userId: authState.userId,
      ageRange: _selectedAge,
      weightRange: _selectedWeight,
      activityLevel: _selectedActivity,
      healthCondition: _selectedHealth,
      dailyGoal: finalGoal, // Use the value from the input field
    );

    context.read<ProfileCubit>().saveProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personalize Plan")),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.tune, size: 60, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text(
                  "Customize Your Goals",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Adjust your profile details below to get a recommended water intake, or set your own goal manually.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
            
                // --- Dropdowns Card ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Profile Details", 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        
                        _buildDropdown("Age Range", HydrationRules.ageRanges, _selectedAge, Icons.cake_outlined, (val) {
                          setState(() {
                            _selectedAge = val!;
                            _isManualGoal = false; // Reset manual flag to allow auto-calc
                            _recalculateGoal();
                          });
                        }),
                        const SizedBox(height: 16),
                        
                        _buildDropdown("Weight Range", HydrationRules.weightRanges, _selectedWeight, Icons.monitor_weight_outlined, (val) {
                          setState(() {
                            _selectedWeight = val!;
                            _isManualGoal = false;
                            _recalculateGoal();
                          });
                        }),
                        const SizedBox(height: 16),
                        
                        _buildDropdown("Activity Level", HydrationRules.activityLevels, _selectedActivity, Icons.directions_run, (val) {
                          setState(() {
                            _selectedActivity = val!;
                            _isManualGoal = false;
                            _recalculateGoal();
                          });
                        }),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedHealth,
                          items: HydrationRules.healthConditions.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedHealth = val!;
                              _isManualGoal = false;
                              _recalculateGoal();
                            });
                          },
                          decoration: const InputDecoration(labelText: "Health Condition", prefixIcon: Icon(Icons.medical_services_outlined)),
                        ),
                      ],
                    ),
                  ),
                ),
            
                const SizedBox(height: 24),
            
                // --- Goal Edit Card ---
                Card(
                  color: Colors.blue.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Daily Goal (ml)", 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                            if (_isManualGoal)
                              GestureDetector(
                                onTap: _resetToRecommended,
                                child: const Text("Reset to Auto", 
                                    style: TextStyle(fontSize: 12, color: Colors.blue, decoration: TextDecoration.underline)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _goalController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            suffixText: "ml",
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onChanged: (val) {
                            // If user types, we mark as manual so dropdowns don't overwrite it immediately
                            setState(() => _isManualGoal = true);
                          },
                          validator: (value) {
                            final n = int.tryParse(value ?? '');
                            if (n == null || n < 500 || n > 10000) {
                              return "Please enter a valid amount (500-10000)";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "You can manually edit this goal if you have specific requirements.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
            
                const SizedBox(height: 32),
            
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoading) {
                      return const CircularProgressIndicator();
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSavePressed,
                        child: const Text("Save Plan"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String currentValue, IconData icon, ValueChanged<String?> onChanged) {
    final value = items.contains(currentValue) ? currentValue : items[0];
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}