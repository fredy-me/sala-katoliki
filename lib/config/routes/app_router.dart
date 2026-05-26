import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/prayer_library/presentation/screens/prayer_library_screen.dart';
import '../../features/readings/presentation/screens/readings_screen.dart';
import '../../features/rosary/presentation/screens/rosary_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shared/presentation/widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/prayers',
            builder: (context, state) => const PrayerLibraryScreen(),
          ),
          GoRoute(
            path: '/rosary',
            builder: (context, state) => const RosaryScreen(),
          ),
          GoRoute(
            path: '/readings',
            builder: (context, state) => const ReadingsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
