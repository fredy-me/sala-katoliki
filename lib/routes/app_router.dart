import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/localization_providers.dart';
import '../features/novenas/presentation/screens/novena_day_screen.dart';
import '../features/novenas/presentation/screens/novena_closing_prayer_screen.dart';
import '../features/novenas/presentation/screens/novena_detail_screen.dart';
import '../features/novenas/presentation/screens/novena_thanksgiving_screen.dart';
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
import '../shared/widgets/app_loading.dart';

final appInitialLocationProvider = Provider<String>((ref) => '/startup');

final appRouterProvider = Provider<GoRouter>((ref) {
  late final GoRouter router;
  String? pendingOnboardingRedirect;

  router = GoRouter(
    initialLocation: ref.read(appInitialLocationProvider),
    redirect: (context, state) {
      final languageState = ref.read(selectedLanguageProvider);
      final path = state.uri.path;
      final location = state.uri.toString();
      final from = _validRedirectPath(state.uri.queryParameters['from']);

      if (languageState.isLoading) {
        if (path == '/startup') {
          return null;
        }
        final target = _validRedirectPath(from ?? location);
        pendingOnboardingRedirect = target ?? pendingOnboardingRedirect;
        return _withFrom('/startup', target ?? '/today');
      }

      final hasLanguage = languageState.asData?.value != null;
      if (!hasLanguage) {
        if (path == '/onboarding') {
          return null;
        }
        final target = _validRedirectPath(from ?? location) ?? '/today';
        pendingOnboardingRedirect = target;
        return _withFrom('/onboarding', target);
      }

      if (path == '/startup' || path == '/onboarding') {
        final target = from ?? pendingOnboardingRedirect ?? '/today';
        pendingOnboardingRedirect = null;
        return target;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/startup',
        builder: (context, state) => const AppLoading(label: 'Sala Katoliki'),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // 5.4. `ShellRoute` gave each navigation a single child widget, so a tab
      // switch destroyed the outgoing branch and rebuilt the incoming one —
      // losing scroll position on the Today/Prayers/Novenas lists.
      // `StatefulShellRoute.indexedStack` keeps one Navigator per branch and
      // only swaps which one is visible, so each tab keeps its own stack and
      // scroll offset. This is the one intentional behaviour change in Part 5
      // and it needs release-note wording.
      //
      // Note the trade-off this introduces, which the plan did not call out:
      // an IndexedStack builds every branch eagerly, so all four tab screens
      // now build at startup instead of only `/today`. That works against the
      // 5.1/5.2/5.3 work in this same part, and is measured in the Part 5
      // status table rather than assumed away.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prayers',
                builder: (context, state) => const PrayerLibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/novenas',
                builder: (context, state) => const NovenasScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: '/library',
                redirect: (context, state) => '/settings',
              ),
            ],
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
        path: '/novenas/:novenaId/thanksgiving',
        builder: (context, state) {
          return NovenaThanksgivingScreen(
            novenaId: state.pathParameters['novenaId']!,
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

  ref.listen(selectedLanguageProvider, (previous, next) {
    router.refresh();
  });
  ref.onDispose(router.dispose);

  return router;
});

String _withFrom(String path, String from) {
  final redirectPath = _validRedirectPath(from) ?? '/today';
  return Uri(path: path, queryParameters: {'from': redirectPath}).toString();
}

String? _validRedirectPath(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(value);
  if (uri == null || uri.hasScheme || uri.hasAuthority || uri.path.isEmpty) {
    return null;
  }
  if (!uri.path.startsWith('/') ||
      uri.path == '/startup' ||
      uri.path == '/onboarding') {
    return null;
  }

  return uri.toString();
}
