import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../prayers/domain/entities/prayer_entity.dart';
import '../../../prayers/presentation/providers/prayer_providers.dart';
import '../../../prayers/presentation/widgets/prayer_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
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
    final strings = _LibraryStrings(languageCode);
    final prayersState = ref.watch(prayersProvider);
    final favoriteIds = ref.watch(favoritePrayerIdsProvider);
    final recentIds =
        ref.watch(recentPrayerIdsProvider).asData?.value ?? const <String>[];

    return prayersState.when(
      loading: () => AppLoading(label: strings.loading),
      error: (error, stackTrace) => AppEmptyState(
        title: strings.loadErrorTitle,
        message: strings.loadErrorMessage,
        icon: Icons.error_outline,
      ),
      data: (prayers) {
        final filtered = prayers
            .where((prayer) => prayer.matches(_query))
            .toList(growable: false);
        final favorites = prayers
            .where((prayer) => favoriteIds.contains(prayer.id))
            .toList(growable: false);
        final recent = _recentPrayers(prayers, recentIds);

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
              _LibrarySearchResults(
                prayers: filtered,
                favoriteIds: favoriteIds,
                emptyMessage: strings.noSearchResults,
              )
            else ...[
              SectionHeader(title: strings.favorites),
              const SizedBox(height: AppSpacing.md),
              _FavoritesRail(
                favorites: favorites,
                emptyText: strings.noFavorites,
              ),
              const SizedBox(height: AppSpacing.lg),
              _LibraryEntry(
                icon: Icons.favorite_border,
                title: strings.favorites,
                subtitle: strings.favoriteCount(favorites.length),
                onTap: () => context.go('/library'),
              ),
              _LibraryEntry(
                icon: Icons.schedule,
                title: strings.recentlyOpened,
                subtitle: recent.isEmpty
                    ? strings.noRecent
                    : strings.recentSubtitle(recent.first.title()),
                onTap: recent.isEmpty
                    ? null
                    : () => context.push('/prayers/${recent.first.id}'),
              ),
              _LibraryEntry(
                icon: Icons.menu_book_outlined,
                title: strings.allPrayers,
                subtitle: strings.allPrayerCount(prayers.length),
                onTap: () => context.go('/prayers'),
              ),
              _LibraryEntry(
                icon: Icons.download_done_outlined,
                title: strings.offlineContent,
                subtitle: strings.offlineSubtitle(prayers.length),
                onTap: null,
              ),
              _LibraryEntry(
                icon: Icons.settings_outlined,
                title: strings.settings,
                subtitle: strings.settingsSubtitle,
                onTap: () => context.go('/settings'),
              ),
              _LibraryEntry(
                icon: Icons.info_outline,
                title: strings.about,
                subtitle: strings.aboutSubtitle,
                onTap: () => _showAbout(context, strings),
              ),
            ],
          ],
        );
      },
    );
  }

  List<PrayerEntity> _recentPrayers(
    List<PrayerEntity> prayers,
    List<String> ids,
  ) {
    final byId = {for (final prayer in prayers) prayer.id: prayer};
    return ids
        .map((id) => byId[id])
        .whereType<PrayerEntity>()
        .toList(growable: false);
  }

  void _showAbout(BuildContext context, _LibraryStrings strings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sala Katoliki',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                strings.aboutBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                backgroundColor: AppColors.surfaceWarm,
                child: Text(
                  strings.contentSources,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FavoritesRail extends StatelessWidget {
  const _FavoritesRail({required this.favorites, required this.emptyText});

  final List<PrayerEntity> favorites;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return AppCard(
        backgroundColor: AppColors.surfaceWarm,
        child: Text(emptyText, style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final prayer = favorites[index];
          return SizedBox(
            width: 150,
            child: AppCard(
              onTap: () => context.push('/prayers/${prayer.id}'),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.favorite, color: AppColors.danger, size: 16),
                  const Spacer(),
                  Text(
                    prayer.title(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    prayer.categoryLabel().toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LibrarySearchResults extends StatelessWidget {
  const _LibrarySearchResults({
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

class _LibraryEntry extends StatelessWidget {
  const _LibraryEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.surfaceWarm,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.navy, size: 21),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _LibraryStrings {
  const _LibraryStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Maktaba' : 'Library';
  String get subtitle => _sw ? 'Sala na zana zako' : 'Your prayers and tools';
  String get loading => _sw ? 'Inapakia maktaba...' : 'Loading library...';
  String get searchHint => _sw
      ? 'Tafuta sala, novenas, rozari...'
      : 'Search prayers, novenas, rosary...';
  String get favorites => _sw ? 'Vipendwa' : 'Favorites';
  String get noFavorites => _sw
      ? 'Sala ulizopenda zitaonekana hapa.'
      : 'Favorite prayers will appear here.';
  String favoriteCount(int count) =>
      _sw ? '$count sala zilizohifadhiwa' : '$count saved prayers';
  String get recentlyOpened =>
      _sw ? 'Zilizofunguliwa Karibuni' : 'Recently Opened';
  String get noRecent => _sw ? 'Hakuna sala ya karibuni' : 'No recent prayers';
  String recentSubtitle(String title) =>
      _sw ? '$title - hivi karibuni' : '$title - recent';
  String get allPrayers => _sw ? 'Sala Zote' : 'All Prayers';
  String allPrayerCount(int count) => _sw ? '$count sala' : '$count prayers';
  String get offlineContent =>
      _sw ? 'Maudhui ya Nje ya Mtandao' : 'Offline Content';
  String offlineSubtitle(int count) =>
      _sw ? '$count sala tayari' : '$count prayers ready';
  String get settings => _sw ? 'Mipangilio' : 'Settings';
  String get settingsSubtitle =>
      _sw ? 'Lugha, vikumbusho, mandhari' : 'Language, reminders, theme';
  String get about => _sw ? 'Kuhusu Programu' : 'About App';
  String get aboutSubtitle => _sw ? 'Toleo 0.1.0' : 'Version 0.1.0';
  String get loadErrorTitle =>
      _sw ? 'Maktaba haijapakia' : 'Library did not load';
  String get loadErrorMessage => _sw
      ? 'Kuna tatizo kusoma maudhui ya ndani.'
      : 'There was a problem reading local content.';
  String get noSearchResults => _sw
      ? 'Hakuna maudhui yanayolingana na utafutaji huu.'
      : 'No content matches this search.';
  String get aboutBody => _sw
      ? 'Programu rahisi ya sala ya Kikatoliki inayofanya kazi nje ya mtandao.'
      : 'A simple offline-first Catholic prayer companion.';
  String get contentSources => _sw
      ? 'Vyanzo: Sala za kimapokeo za Kikatoliki na ibada zilizoidhinishwa.'
      : 'Sources: Traditional Catholic prayers and approved devotions.';
}
