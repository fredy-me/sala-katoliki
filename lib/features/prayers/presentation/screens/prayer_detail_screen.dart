import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/prayer_text_view.dart';
import '../providers/prayer_providers.dart';

class PrayerDetailScreen extends ConsumerWidget {
  const PrayerDetailScreen({required this.prayerId, super.key});

  final String prayerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerByIdProvider(prayerId));
    final favorites = ref.watch(favoritePrayerIdsProvider);

    return Scaffold(
      body: SafeArea(
        child: prayerState.when(
          loading: () => const AppLoading(label: 'Inapakia sala...'),
          error: (error, stackTrace) => _DetailMessage(
            title: 'Sala haikupatikana',
            message: 'Jaribu kurudi kwenye maktaba ya sala.',
            onBack: () => context.pop(),
          ),
          data: (prayer) {
            if (prayer == null) {
              return _DetailMessage(
                title: 'Sala haikupatikana',
                message: 'Jaribu kuchagua sala nyingine.',
                onBack: () => context.pop(),
              );
            }

            final isFavorite = favorites.contains(prayer.id);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Rudi',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Badili lugha',
                        onPressed: () {},
                        icon: const Icon(Icons.translate_outlined),
                      ),
                      IconButton(
                        tooltip: 'Shiriki',
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                      ),
                      IconButton(
                        tooltip: isFavorite ? 'Ondoa kipendwa' : 'Hifadhi',
                        onPressed: () => _toggleFavorite(ref, prayer.id),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    children: [
                      Text(
                        prayer.categoryLabel().toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.mutedText,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        prayer.title(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          _TextSizeChip(label: 'A-', selected: false),
                          _TextSizeChip(label: 'A', selected: true),
                          _TextSizeChip(label: 'A+', selected: false),
                        ],
                      ),
                      const SizedBox(height: 24),
                      PrayerTextView(text: prayer.text()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref, String prayerId) {
    ref.read(favoritePrayerIdsProvider.notifier).toggle(prayerId);
  }
}

class _TextSizeChip extends StatelessWidget {
  const _TextSizeChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(right: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.nightPanelAlt : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected ? AppColors.text : AppColors.primary,
        ),
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({
    required this.title,
    required this.message,
    required this.onBack,
  });

  final String title;
  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: title,
      message: message,
      actionLabel: 'Rudi',
      onAction: onBack,
    );
  }
}
