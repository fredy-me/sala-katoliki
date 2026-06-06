import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/localization_providers.dart';
import 'app_bottom_nav.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = _BottomNavStrings(ref.watch(activeLanguageProvider));

    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: AppBottomNav(
        location: location,
        destinations: [
          AppBottomNavDestination('/today', strings.today, Icons.home_outlined),
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
            '/library',
            strings.library,
            Icons.auto_stories_outlined,
          ),
        ],
      ),
    );
  }
}

class _BottomNavStrings {
  const _BottomNavStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get today => _sw ? 'Leo' : 'Today';
  String get pray => _sw ? 'Sala' : 'Pray';
  String get novenas => _sw ? 'Novenas' : 'Novenas';
  String get library => _sw ? 'Maktaba' : 'Library';
}
