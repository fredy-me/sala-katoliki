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
    final favoriteIds = ref.watch(favoritePrayerIdsProvider);

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
  });

  final List<PrayerEntity> prayers;
  final Set<String> favoriteIds;
  final String emptyMessage;

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
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.98,
      children: [
        for (final category in categories)
          _CategoryCard(
            category: category,
            count: prayers
                .where((prayer) => prayer.categoryId == category.id)
                .length,
            languageCode: languageCode,
          ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.languageCode,
  });

  final CategoryModel category;
  final int count;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final title =
        category.title[languageCode] ?? category.title['en'] ?? category.id;
    final description =
        category.description[languageCode] ?? category.description['en'] ?? '';

    return AppCard(
      onTap: () => context.push('/prayers/category/${category.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryIcon(iconName: category.icon),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '$count ${count == 1 ? 'prayer' : 'prayers'}',
            style: Theme.of(context).textTheme.labelSmall,
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
      _ => Icons.add,
    };

    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: AppColors.goldSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.navy, size: 21),
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
  String get subtitle =>
      _sw ? 'Vinjari sala kwa makundi' : 'Browse prayers by category';
  String get loading => _sw ? 'Inapakia sala...' : 'Loading prayers...';
  String get searchHint => _sw ? 'Tafuta sala...' : 'Search prayers...';
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
