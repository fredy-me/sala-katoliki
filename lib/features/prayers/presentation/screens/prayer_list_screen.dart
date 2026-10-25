import 'package:salakatoliki/core/localization/app_strings.dart';
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
    final strings = AppStrings(languageCode);
    final prayersState = ref.watch(prayersProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final favoriteIds =
        ref.watch(favoritePrayerIdsProvider).asData?.value ?? <String>{};

    return Scaffold(
      body: SafeArea(
        child: prayersState.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            title: strings.prayerListErrorTitle,
            message: strings.prayerListErrorMessage,
            actionLabel: strings.prayerListBack,
            onAction: () => context.popOrGo('/prayers'),
          ),
          data: (prayers) {
            final categoryPrayers = prayers
                .where((prayer) => _includesPrayer(prayer.categoryId))
                .toList(growable: false);
            final visiblePrayers =
                categoryPrayers
                    .map((p) => (prayer: p, score: p.score(_query)))
                    .where((r) => r.score > 0)
                    .toList()
                  ..sort((a, b) => b.score.compareTo(a.score));
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
                      tooltip: strings.prayerListBack,
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
                  hintText: strings.prayerListSearchHint(categoryTitle),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (categoryPrayers.isEmpty)
                  AppEmptyState(
                    message: strings.prayerListEmptyMessage,
                    icon: Icons.menu_book_outlined,
                  )
                else if (visiblePrayers.isEmpty)
                  AppEmptyState(
                    message: strings.prayerListNoSearchResults,
                    icon: Icons.search_off_outlined,
                  )
                else
                  for (final result in visiblePrayers) ...[
                    PrayerCard(
                      prayer: result.prayer,
                      isFavorite: favoriteIds.contains(result.prayer.id),
                      onTap: () => context.push('/prayers/${result.prayer.id}'),
                      onFavoriteToggle: () => ref
                          .read(favoritePrayerIdsProvider.notifier)
                          .toggle(result.prayer.id),
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
