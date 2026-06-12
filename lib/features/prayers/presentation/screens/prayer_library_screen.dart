import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/section_header.dart';
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
            else ...[
              SectionHeader(title: strings.allPrayers),
              const SizedBox(height: AppSpacing.md),
              _SearchResults(
                prayers: prayers,
                favoriteIds: favoriteIds,
                emptyMessage: strings.noPrayers,
                onFavoriteToggle: (prayerId) => ref
                    .read(favoritePrayerIdsProvider.notifier)
                    .toggle(prayerId),
              ),
            ],
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
  String get allPrayers => _sw ? 'Sala Zote' : 'All Prayers';
  String get noPrayers => _sw
      ? 'Hakuna sala zilizopatikana kwenye maudhui ya ndani.'
      : 'No prayers were found in local content.';
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
