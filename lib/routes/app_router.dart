import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/novenas/presentation/screens/novena_day_screen.dart';
import '../features/novenas/presentation/screens/novena_closing_prayer_screen.dart';
import '../features/novenas/presentation/screens/novena_detail_screen.dart';
import '../features/library/presentation/screens/favorites_screen.dart';
import '../features/novenas/presentation/screens/novenas_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/prayers/presentation/screens/prayer_detail_screen.dart';
import '../features/prayers/presentation/screens/prayer_library_screen.dart';
import '../features/prayers/presentation/screens/prayer_list_screen.dart';
import '../features/rosary/presentation/screens/mystery_selection_screen.dart';
import '../features/rosary/presentation/screens/rosary_screen.dart';
import '../features/rosary/presentation/screens/rosary_step_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/today/presentation/screens/today_screen.dart';
import '../shared/widgets/app_shell.dart';

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
            path: '/today',
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: '/prayers',
            builder: (context, state) => const PrayerLibraryScreen(),
          ),
          GoRoute(
            path: '/novenas',
            builder: (context, state) => const NovenasScreen(),
          ),
          GoRoute(path: '/library', redirect: (context, state) => '/settings'),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/prayers/category/:categoryId',
        builder: (context, state) {
          return PrayerListScreen(
            categoryId: state.pathParameters['categoryId']!,
          );
        },
      ),
      GoRoute(
        path: '/prayers/:prayerId',
        builder: (context, state) {
          return PrayerDetailScreen(
            prayerId: state.pathParameters['prayerId']!,
          );
        },
      ),
      GoRoute(
        path: '/rosary',
        builder: (context, state) => const RosaryScreen(),
      ),
      GoRoute(
        path: '/rosary/select',
        builder: (context, state) => const MysterySelectionScreen(),
      ),
      GoRoute(
        path: '/rosary/step/:mysteryId',
        builder: (context, state) {
          return RosaryStepScreen(
            mysteryId: state.pathParameters['mysteryId']!,
          );
        },
      ),
      GoRoute(
        path: '/novenas/:novenaId',
        builder: (context, state) {
          return NovenaDetailScreen(
            novenaId: state.pathParameters['novenaId']!,
          );
        },
      ),
      GoRoute(
        path: '/novenas/:novenaId/day/:day',
        builder: (context, state) {
          return NovenaDayScreen(
            novenaId: state.pathParameters['novenaId']!,
            day: int.tryParse(state.pathParameters['day'] ?? '') ?? -1,
          );
        },
      ),
      GoRoute(
        path: '/novenas/:novenaId/closing-prayer',
        builder: (context, state) {
          return NovenaClosingPrayerScreen(
            novenaId: state.pathParameters['novenaId']!,
          );
        },
      ),
    ],
  );
});
