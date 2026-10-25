import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/localization_providers.dart';
import 'app_bottom_nav.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  // 5.4: a `StatefulNavigationShell` instead of the `location` + `child` pair a
  // plain `ShellRoute` handed over. It carries the per-branch Navigators and
  // the active index, which is what makes a tab switch state-preserving.
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _exitWindow = Duration(seconds: 2);

  DateTime? _lastExitRequestAt;

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(activeLanguageProvider);
    // 5.7: the labels and the four destination objects depend only on the
    // language. They used to be rebuilt on every AppShell build — that is,
    // on every navigation — so switching tabs allocated four objects and a
    // list to produce values that never changed. Caching per language keeps
    // the rendered output identical and drops the allocation.
    final strings = AppStrings.of(languageCode);
    final destinations = _BottomNavDestinations.forStrings(strings);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        _handleBack(strings.bottomNavExitPrompt);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: NavigatorPopHandler(child: widget.navigationShell),
        ),
        bottomNavigationBar: AppBottomNav(
          // 5.4: the selected index now comes from the shell rather than being
          // inferred by matching the current path against the destination list.
          // Same value in every reachable state, but it stays correct if a
          // branch ever gains a nested route.
          selectedIndex: widget.navigationShell.currentIndex,
          // `goBranch` switches which branch Navigator is visible without
          // destroying the other branches, so each tab keeps its scroll
          // position and its own stack.
          //
          // `context.go` was tried here first and rejected: on a stateful shell
          // it replaces the shell's location and resets branch state, which
          // defeats the whole point of 5.4. Tapping the already-active tab
          // passes `initialLocation: true`, go_router's documented idiom for
          // popping that branch back to its root.
          onDestinationSelected: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
          destinations: destinations,
        ),
      ),
    );
  }

  void _handleBack(String exitPrompt) {
    final now = DateTime.now();
    final shouldExit =
        _lastExitRequestAt != null &&
        now.difference(_lastExitRequestAt!) <= _exitWindow;

    if (shouldExit) {
      SystemNavigator.pop();
      return;
    }

    _lastExitRequestAt = now;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(exitPrompt)));
  }
}

abstract final class _BottomNavDestinations {
  static final Map<String, List<AppBottomNavDestination>>
  _destinationsByLanguage = <String, List<AppBottomNavDestination>>{};

  static List<AppBottomNavDestination> forStrings(AppStrings strings) {
    return _destinationsByLanguage.putIfAbsent(strings.languageCode, () {
      return <AppBottomNavDestination>[
        AppBottomNavDestination(
          '/today',
          strings.bottomNavToday,
          Icons.home_outlined,
        ),
        AppBottomNavDestination(
          '/prayers',
          strings.bottomNavPray,
          Icons.menu_book_outlined,
        ),
        AppBottomNavDestination(
          '/novenas',
          strings.bottomNavNovenas,
          Icons.calendar_month_outlined,
        ),
        AppBottomNavDestination(
          '/settings',
          strings.bottomNavSettings,
          Icons.settings_outlined,
        ),
      ];
    });
  }
}
