import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Mipangilio',
      subtitle:
          'Lugha, mandhari, vikumbusho, ukubwa wa maandishi, na taarifa za programu.',
      icon: Icons.settings_outlined,
      primaryActionLabel: 'Badili lugha',
    );
  }
}
