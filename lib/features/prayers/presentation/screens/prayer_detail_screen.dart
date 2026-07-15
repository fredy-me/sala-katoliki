import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/litany_text_view.dart';
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
    final strings = _PrayerDetailStrings(activeLanguageCode);
    final favorites =
        ref.watch(favoritePrayerIdsProvider).asData?.value ?? <String>{};

    return Scaffold(
      body: SafeArea(
        child: prayerState.when(
          loading: () => AppLoading(label: strings.loading),
          error: (error, stackTrace) => _DetailMessage(
            title: strings.notFoundTitle,
            message: strings.loadErrorMessage,
            actionLabel: strings.back,
            onBack: () => context.popOrGo('/prayers'),
          ),
          data: (prayer) {
            if (prayer == null) {
              return _DetailMessage(
                title: strings.notFoundTitle,
                message: strings.missingMessage,
                actionLabel: strings.back,
                onBack: () => context.popOrGo('/prayers'),
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
                        tooltip: strings.back,
                        onPressed: () => context.popOrGo('/prayers'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: strings.changeLanguage,
                        onPressed: () =>
                            _toggleLanguage(activeLanguageCode, strings),
                        icon: const Icon(Icons.translate_outlined),
                      ),
                      IconButton(
                        tooltip: strings.share,
                        onPressed: () => _sharePrayer(prayer, strings),
                        icon: const Icon(Icons.share_outlined),
                      ),
                      IconButton(
                        tooltip: isFavorite
                            ? strings.removeFavorite
                            : strings.saveFavorite,
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
                        prayer.categoryLabel(activeLanguageCode).toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        prayer.title(activeLanguageCode),
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
                      if (prayer.categoryId == 'litanies')
                        LitanyTextView(
                          text: prayer.text(activeLanguageCode),
                          fontScale: _textScale,
                          showContainer: false,
                          stRitaStyle: const {
                            'st_rita_litany',
                            'bikira_maria_litany',
                            'divine_mercy_litany',
                            'holy_spirit_litany',
                            'sacred_head_of_jesus_litany',
                            'st_aloysius_gonzaga_litany',
                            'st_jude_thaddeus_litany',
                            'st_joseph_litany',
                            'st_anthony_of_padua_litany_v1',
                            'st_anthony_of_padua_litany_v2',
                            'franciscan_st_anthony_litany',
                            'st_anne_litany',
                            'holy_angels_litany',
                          }.contains(prayer.id),
                        )
                      else
                        PrayerTextView(
                          text: prayer.text(activeLanguageCode),
                          fontScale: _textScale,
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

  Future<void> _toggleLanguage(
    String activeLanguageCode,
    _PrayerDetailStrings strings,
  ) async {
    final nextLanguageCode = activeLanguageCode == 'sw' ? 'en' : 'sw';
    await ref
        .read(selectedLanguageProvider.notifier)
        .selectLanguage(nextLanguageCode);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.languageChanged(nextLanguageCode))),
    );
  }

  Future<void> _sharePrayer(
    PrayerEntity prayer,
    _PrayerDetailStrings strings,
  ) async {
    final source = prayer.source?.trim().isNotEmpty == true
        ? prayer.source!
        : strings.defaultSource;
    final shareText =
        '${prayer.title()}\n\n${prayer.text()}\n\n${strings.source}: $source';

    try {
      await SharePlus.instance.share(
        ShareParams(text: shareText, subject: prayer.title()),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.shareFailed)));
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
    required this.actionLabel,
    required this.onBack,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onBack,
    );
  }
}

class _PrayerDetailStrings {
  const _PrayerDetailStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia sala...' : 'Loading prayer...';
  String get notFoundTitle => _sw ? 'Sala haikupatikana' : 'Prayer not found';
  String get loadErrorMessage => _sw
      ? 'Jaribu kurudi kwenye orodha ya sala.'
      : 'Try returning to the prayer list.';
  String get missingMessage =>
      _sw ? 'Jaribu kuchagua sala nyingine.' : 'Try choosing another prayer.';
  String get back => _sw ? 'Rudi' : 'Back';
  String get changeLanguage => _sw ? 'Badili lugha' : 'Change language';
  String get share => _sw ? 'Shiriki' : 'Share';
  String get removeFavorite => _sw ? 'Ondoa kipendwa' : 'Remove favorite';
  String get saveFavorite => _sw ? 'Hifadhi' : 'Save';
  String get source => _sw ? 'Chanzo' : 'Source';
  String get defaultSource =>
      _sw ? 'Sala ya kimapokeo ya Kikatoliki' : 'Traditional Catholic Prayer';
  String get shareFailed => _sw
      ? 'Imeshindikana kushiriki sala hii.'
      : 'Could not share this prayer.';

  String languageChanged(String nextLanguageCode) {
    if (nextLanguageCode == 'sw') {
      return _sw
          ? 'Lugha imebadilishwa kwenda Kiswahili.'
          : 'Language changed to Kiswahili.';
    }

    return _sw
        ? 'Lugha imebadilishwa kwenda Kiingereza.'
        : 'Language changed to English.';
  }
}
