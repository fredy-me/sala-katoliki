import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/prayer_text_view.dart';
import '../../domain/entities/prayer_entity.dart';
import '../providers/prayer_providers.dart';

class PrayerDetailScreen extends ConsumerStatefulWidget {
  const PrayerDetailScreen({required this.prayerId, super.key});

  final String prayerId;

  @override
  ConsumerState<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends ConsumerState<PrayerDetailScreen> {
  static const _defaultTextScale = 1.0;
  static const _minTextScale = 0.85;
  static const _maxTextScale = 1.3;
  static const _textScaleStep = 0.15;

  double _textScale = _defaultTextScale;

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerByIdProvider(widget.prayerId));
    final activeLanguageCode = ref.watch(activeLanguageProvider);
    final favorites =
        ref.watch(favoritePrayerIdsProvider).asData?.value ?? <String>{};

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

            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(recentPrayerIdsProvider.notifier).record(prayer.id);
            });

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
                        onPressed: () => _toggleLanguage(activeLanguageCode),
                        icon: const Icon(Icons.translate_outlined),
                      ),
                      IconButton(
                        tooltip: 'Shiriki',
                        onPressed: () => _sharePrayer(prayer),
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
                Divider(height: 1, color: Theme.of(context).dividerTheme.color),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    children: [
                      Text(
                        prayer.categoryLabel().toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
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
                          _TextSizeChip(
                            label: 'A-',
                            selected: _textScale < _defaultTextScale,
                            onPressed: _decreaseTextSize,
                          ),
                          _TextSizeChip(
                            label: 'A',
                            selected: _textScale == _defaultTextScale,
                            onPressed: _resetTextSize,
                          ),
                          _TextSizeChip(
                            label: 'A+',
                            selected: _textScale > _defaultTextScale,
                            onPressed: _increaseTextSize,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      PrayerTextView(
                        text: prayer.text(),
                        fontScale: _textScale,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Source',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              prayer.source?.trim().isNotEmpty == true
                                  ? prayer.source!
                                  : 'Traditional Catholic Prayer',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
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

  Future<void> _toggleLanguage(String activeLanguageCode) async {
    final nextLanguageCode = activeLanguageCode == 'sw' ? 'en' : 'sw';
    await ref
        .read(selectedLanguageProvider.notifier)
        .selectLanguage(nextLanguageCode);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextLanguageCode == 'sw'
              ? 'Lugha imebadilishwa kwenda Kiswahili.'
              : 'Language changed to English.',
        ),
      ),
    );
  }

  Future<void> _sharePrayer(PrayerEntity prayer) async {
    final source = prayer.source?.trim().isNotEmpty == true
        ? prayer.source!
        : 'Traditional Catholic Prayer';
    final shareText =
        '${prayer.title()}\n\n${prayer.text()}\n\nSource: $source';

    try {
      await SharePlus.instance.share(
        ShareParams(text: shareText, subject: prayer.title()),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imeshindikana kushiriki sala hii.')),
      );
    }
  }

  void _decreaseTextSize() {
    setState(() {
      _textScale = (_textScale - _textScaleStep).clamp(
        _minTextScale,
        _maxTextScale,
      );
    });
  }

  void _resetTextSize() {
    setState(() {
      _textScale = _defaultTextScale;
    });
  }

  void _increaseTextSize() {
    setState(() {
      _textScale = (_textScale + _textScaleStep).clamp(
        _minTextScale,
        _maxTextScale,
      );
    });
  }
}

class _TextSizeChip extends StatelessWidget {
  const _TextSizeChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
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
