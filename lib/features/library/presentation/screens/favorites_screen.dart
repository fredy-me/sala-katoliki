import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/novena_model.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../prayers/domain/entities/prayer_entity.dart';
import '../../../prayers/presentation/providers/prayer_providers.dart';
import '../../../prayers/presentation/widgets/prayer_card.dart';
import '../../../novenas/presentation/providers/novena_providers.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
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
    final strings = _FavoritesStrings(languageCode);
    final prayersState = ref.watch(prayersProvider);
    final novenasState = ref.watch(novenasProvider);
    final favoriteIds =
        ref.watch(favoritePrayerIdsProvider).asData?.value ?? <String>{};
    final favoriteNovenaIds =
        ref.watch(favoriteNovenaIdsProvider).asData?.value ?? <String>{};

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        context.popOrGo('/today');
      },
      child: Scaffold(
        body: SafeArea(
          child: prayersState.when(
            loading: () => AppLoading(label: strings.loading),
            error: (error, stackTrace) => AppErrorState(
              title: strings.loadErrorTitle,
              message: strings.loadErrorMessage,
              actionLabel: strings.back,
              onAction: () => context.popOrGo('/today'),
            ),
            data: (prayers) {
              final favorites = _favoritePrayers(prayers, favoriteIds);
              final favoriteNovenas = _favoriteNovenas(
                novenasState.asData?.value ?? const <NovenaModel>[],
                favoriteNovenaIds,
              );
              final visible = favorites
                  .where((prayer) => prayer.matches(_query))
                  .toList(growable: false);
              final visibleNovenas = favoriteNovenas
                  .where((novena) => _matchesNovena(novena, _query))
                  .toList(growable: false);

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
                        tooltip: strings.back,
                        onPressed: () => context.popOrGo('/today'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          strings.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Text(
                      strings.subtitle(
                        favorites.length + favoriteNovenas.length,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppSearchBar(
                    controller: _searchController,
                    hintText: strings.searchHint,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (favorites.isEmpty && favoriteNovenas.isEmpty)
                    AppEmptyState(
                      title: strings.emptyTitle,
                      message: strings.emptyMessage,
                      icon: Icons.favorite_border,
                    )
                  else if (visible.isEmpty && visibleNovenas.isEmpty)
                    AppEmptyState(
                      message: strings.noSearchResults,
                      icon: Icons.search_off_outlined,
                    )
                  else ...[
                    for (final novena in visibleNovenas) ...[
                      _FavoriteNovenaCard(
                        novena: novena,
                        onTap: () => context.push('/novenas/${novena.id}'),
                        onRemove: () => ref
                            .read(favoriteNovenaIdsProvider.notifier)
                            .remove(novena.id),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    for (final prayer in visible) ...[
                      PrayerCard(
                        prayer: prayer,
                        isFavorite: true,
                        onTap: () => context.push('/prayers/${prayer.id}'),
                        onFavoriteToggle: () => ref
                            .read(favoritePrayerIdsProvider.notifier)
                            .remove(prayer.id),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<PrayerEntity> _favoritePrayers(
    List<PrayerEntity> prayers,
    Set<String> favoriteIds,
  ) {
    return prayers
        .where((prayer) => favoriteIds.contains(prayer.id))
        .toList(growable: false);
  }

  List<NovenaModel> _favoriteNovenas(
    List<NovenaModel> novenas,
    Set<String> favoriteIds,
  ) {
    return novenas
        .where((novena) => favoriteIds.contains(novena.id))
        .toList(growable: false);
  }

  bool _matchesNovena(NovenaModel novena, String query) {
    final normalized = query.trim().toLowerCase();
    return normalized.isEmpty ||
        novena.title.toLowerCase().contains(normalized) ||
        novena.description.toLowerCase().contains(normalized);
  }
}

class _FavoriteNovenaCard extends StatelessWidget {
  const _FavoriteNovenaCard({
    required this.novena,
    required this.onTap,
    required this.onRemove,
  });

  final NovenaModel novena;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.calendar_month_outlined),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(novena.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  novena.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove favorite',
            onPressed: onRemove,
            icon: Icon(
              Icons.favorite,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesStrings {
  const _FavoritesStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Vipendwa' : 'Favorites';
  String subtitle(int count) =>
      _sw ? '$count vipendwa vilivyohifadhiwa' : '$count saved favorites';
  String get loading => _sw ? 'Inapakia vipendwa...' : 'Loading favorites...';
  String get searchHint => _sw ? 'Tafuta vipendwa...' : 'Search favorites...';
  String get emptyTitle => _sw ? 'Hakuna vipendwa bado' : 'No favorites yet';
  String get emptyMessage => _sw
      ? 'Gusa alama ya moyo kwenye sala ili kuihifadhi hapa.'
      : 'Tap the heart on any prayer to save it here.';
  String get noSearchResults => _sw
      ? 'Hakuna kipendwa kinacholingana na utafutaji huu.'
      : 'No favorite prayer matches this search.';
  String get loadErrorTitle =>
      _sw ? 'Vipendwa havijapakia' : 'Favorites did not load';
  String get loadErrorMessage => _sw
      ? 'Kuna tatizo kusoma sala zilizohifadhiwa.'
      : 'There was a problem reading saved prayers.';
  String get back => _sw ? 'Rudi' : 'Back';
}
