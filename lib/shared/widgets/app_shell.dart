import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/localization_providers.dart';
import 'app_bottom_nav.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _exitWindow = Duration(seconds: 2);

  DateTime? _lastExitRequestAt;

  @override
  Widget build(BuildContext context) {
    final strings = _BottomNavStrings(ref.watch(activeLanguageProvider));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        _handleBack(strings.exitPrompt);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: NavigatorPopHandler(child: widget.child),
        ),
        bottomNavigationBar: AppBottomNav(
          location: widget.location,
          destinations: [
            AppBottomNavDestination(
              '/today',
              strings.today,
              Icons.home_outlined,
            ),
            AppBottomNavDestination(
              '/prayers',
              strings.pray,
              Icons.menu_book_outlined,
            ),
            AppBottomNavDestination(
              '/novenas',
              strings.novenas,
              Icons.calendar_month_outlined,
            ),
            AppBottomNavDestination(
              '/settings',
              strings.settings,
              Icons.settings_outlined,
            ),
          ],
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

class _BottomNavStrings {
  const _BottomNavStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get today => _sw ? 'Leo' : 'Today';
  String get pray => _sw ? 'Sala' : 'Pray';
  String get novenas => _sw ? 'Novenas' : 'Novenas';
  String get settings => _sw ? 'Mipangilio' : 'Settings';
  String get exitPrompt => _sw
      ? 'Bonyeza tena kufunga Sala Katoliki.'
      : 'Press back again to close Sala Katoliki.';
}
