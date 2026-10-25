import 'package:salakatoliki/core/localization/app_strings.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/novena_model.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/text_style_rules.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../../novenas/presentation/providers/novena_providers.dart';
import '../providers/prayer_providers.dart';
import '../widgets/prayer_card.dart';

class PrayerLibraryScreen extends ConsumerStatefulWidget {
  const PrayerLibraryScreen({super.key});

  @override
  ConsumerState<PrayerLibraryScreen> createState() =>
      _PrayerLibraryScreenState();
}

class _PrayerLibraryScreenState extends ConsumerState<PrayerLibraryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  /// 4.7: the query the results are filtered by, applied only after the user
  /// stops typing. The field itself still updates on every keystroke, so the
  /// field stays responsive; only the 36-prayer re-scoring is deferred.
  static const _searchDebounce = Duration(milliseconds: 250);

  Timer? _debounceTimer;

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_searchDebounce, () {
      if (!mounted) {
        return;
      }
      setState(() => _query = value);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = AppStrings(languageCode);
    final prayersState = ref.watch(prayersProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final novenasState = ref.watch(novenasProvider);
    final favoriteIds =
        ref.watch(favoritePrayerIdsProvider).asData?.value ?? <String>{};

    return prayersState.when(
      loading: () => AppLoading(label: strings.prayerLibraryLoading),
      error: (error, stackTrace) => _PrayerLoadError(
        strings: strings,
        onRetry: () => ref.invalidate(prayersProvider),
      ),
      data: (prayers) {
        final novenas = novenasState.asData?.value ?? const <NovenaModel>[];
        final scoredPrayers =
            prayers
                .map((p) => (prayer: p, score: p.score(_query)))
                .where((r) => r.score > 0)
                .toList()
              ..sort((a, b) => b.score.compareTo(a.score));
        final scoredNovenas =
            novenas
                .map(
                  (n) => (
                    novena: n,
                    score: scoreNovena(n.title, n.description, _query),
                  ),
                )
                .where((r) => r.score > 0)
                .toList()
              ..sort((a, b) => b.score.compareTo(a.score));

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.screenTop,
            AppSpacing.screenHorizontal,
            AppSpacing.screenBottom,
          ),
          children: [
            Text(
              strings.prayerLibraryTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings.prayerLibrarySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSearchBar(
              controller: _searchController,
              hintText: strings.prayerLibrarySearchHint,
              onChanged: _onQueryChanged,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_query.trim().isNotEmpty)
              _SearchResults(
                prayers: scoredPrayers,
                novenas: scoredNovenas,
                favoriteIds: favoriteIds,
                emptyMessage: strings.prayerLibraryNoSearchResults,
                onFavoriteToggle: (prayerId) => ref
                    .read(favoritePrayerIdsProvider.notifier)
                    .toggle(prayerId),
              )
            else
              categoriesState.when(
                loading: () => const AppLoading(),
                error: (error, stackTrace) => AppErrorState(
                  title: strings.prayerLibraryCategoriesErrorTitle,
                  message: strings.prayerLibraryCategoriesErrorMessage,
                  actionLabel: strings.prayerLibraryRetry,
                  onAction: () => ref.invalidate(categoriesProvider),
                ),
                data: (categories) => _CategoryGrid(
                  categories: categories,
                  prayers: prayers,
                  languageCode: languageCode,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.prayers,
    required this.novenas,
    required this.favoriteIds,
    required this.emptyMessage,
    required this.onFavoriteToggle,
  });

  final List<({PrayerEntity prayer, int score})> prayers;
  final List<({NovenaModel novena, int score})> novenas;
  final Set<String> favoriteIds;
  final String emptyMessage;
  final ValueChanged<String> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty && novenas.isEmpty) {
      return AppEmptyState(
        message: emptyMessage,
        icon: Icons.search_off_outlined,
      );
    }

    return Column(
      children: [
        for (final novena in novenas) ...[
          AppCard(
            onTap: () => context.push('/novenas/${novena.novena.id}'),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        novena.novena.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        novena.novena.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        for (final result in prayers) ...[
          PrayerCard(
            prayer: result.prayer,
            isFavorite: favoriteIds.contains(result.prayer.id),
            onTap: () => context.push('/prayers/${result.prayer.id}'),
            onFavoriteToggle: () => onFavoriteToggle(result.prayer.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.prayers,
    required this.languageCode,
  });

  final List<CategoryModel> categories;
  final List<PrayerEntity> prayers;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(languageCode);
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final countsByCategory = <String, int>{};
    for (final prayer in prayers) {
      final categoryId = isCommonPrayerCategory(prayer.categoryId)
          ? 'common_prayers'
          : prayer.categoryId;
      countsByCategory.update(
        categoryId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrayerSection(
          title: strings.prayerLibraryCorePrayers,
          entries: [
            if (categoriesById['common_prayers'] != null)
              _PrayerCategoryEntry(
                category: categoriesById['common_prayers']!,
                count: countsByCategory['common_prayers'] ?? 0,
              ),
          ],
          languageCode: languageCode,
          strings: strings,
        ),
        const SizedBox(height: AppSpacing.lg),
        _PrayerSection(
          title: strings.prayerLibraryMarianAndRosary,
          entries: [
            if (categoriesById['marian_prayers'] != null)
              _PrayerCategoryEntry(
                category: categoriesById['marian_prayers']!,
                count: countsByCategory['marian_prayers'] ?? 0,
              ),
            _PrayerFeatureEntry(
              title: strings.prayerLibraryRosaryAndMysteries,
              description: strings.prayerLibraryRosaryAndMysteriesDescription,
              iconName: 'rosary',
              route: '/rosary',
            ),
            _PrayerFeatureEntry(
              title: strings.prayerLibraryDivineMercyRosary,
              description: strings.prayerLibraryDivineMercyRosaryDescription,
              iconName: 'heart',
              route: '/rosary/step/divine_mercy_rosary',
            ),
          ],
          languageCode: languageCode,
          strings: strings,
        ),
        const SizedBox(height: AppSpacing.lg),
        _PrayerSection(
          title: strings.prayerLibraryDevotions,
          entries: [
            if (categoriesById['litanies'] != null)
              _PrayerCategoryEntry(
                category: categoriesById['litanies']!,
                count: countsByCategory['litanies'] ?? 0,
              ),
          ],
          languageCode: languageCode,
          strings: strings,
        ),
      ],
    );
  }
}

sealed class _PrayerEntry {
  const _PrayerEntry();
}

class _PrayerCategoryEntry extends _PrayerEntry {
  const _PrayerCategoryEntry({required this.category, required this.count});

  final CategoryModel category;
  final int count;
}

class _PrayerFeatureEntry extends _PrayerEntry {
  const _PrayerFeatureEntry({
    required this.title,
    required this.description,
    required this.iconName,
    required this.route,
  });

  final String title;
  final String description;
  final String iconName;
  final String route;
}

class _PrayerSection extends StatelessWidget {
  const _PrayerSection({
    required this.title,
    required this.entries,
    required this.languageCode,
    required this.strings,
  });

  final String title;
  final List<_PrayerEntry> entries;
  final String languageCode;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.gold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final entry in entries) ...[
          switch (entry) {
            _PrayerCategoryEntry() => _CategoryCard(
              category: entry.category,
              count: entry.count,
              languageCode: languageCode,
              unavailableLabel: strings.prayerLibraryComingSoon,
            ),
            _PrayerFeatureEntry() => _FeatureCard(entry: entry),
          },
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.languageCode,
    required this.unavailableLabel,
  });

  final CategoryModel category;
  final int count;
  final String languageCode;
  final String unavailableLabel;

  @override
  Widget build(BuildContext context) {
    final title =
        category.title[languageCode] ?? category.title['en'] ?? category.id;
    final description =
        category.description[languageCode] ?? category.description['en'] ?? '';
    final hasContent = count > 0;

    return AppCard(
      onTap: hasContent
          ? () => context.push('/prayers/category/${category.id}')
          : null,
      radius: AppSpacing.radiusXl,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CategoryIcon(iconName: category.icon),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hasContent ? description : unavailableLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            hasContent ? Icons.chevron_right : Icons.lock_outline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.entry});

  final _PrayerFeatureEntry entry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(entry.route),
      radius: AppSpacing.radiusXl,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CategoryIcon(iconName: entry.iconName),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  entry.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconName});

  final String iconName;

  @override
  Widget build(BuildContext context) {
    final icon = switch (iconName) {
      'star' => Icons.auto_awesome,
      'hands_prayer' => Icons.volunteer_activism,
      'church' => Icons.church,
      'heart' => Icons.favorite_border,
      'list' => Icons.format_list_bulleted,
      'calendar' => Icons.calendar_month_outlined,
      'rosary' => Icons.radio_button_checked,
      _ => Icons.add,
    };

    return Container(
      width: 58,
      height: 58,
      decoration: const BoxDecoration(
        color: AppColors.goldSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.navy, size: 28),
    );
  }
}

class _PrayerLoadError extends StatelessWidget {
  const _PrayerLoadError({required this.strings, required this.onRetry});

  final AppStrings strings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: strings.prayerLibraryLoadErrorTitle,
      message: strings.prayerLibraryLoadErrorMessage,
      actionLabel: strings.prayerLibraryRetry,
      onAction: onRetry,
    );
  }
}
