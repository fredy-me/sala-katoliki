import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String? title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.section,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.surfaceWarm,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.gold),
          ),
          if (title != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              title!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
