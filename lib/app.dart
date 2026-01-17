import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'app_router.dart';

// Repositories
import 'profile/data/profile_repository.dart';
import 'hydration/data/hydration_repository.dart';

// Cubits
import 'features/auth/cubit/auth_cubit.dart';
import 'profile/cubit/profile_cubit.dart';
import 'hydration/cubit/hydration_cubit.dart';

class HydroBuddyApp extends StatelessWidget {
  final SupabaseService supabaseService;
  final String initialRoute;

  const HydroBuddyApp({
    super.key,
    required this.supabaseService,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Initialize Repositories (The Data Layer)
    // We pass the service to them so they can talk to the database
    final profileRepository = ProfileRepository(supabaseService);
    final hydrationRepository = HydrationRepository(supabaseService);

    return MultiBlocProvider(
      // 2. Inject Cubits (The Logic Layer)
      // Now any screen in the app can say "context.read<HydrationCubit>()"
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(supabaseService),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepository),
        ),
        BlocProvider<HydrationCubit>(
          create: (context) => HydrationCubit(hydrationRepository),
        ),
      ],
      child: MaterialApp(
        title: 'HydroBuddy',
        theme: AppTheme.lightTheme,
        // 3. Use the initial route decided in main.dart
        initialRoute: initialRoute,
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
