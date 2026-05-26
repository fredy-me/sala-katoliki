import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _destinations = [
    _ShellDestination('/home', 'Nyumbani', Icons.home_outlined),
    _ShellDestination('/prayers', 'Sala', Icons.menu_book_outlined),
    _ShellDestination('/rosary', 'Rozari', Icons.auto_awesome_outlined),
    _ShellDestination('/readings', 'Masomo', Icons.favorite_border),
    _ShellDestination('/settings', 'Mipangilio', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _destinations.indexWhere(
      (destination) => location == destination.path,
    );

    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onDestinationSelected: (index) {
          context.go(_destinations[index].path);
        },
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}
