import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/feature_placeholder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Mipangilio',
      subtitle: 'Lugha, mandhari, vikumbusho, na akaunti ya majaribio.',
      icon: Icons.settings_outlined,
      primaryActionLabel: 'Badili lugha',
    );
  }
}
