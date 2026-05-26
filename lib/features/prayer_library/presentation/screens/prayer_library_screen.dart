import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/feature_placeholder_screen.dart';

class PrayerLibraryScreen extends StatelessWidget {
  const PrayerLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Sala',
      subtitle: 'Maktaba ya sala itaandaliwa kwa maudhui ya ndani kwanza.',
      icon: Icons.menu_book_outlined,
      primaryActionLabel: 'Tazama sala za mwanzo',
    );
  }
}
