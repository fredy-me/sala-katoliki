import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/feature_placeholder_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderScreen(
      title: 'Library',
      subtitle:
          'Favorites, search, offline content, settings, and app information.',
      icon: Icons.auto_stories_outlined,
      primaryActionLabel: 'Open settings',
      onPrimaryAction: () => context.go('/settings'),
    );
  }
}
