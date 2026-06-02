import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/feature_placeholder_screen.dart';

class ReadingsScreen extends StatelessWidget {
  const ReadingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Masomo',
      subtitle: 'Masomo ya kila siku yatafanya kazi bila intaneti.',
      icon: Icons.favorite_border,
      primaryActionLabel: 'Fungua masomo ya leo',
    );
  }
}
