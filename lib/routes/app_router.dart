import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/library/presentation/screens/favorites_screen.dart';
import '../features/library/presentation/screens/library_screen.dart';
import '../features/novenas/presentation/screens/novenas_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/prayers/presentation/screens/prayer_detail_screen.dart';
import '../features/prayers/presentation/screens/prayer_library_screen.dart';
import '../features/prayers/presentation/screens/prayer_list_screen.dart';
import '../features/rosary/presentation/screens/rosary_screen.dart';
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
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
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
    ],
  );
});
