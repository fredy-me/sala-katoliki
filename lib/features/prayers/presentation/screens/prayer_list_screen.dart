import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/prayer_entity.dart';
import '../providers/prayer_providers.dart';
import '../widgets/prayer_card.dart';

class PrayerListScreen extends ConsumerWidget {
  const PrayerListScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final prayersState = ref.watch(prayersProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final favoriteIds = ref.watch(favoritePrayerIdsProvider);

    return Scaffold(
      body: SafeArea(
        child: prayersState.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            title: languageCode == 'sw'
                ? 'Sala hazijapakia'
                : 'Prayers did not load',
            message: languageCode == 'sw'
                ? 'Kuna tatizo kusoma sala za kundi hili.'
                : 'There was a problem reading this category.',
            actionLabel: languageCode == 'sw' ? 'Rudi' : 'Back',
            onAction: () => context.pop(),
          ),
          data: (prayers) {
            final categoryPrayers = prayers
                .where((prayer) => prayer.categoryId == categoryId)
                .toList(growable: false);
            final categoryTitle =
                categoriesState.asData?.value
                    .where((category) => category.id == categoryId)
                    .map(
                      (category) =>
                          category.title[languageCode] ??
                          category.title['en'] ??
                          category.id,
                    )
                    .firstOrNull ??
                _fallbackTitle(categoryPrayers, languageCode);

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                AppSpacing.screenBottom,
              ),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: languageCode == 'sw' ? 'Rudi' : 'Back',
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        categoryTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (categoryPrayers.isEmpty)
                  AppEmptyState(
                    message: languageCode == 'sw'
                        ? 'Hakuna sala katika kundi hili bado.'
                        : 'No prayers are available in this category yet.',
                    icon: Icons.menu_book_outlined,
                  )
                else
                  for (final prayer in categoryPrayers) ...[
                    PrayerCard(
                      prayer: prayer,
                      isFavorite: favoriteIds.contains(prayer.id),
                      onTap: () => context.push('/prayers/${prayer.id}'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _fallbackTitle(List<PrayerEntity> prayers, String languageCode) {
    if (prayers.isEmpty) {
      return categoryId.replaceAll('_', ' ');
    }

    return prayers.first.categoryLabel(languageCode);
  }
}
