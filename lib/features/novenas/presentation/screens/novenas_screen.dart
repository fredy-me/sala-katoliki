import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_screen.dart';

class NovenasScreen extends StatelessWidget {
  const NovenasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Novenas',
      subtitle: 'Nine-day Catholic devotions with local progress tracking.',
      icon: Icons.calendar_month_outlined,
      primaryActionLabel: 'Start novena',
    );
  }
}
