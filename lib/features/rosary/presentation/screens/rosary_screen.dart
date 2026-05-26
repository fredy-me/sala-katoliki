import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/feature_placeholder_screen.dart';

class RosaryScreen extends StatelessWidget {
  const RosaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Rozari',
      subtitle: 'Mwongozo wa rozari utaonyesha fumbo, sala, na maendeleo.',
      icon: Icons.auto_awesome_outlined,
      primaryActionLabel: 'Anza rozari',
    );
  }
}
