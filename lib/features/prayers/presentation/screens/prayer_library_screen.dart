import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../domain/entities/prayer_entity.dart';
import '../providers/prayer_providers.dart';
import '../widgets/prayer_card.dart';

enum _PrayerTab { all, categories, favorites }

class PrayerLibraryScreen extends ConsumerStatefulWidget {
  const PrayerLibraryScreen({super.key});

  @override
  ConsumerState<PrayerLibraryScreen> createState() =>
      _PrayerLibraryScreenState();
}

class _PrayerLibraryScreenState extends ConsumerState<PrayerLibraryScreen> {
  final _searchController = TextEditingController();
  _PrayerTab _selectedTab = _PrayerTab.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayersState = ref.watch(prayersProvider);
    final favoriteIds = ref.watch(favoritePrayerIdsProvider);
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _PrayerLibraryStrings(languageCode);

    return prayersState.when(
      loading: () => AppLoading(label: strings.loading),
      error: (error, stackTrace) => _PrayerLoadError(
        strings: strings,
        onRetry: () {
          ref.invalidate(prayersProvider);
        },
      ),
      data: (prayers) {
        final filtered = prayers
            .where((prayer) => prayer.matches(_query))
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            Text(
              strings.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 18),
            AppSearchBar(
              controller: _searchController,
              hintText: strings.searchHint,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 18),
            _TabSelector(
              selected: _selectedTab,
              strings: strings,
              onChanged: (tab) => setState(() => _selectedTab = tab),
            ),
            const SizedBox(height: 16),
            switch (_selectedTab) {
              _PrayerTab.all => _AllPrayersList(
                prayers: filtered,
                favoriteIds: favoriteIds,
                emptyMessage: strings.noSearchResults,
              ),
              _PrayerTab.categories => _CategoryList(
                prayers: filtered,
                emptyMessage: strings.noCategoryResults,
              ),
              _PrayerTab.favorites => _FavoritesList(
                prayers: filtered,
                favoriteIds: favoriteIds,
                emptyMessage: strings.emptyFavorites,
              ),
            },
          ],
        );
      },
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.selected,
    required this.strings,
    required this.onChanged,
  });

  final _PrayerTab selected;
  final _PrayerLibraryStrings strings;
  final ValueChanged<_PrayerTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.nightPanelAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _TabButton(
            label: strings.allTab,
            selected: selected == _PrayerTab.all,
            onTap: () => onChanged(_PrayerTab.all),
          ),
          _TabButton(
            label: strings.categoriesTab,
            selected: selected == _PrayerTab.categories,
            onTap: () => onChanged(_PrayerTab.categories),
          ),
          _TabButton(
            label: strings.favoritesTab,
            selected: selected == _PrayerTab.favorites,
            onTap: () => onChanged(_PrayerTab.favorites),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.text : AppColors.mutedText,
            ),
          ),
        ),
      ),
    );
  }
}

class _AllPrayersList extends StatelessWidget {
  const _AllPrayersList({
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
      return _EmptyState(message: emptyMessage);
    }

    return Column(
      children: [
        for (final prayer in prayers) ...[
          PrayerCard(
            prayer: prayer,
            isFavorite: favoriteIds.contains(prayer.id),
            onTap: () => context.push('/prayers/${prayer.id}'),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({
    required this.prayers,
    required this.favoriteIds,
    required this.emptyMessage,
  });

  final List<PrayerEntity> prayers;
  final Set<String> favoriteIds;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final favorites = prayers
        .where((prayer) => favoriteIds.contains(prayer.id))
        .toList(growable: false);

    if (favorites.isEmpty) {
      return _EmptyState(message: emptyMessage);
    }

    return _AllPrayersList(
      prayers: favorites,
      favoriteIds: favoriteIds,
      emptyMessage: emptyMessage,
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.prayers, required this.emptyMessage});

  final List<PrayerEntity> prayers;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) {
      return _EmptyState(message: emptyMessage);
    }

    final grouped = <String, List<PrayerEntity>>{};
    for (final prayer in prayers) {
      grouped.putIfAbsent(prayer.categoryLabel(), () => []).add(prayer);
    }

    return Column(
      children: [
        for (final entry in grouped.entries) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '${entry.value.length} prayers',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
                for (final prayer in entry.value.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '· ${prayer.title()}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.text),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(message: message, icon: Icons.menu_book_outlined);
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
  String get loading => _sw ? 'Inapakia sala...' : 'Loading prayers...';
  String get searchHint => _sw ? 'Tafuta sala...' : 'Search prayers...';
  String get allTab => _sw ? 'Sala zote' : 'All';
  String get categoriesTab => _sw ? 'Makundi' : 'Categories';
  String get favoritesTab => _sw ? 'Vipendwa' : 'Favorites';
  String get noSearchResults => _sw
      ? 'Hakuna sala inayolingana na utafutaji huu.'
      : 'No prayers match this search.';
  String get noCategoryResults => _sw
      ? 'Hakuna kundi linalolingana na utafutaji huu.'
      : 'No categories match this search.';
  String get emptyFavorites => _sw
      ? 'Gusa moyo kwenye sala yoyote kuihifadhi hapa.'
      : 'Tap the heart on any prayer to save it here.';
  String get loadErrorTitle =>
      _sw ? 'Sala hazijapakia' : 'Prayers did not load';
  String get loadErrorMessage => _sw
      ? 'Kuna tatizo kusoma maudhui ya ndani.'
      : 'There was a problem reading local content.';
  String get retry => _sw ? 'Jaribu tena' : 'Retry';
}
