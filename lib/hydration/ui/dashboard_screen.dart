import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // You might need to add intl to pubspec.yaml for time formatting
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../cubit/hydration_cubit.dart';
import '../cubit/hydration_state.dart';
import '../data/intake_model.dart';
import '../../core/services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _customIntakeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupNotifications();
  }

  @override
  void dispose() {
    _customIntakeController.dispose();
    super.dispose();
  }

  void _setupNotifications() async {
    await _notificationService.initialize();
    _notificationService.schedulePeriodicWaterReminder();
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

  // --- Custom Entry Dialog ---
  void _showCustomEntryDialog(BuildContext context, String userId) {
    _customIntakeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Custom Amount"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.water_drop, size: 40, color: Colors.blue),
            const SizedBox(height: 16),
            TextField(
              controller: _customIntakeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "0",
                suffixText: "ml",
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(_customIntakeController.text);
              if (amount != null && amount > 0) {
                context.read<HydrationCubit>().logIntake(userId, amount);
                Navigator.pop(context);
              }
            },
            child: const Text("Add Water"),
          ),
        ],
      ),
    );
  }

  // --- HISTORY BOTTOM SHEET ---
  void _showHistorySheet(BuildContext context, List<IntakeModel> history) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allow it to expand
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Today's History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: history.isEmpty
                        ? Center(
                            child: Text("No logs yet today.",
                                style: TextStyle(color: Colors.grey.shade500)),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: history.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final item = history[index];
                              // Simple date formatting
                              final timeStr = DateFormat('h:mm a').format(item.timestamp);
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.local_drink,
                                      color: Colors.blue, size: 20),
                                ),
                                title: Text("${item.amountMl} ml",
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(timeStr),
                                trailing: item.isSynced
                                    ? const Icon(Icons.cloud_done, size: 16, color: Colors.green)
                                    : const Icon(Icons.cloud_upload, size: 16, color: Colors.orange),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              "HydroBuddy",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          BlocBuilder<HydrationCubit, HydrationState>(
            builder: (context, state) {
              if (state is HydrationLoaded) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: state.hasUnsyncedData
                          ? Colors.orange.shade50
                          : Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      state.hasUnsyncedData ? Icons.cloud_upload : Icons.cloud_done,
                      color: state.hasUnsyncedData ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
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
              return RefreshIndicator(
                onRefresh: () async {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    await context.read<HydrationCubit>().syncData(authState.userId);
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: _buildDashboardContent(context, profileState.profile.dailyGoal),
                ),
              );
            } else if (profileState is ProfileError) {
              return Center(child: Text("Error: ${profileState.message}"));
            }
            return const Center(child: Text("Initializing..."));
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, int dailyGoal) {
    final theme = Theme.of(context);

    return BlocBuilder<HydrationCubit, HydrationState>(
      builder: (context, hydrationState) {
        int currentIntake = 0;
        List<IntakeModel> history = [];
        
        if (hydrationState is HydrationLoaded) {
          currentIntake = hydrationState.currentIntake;
          history = hydrationState.history;
        }
        
        double progress = (currentIntake / dailyGoal).clamp(0.0, 1.0);
        int percentage = (progress * 100).toInt();

        final userId = context.read<AuthCubit>().state is AuthAuthenticated
            ? (context.read<AuthCubit>().state as AuthAuthenticated).userId
            : '';

        return Column(
          children: [
            // --- 1. Large Circular Tracker (Now Clickable) ---
            GestureDetector(
              onTap: () => _showHistorySheet(context, history),
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 250,
                      width: 250,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 20,
                        color: Colors.grey.shade100,
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      width: 250,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 20,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        color: theme.primaryColor,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop, size: 40, color: theme.primaryColor),
                        const SizedBox(height: 8),
                        Text(
                          "$percentage%",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(
                          "$currentIntake / $dailyGoal ml",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Visual cue that it's clickable
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: const Text("Tap for History", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- 2. Custom Add Button (+) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showCustomEntryDialog(context, userId),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Add Water",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- 3. Quick Add Buttons (Below) ---
            const Text(
              "Quick Add",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _WaterButton(
                  amount: 250, 
                  label: "Cup", 
                  icon: Icons.local_cafe_outlined,
                  onTap: () => context.read<HydrationCubit>().logIntake(userId, 250),
                ),
                const SizedBox(width: 20),
                _WaterButton(
                  amount: 500, 
                  label: "Bottle", 
                  icon: Icons.local_drink_outlined,
                  onTap: () => context.read<HydrationCubit>().logIntake(userId, 500),
                ),
                const SizedBox(width: 20),
                _WaterButton(
                  amount: 750, 
                  label: "Jug", 
                  icon: Icons.water_drop_outlined,
                  onTap: () => context.read<HydrationCubit>().logIntake(userId, 750),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _WaterButton extends StatelessWidget {
  final int amount;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _WaterButton({
    required this.amount, 
    required this.label, 
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue.shade300, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text("$amount ml", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}