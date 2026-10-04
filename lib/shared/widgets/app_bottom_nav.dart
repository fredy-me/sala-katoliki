import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  });

  // 5.4: supplied by the caller from the `StatefulNavigationShell` rather than
  // inferred from the current path. See `AppShell`.
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;
  final List<AppBottomNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        Theme.of(context).dividerTheme.color ??
        Theme.of(context).colorScheme.outlineVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: NavigationBar(
        maintainBottomViewPadding: true,
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onDestinationSelected: onDestinationSelected,
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
