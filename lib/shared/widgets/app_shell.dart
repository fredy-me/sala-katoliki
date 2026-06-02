import 'package:flutter/material.dart';

import 'app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _destinations = [
    AppBottomNavDestination('/today', 'Today', Icons.home_outlined),
    AppBottomNavDestination('/prayers', 'Pray', Icons.menu_book_outlined),
    AppBottomNavDestination(
      '/novenas',
      'Novenas',
      Icons.calendar_month_outlined,
    ),
    AppBottomNavDestination('/library', 'Library', Icons.auto_stories_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: AppBottomNav(
        location: location,
        destinations: _destinations,
      ),
    );
  }
}
