import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../domain/entities/prayer_entity.dart';
import '../providers/prayer_providers.dart';
import '../widgets/prayer_card.dart';

const _commonPrayerCategoryIds = {
  'common_prayers',
  'mass_prayers',
  'confession_prayers',
  'divine_mercy',
};

class PrayerListScreen extends ConsumerStatefulWidget {
  const PrayerListScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  ConsumerState<PrayerListScreen> createState() => _PrayerListScreenState();
}

class _PrayerListScreenState extends ConsumerState<PrayerListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(activeLanguageProvider);
    final prayersState = ref.watch(prayersProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final favoriteIds =
        ref.watch(favoritePrayerIdsProvider).asData?.value ?? <String>{};

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
            onAction: () => context.popOrGo('/prayers'),
          ),
          data: (prayers) {
            final categoryPrayers = prayers
                .where((prayer) => _includesPrayer(prayer.categoryId))
                .toList(growable: false);
            final visiblePrayers = categoryPrayers
                .where((prayer) => prayer.matches(_query))
                .toList(growable: false);
            final categoryTitle =
                categoriesState.asData?.value
                    .where((category) => category.id == widget.categoryId)
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
                      onPressed: () => context.popOrGo('/prayers'),
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
                AppSearchBar(
                  controller: _searchController,
                  hintText: languageCode == 'sw'
                      ? 'Tafuta ndani ya $categoryTitle...'
                      : 'Search in $categoryTitle...',
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (categoryPrayers.isEmpty)
                  AppEmptyState(
                    message: languageCode == 'sw'
                        ? 'Hakuna sala katika kundi hili bado.'
                        : 'No prayers are available in this category yet.',
                    icon: Icons.menu_book_outlined,
                  )
                else if (visiblePrayers.isEmpty)
                  AppEmptyState(
                    message: languageCode == 'sw'
                        ? 'Hakuna sala inayolingana na utafutaji huu.'
                        : 'No prayers match this search.',
                    icon: Icons.search_off_outlined,
                  )
                else
                  for (final prayer in visiblePrayers) ...[
                    PrayerCard(
                      prayer: prayer,
                      isFavorite: favoriteIds.contains(prayer.id),
                      onTap: () => context.push('/prayers/${prayer.id}'),
                      onFavoriteToggle: () => ref
                          .read(favoritePrayerIdsProvider.notifier)
                          .toggle(prayer.id),
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
      return widget.categoryId.replaceAll('_', ' ');
    }

    return prayers.first.categoryLabel(languageCode);
  }

  bool _includesPrayer(String prayerCategoryId) {
    if (widget.categoryId == 'common_prayers') {
      return _commonPrayerCategoryIds.contains(prayerCategoryId);
    }

    return prayerCategoryId == widget.categoryId;
  }
}
