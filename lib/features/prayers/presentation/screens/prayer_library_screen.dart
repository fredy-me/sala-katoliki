import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/category_model.dart';
import '../../../../shared/widgets/app_card.dart';
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
};

class PrayerLibraryScreen extends ConsumerStatefulWidget {
  const PrayerLibraryScreen({super.key});

  @override
  ConsumerState<PrayerLibraryScreen> createState() =>
      _PrayerLibraryScreenState();
}

class _PrayerLibraryScreenState extends ConsumerState<PrayerLibraryScreen> {
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
    final strings = _PrayerLibraryStrings(languageCode);
    final prayersState = ref.watch(prayersProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final favoriteIds =
        ref.watch(favoritePrayerIdsProvider).asData?.value ?? <String>{};

    return prayersState.when(
      loading: () => AppLoading(label: strings.loading),
      error: (error, stackTrace) => _PrayerLoadError(
        strings: strings,
        onRetry: () => ref.invalidate(prayersProvider),
      ),
      data: (prayers) {
        final filtered = prayers
            .where((prayer) => prayer.matches(_query))
            .toList(growable: false);

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.screenTop,
            AppSpacing.screenHorizontal,
            AppSpacing.screenBottom,
          ),
          children: [
            Text(
              strings.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSearchBar(
              controller: _searchController,
              hintText: strings.searchHint,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_query.trim().isNotEmpty)
              _SearchResults(
                prayers: filtered,
                favoriteIds: favoriteIds,
                emptyMessage: strings.noSearchResults,
                onFavoriteToggle: (prayerId) => ref
                    .read(favoritePrayerIdsProvider.notifier)
                    .toggle(prayerId),
              )
            else
              categoriesState.when(
                loading: () => const AppLoading(),
                error: (error, stackTrace) => AppErrorState(
                  title: strings.categoriesErrorTitle,
                  message: strings.categoriesErrorMessage,
                  actionLabel: strings.retry,
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
    required this.favoriteIds,
    required this.emptyMessage,
    required this.onFavoriteToggle,
  });

  final List<PrayerEntity> prayers;
  final Set<String> favoriteIds;
  final String emptyMessage;
  final ValueChanged<String> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) {
      return AppEmptyState(
        message: emptyMessage,
        icon: Icons.search_off_outlined,
      );
    }

    return Column(
      children: [
        for (final prayer in prayers) ...[
          PrayerCard(
            prayer: prayer,
            isFavorite: favoriteIds.contains(prayer.id),
            onTap: () => context.push('/prayers/${prayer.id}'),
            onFavoriteToggle: () => onFavoriteToggle(prayer.id),
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
    final strings = _PrayerLibraryStrings(languageCode);
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final countsByCategory = <String, int>{};
    for (final prayer in prayers) {
      final categoryId = _commonPrayerCategoryIds.contains(prayer.categoryId)
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
          title: strings.corePrayers,
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
          title: strings.marianAndRosary,
          entries: [
            if (categoriesById['marian_prayers'] != null)
              _PrayerCategoryEntry(
                category: categoriesById['marian_prayers']!,
                count: countsByCategory['marian_prayers'] ?? 0,
              ),
            _PrayerFeatureEntry(
              title: strings.rosaryAndMysteries,
              description: strings.rosaryAndMysteriesDescription,
              iconName: 'rosary',
              route: '/rosary',
            ),
          ],
          languageCode: languageCode,
          strings: strings,
        ),
        const SizedBox(height: AppSpacing.lg),
        _PrayerSection(
          title: strings.devotions,
          entries: [
            if (categoriesById['litanies'] != null)
              _PrayerCategoryEntry(
                category: categoriesById['litanies']!,
                count: countsByCategory['litanies'] ?? 0,
              ),
            _PrayerFeatureEntry(
              title: strings.novenas,
              description: strings.novenasDescription,
              iconName: 'calendar',
              route: '/novenas',
            ),
            if (categoriesById['divine_mercy'] != null)
              _PrayerCategoryEntry(
                category: categoriesById['divine_mercy']!,
                count: countsByCategory['divine_mercy'] ?? 0,
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
  final _PrayerLibraryStrings strings;

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
              unavailableLabel: strings.comingSoon,
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

  final _PrayerLibraryStrings strings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: strings.loadErrorTitle,
      message: strings.loadErrorMessage,
      actionLabel: strings.retry,
      onAction: onRetry,
    );
  }
}

class _PrayerLibraryStrings {
  const _PrayerLibraryStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Sala' : 'Pray';
  String get subtitle => _sw
      ? 'Chagua sala, ibada, novena, na rozari kwa mpangilio.'
      : 'Choose prayers, devotions, novenas, and rosary in order.';
  String get loading => _sw ? 'Inapakia sala...' : 'Loading prayers...';
  String get searchHint => _sw ? 'Tafuta sala...' : 'Search prayers...';
  String get corePrayers => _sw ? 'Sala Muhimu' : 'Essential Prayers';
  String get marianAndRosary =>
      _sw ? 'Bikira Maria na Rozari' : 'Mary and Rosary';
  String get devotions => _sw ? 'Ibada Maalum' : 'Devotions';
  String get rosaryAndMysteries =>
      _sw ? 'Rozari na Mafumbo' : 'Rosary and Mysteries';
  String get rosaryAndMysteriesDescription => _sw
      ? 'Sali rozari kwa hatua na mafumbo ya siku.'
      : 'Pray the rosary step by step with the mysteries of the day.';
  String get novenas => _sw ? 'Novena' : 'Novenas';
  String get novenasDescription => _sw
      ? 'Ibada za siku tisa na ufuatiliaji wa maendeleo.'
      : 'Nine-day devotions with progress tracking.';
  String get comingSoon => _sw ? 'Inaandaliwa' : 'Coming soon';
  String countLabel(int count) {
    if (_sw) {
      return count == 1 ? 'Sala 1' : 'Sala $count';
    }

    return count == 1 ? '1 prayer' : '$count prayers';
  }

  String get noSearchResults => _sw
      ? 'Hakuna sala inayolingana na utafutaji huu.'
      : 'No prayers match this search.';
  String get loadErrorTitle =>
      _sw ? 'Sala hazijapakia' : 'Prayers did not load';
  String get loadErrorMessage => _sw
      ? 'Kuna tatizo kusoma maudhui ya ndani.'
      : 'There was a problem reading local content.';
  String get categoriesErrorTitle =>
      _sw ? 'Makundi hayajapakia' : 'Categories did not load';
  String get categoriesErrorMessage => _sw
      ? 'Kuna tatizo kusoma makundi ya sala.'
      : 'There was a problem reading prayer categories.';
  String get retry => _sw ? 'Jaribu tena' : 'Retry';
}
