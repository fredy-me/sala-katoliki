import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryActionLabel,
    this.onPrimaryAction,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.nightPanelAlt,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 24),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.nightPanel,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phase 1 placeholder',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'This screen is ready for the next SRS implementation phase.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onPrimaryAction ?? () {},
          child: Text(primaryActionLabel),
        ),
      ],
    );
  }
}
