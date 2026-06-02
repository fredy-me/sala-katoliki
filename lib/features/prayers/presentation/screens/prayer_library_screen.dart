import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
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

    return prayersState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _PrayerLoadError(
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
            Text('Sala', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 18),
            _SearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 18),
            _TabSelector(
              selected: _selectedTab,
              onChanged: (tab) => setState(() => _selectedTab = tab),
            ),
            const SizedBox(height: 16),
            switch (_selectedTab) {
              _PrayerTab.all => _AllPrayersList(
                prayers: filtered,
                favoriteIds: favoriteIds,
              ),
              _PrayerTab.categories => _CategoryList(prayers: filtered),
              _PrayerTab.favorites => _FavoritesList(
                prayers: filtered,
                favoriteIds: favoriteIds,
              ),
            },
          ],
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.text),
      decoration: InputDecoration(
        hintText: 'Tafuta sala...',
        hintStyle: Theme.of(context).textTheme.bodyLarge,
        prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
        filled: true,
        fillColor: AppColors.nightPanel,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.selected, required this.onChanged});

  final _PrayerTab selected;
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
            label: 'Sala zote',
            selected: selected == _PrayerTab.all,
            onTap: () => onChanged(_PrayerTab.all),
          ),
          _TabButton(
            label: 'Makundi',
            selected: selected == _PrayerTab.categories,
            onTap: () => onChanged(_PrayerTab.categories),
          ),
          _TabButton(
            label: 'Vipendwa',
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
            color: selected ? AppColors.night : Colors.transparent,
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
  const _AllPrayersList({required this.prayers, required this.favoriteIds});

  final List<PrayerEntity> prayers;
  final Set<String> favoriteIds;

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) {
      return const _EmptyState(
        message: 'Hakuna sala inayolingana na utafutaji huu.',
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
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.prayers, required this.favoriteIds});

  final List<PrayerEntity> prayers;
  final Set<String> favoriteIds;

  @override
  Widget build(BuildContext context) {
    final favorites = prayers
        .where((prayer) => favoriteIds.contains(prayer.id))
        .toList(growable: false);

    if (favorites.isEmpty) {
      return const _EmptyState(
        message: 'Gusa moyo kwenye sala yoyote kuihifadhi hapa.',
      );
    }

    return _AllPrayersList(prayers: favorites, favoriteIds: favoriteIds);
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.prayers});

  final List<PrayerEntity> prayers;

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) {
      return const _EmptyState(
        message: 'Hakuna kundi linalolingana na utafutaji huu.',
      );
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
              color: AppColors.nightPanel,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(22),
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
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _PrayerLoadError extends StatelessWidget {
  const _PrayerLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sala hazijapakia',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Kuna tatizo kusoma maudhui ya ndani.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Jaribu tena')),
          ],
        ),
      ),
    );
  }
}
