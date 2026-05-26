import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/entities/prayer_entity.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    required this.prayer,
    required this.isFavorite,
    required this.onTap,
    super.key,
  });

  final PrayerEntity prayer;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.nightPanel,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prayer.title(), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    prayer.categoryLabel(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            if (isFavorite)
              const Icon(Icons.favorite, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
