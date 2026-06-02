import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.location,
    required this.destinations,
    super.key,
  });

  final String location;
  final List<AppBottomNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = destinations.indexWhere(
      (destination) => location == destination.path,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onDestinationSelected: (index) {
          context.go(destinations[index].path);
        },
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class AppBottomNavDestination {
  const AppBottomNavDestination(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}
