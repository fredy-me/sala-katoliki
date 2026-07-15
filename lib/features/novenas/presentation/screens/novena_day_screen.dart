import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../data/models/novena_model.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/novena_text_view.dart';
import '../providers/novena_providers.dart';

class NovenaDayScreen extends ConsumerStatefulWidget {
  const NovenaDayScreen({required this.novenaId, required this.day, super.key});

  final String novenaId;
  final int day;

  @override
  ConsumerState<NovenaDayScreen> createState() => _NovenaDayScreenState();
}

class _NovenaDayScreenState extends ConsumerState<NovenaDayScreen> {
  static const _defaultTextScale = 1.0;
  static const _minTextScale = 0.85;
  static const _maxTextScale = 1.3;
  static const _textScaleStep = 0.15;

  double _textScale = _defaultTextScale;

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _NovenaDayStrings(languageCode);
    final novenaState = ref.watch(novenaByIdProvider(widget.novenaId));
    final progress = ref.watch(novenaProgressProvider).asData?.value;
    final favoriteNovenaIds =
        ref.watch(favoriteNovenaIdsProvider).asData?.value ?? <String>{};

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        context.popOrGo('/novenas/${widget.novenaId}');
      },
      child: Scaffold(
        body: SafeArea(
          child: novenaState.when(
            loading: () => AppLoading(label: strings.loading),
            error: (error, stackTrace) => AppErrorState(
              title: strings.errorTitle,
              message: strings.errorMessage,
              actionLabel: strings.back,
              onAction: () => context.popOrGo('/novenas/${widget.novenaId}'),
            ),
            data: (novena) {
              if (novena == null ||
                  widget.day < 1 ||
                  widget.day > novena.days.length) {
                return AppErrorState(
                  title: strings.missingTitle,
                  message: strings.missingMessage,
                  actionLabel: strings.back,
                  onAction: () =>
                      context.popOrGo('/novenas/${widget.novenaId}'),
                );
              }

              final dayContent = novena.days.firstWhere(
                (item) => item.day == widget.day,
              );
              final completed =
                  progress?.isCompleted(widget.novenaId, widget.day) ?? false;
              final isFavorite = favoriteNovenaIds.contains(novena.id);

              return Column(
                children: [
                  _ActionBar(
                    strings: strings,
                    isFavorite: isFavorite,
                    onBack: () =>
                        context.popOrGo('/novenas/${widget.novenaId}'),
                    onToggleLanguage: () =>
                        _toggleLanguage(languageCode, strings),
                    onShare: () => _shareNovenaDay(
                      novena: novena,
                      dayTitle: dayContent.title,
                      dayBody: dayContent.body,
                      strings: strings,
                    ),
                    onToggleFavorite: () => ref
                        .read(favoriteNovenaIdsProvider.notifier)
                        .toggle(novena.id),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerTheme.color,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        AppSpacing.xl,
                        AppSpacing.screenHorizontal,
                        AppSpacing.screenBottom,
                      ),
                      children: [
                        Text(
                          strings.dayProgress(
                            widget.day,
                            novena.days.length,
                          ),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(letterSpacing: 1.6),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          novena.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xl),
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
                        const SizedBox(height: AppSpacing.lg),
                        NovenaTextView(
                          text: dayContent.body,
                          showContainer: false,
                          fontScale: _textScale,
                          allSaintsStyle: novena.id == 'all_saints_day_novena' ||
                              novena.id == 'divine_mercy_novena' ||
                              novena.id == 'holy_family_novena' ||
                              novena.id == 'holy_spirit_novena' ||
                              novena.id == 'litany_of_trust_novena' ||
                              novena.id == 'sacred_heart_of_jesus_novena' ||
                              novena.id == 'st_aloysius_gonzaga_novena' ||
                              novena.id == 'st_jude_novena' ||
                              novena.id == 'st_rita_novena',
                          holySpiritStyle: novena.id == 'holy_spirit_novena',
                          stRitaStyle: novena.id == 'st_rita_novena',
                        ),
                      ],
                    ),
                  ),
                  _CompleteBar(
                    day: widget.day,
                    completed: completed,
                    strings: strings,
                    onComplete: completed
                        ? null
                        : () => _complete(context, ref, novena, dayContent.day),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    NovenaModel novena,
    int day,
  ) async {
    await ref.read(novenaProgressProvider.notifier).completeDay(novena.id, day);
    if (context.mounted) {
      context.go('/novenas/${novena.id}');
    }
  }

  Future<void> _toggleLanguage(
    String activeLanguageCode,
    _NovenaDayStrings strings,
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

  Future<void> _shareNovenaDay({
    required NovenaModel novena,
    required String dayTitle,
    required String dayBody,
    required _NovenaDayStrings strings,
  }) async {
    final shareText =
        '${novena.title}\n\n${strings.dayProgress(widget.day, novena.days.length)}: '
        '$dayTitle\n\n$dayBody\n\n${strings.source}: Sala Katoliki App';

    try {
      await SharePlus.instance.share(
        ShareParams(text: shareText, subject: novena.title),
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
    setState(() => _textScale = _defaultTextScale);
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.strings,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleLanguage,
    required this.onShare,
    required this.onToggleFavorite,
  });

  final _NovenaDayStrings strings;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onToggleLanguage;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            tooltip: strings.back,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          IconButton(
            tooltip: strings.changeLanguage,
            onPressed: onToggleLanguage,
            icon: const Icon(Icons.translate_outlined),
          ),
          IconButton(
            tooltip: strings.share,
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: isFavorite ? strings.removeFavorite : strings.saveFavorite,
            onPressed: onToggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.only(right: AppSpacing.sm),
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

class _CompleteBar extends StatelessWidget {
  const _CompleteBar({
    required this.day,
    required this.completed,
    required this.strings,
    required this.onComplete,
  });

  final int day;
  final bool completed;
  final _NovenaDayStrings strings;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.sm,
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onComplete,
                icon: Icon(
                  completed ? Icons.check : Icons.check_circle_outline,
                  size: 18,
                ),
                label: Text(
                  completed ? strings.completed : strings.completeDay(day),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NovenaDayStrings {
  const _NovenaDayStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia siku...' : 'Loading day...';
  String get back => _sw ? 'Rudi' : 'Back';
  String completeDay(int day) =>
      _sw ? 'Nimemaliza Siku $day' : 'Complete Day $day';
  String get completed => _sw ? 'Imekamilika' : 'Completed';
  String dayLabel(int day) => _sw ? 'Siku ya $day' : 'Day $day';
  String dayProgress(int day, int totalDays) =>
      _sw ? 'Siku ya $day kati ya $totalDays' : 'Day $day of $totalDays';
  String get changeLanguage => _sw ? 'Badili lugha' : 'Change language';
  String get share => _sw ? 'Shiriki' : 'Share';
  String get removeFavorite => _sw ? 'Ondoa kipendwa' : 'Remove favorite';
  String get saveFavorite => _sw ? 'Hifadhi' : 'Save';
  String get source => _sw ? 'Chanzo' : 'Source';
  String get shareFailed => _sw
      ? 'Imeshindikana kushiriki novena hii.'
      : 'Could not share this novena.';
  String get errorTitle => _sw ? 'Siku haijapakia' : 'Day did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma siku hii ya novena.'
      : 'There was a problem reading this novena day.';
  String get missingTitle => _sw ? 'Siku haikupatikana' : 'Day not found';
  String get missingMessage => _sw
      ? 'Siku hii haipo kwenye novena hii.'
      : 'This day is not available in this novena.';

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
