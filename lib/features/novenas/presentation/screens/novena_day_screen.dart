import 'package:salakatoliki/core/localization/app_strings.dart';
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

  /// 4.5: the scale lives in a notifier rather than in this State's `setState`,
  /// so tapping A- / A / A+ rebuilds only the chip row and the day text
  /// instead of the entire day screen.
  final ValueNotifier<double> _textScale = ValueNotifier<double>(
    _defaultTextScale,
  );

  @override
  void dispose() {
    _textScale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = AppStrings(languageCode);
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
            loading: () => AppLoading(label: strings.novenaDayLoading),
            error: (error, stackTrace) => AppErrorState(
              title: strings.novenaDayErrorTitle,
              message: strings.novenaDayErrorMessage,
              actionLabel: strings.novenaDayBack,
              onAction: () => context.popOrGo('/novenas/${widget.novenaId}'),
            ),
            data: (novena) {
              if (novena == null ||
                  widget.day < 1 ||
                  widget.day > novena.days.length) {
                return AppErrorState(
                  title: strings.novenaDayMissingTitle,
                  message: strings.novenaDayMissingMessage,
                  actionLabel: strings.novenaDayBack,
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
                          strings.novenaDayDayProgress(
                            widget.day,
                            novena.days.length,
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(letterSpacing: 1.6),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          novena.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ValueListenableBuilder<double>(
                          valueListenable: _textScale,
                          builder: (context, textScale, _) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    _TextSizeChip(
                                      label: 'A-',
                                      selected: textScale < _defaultTextScale,
                                      onPressed: _decreaseTextSize,
                                    ),
                                    _TextSizeChip(
                                      label: 'A',
                                      selected: textScale == _defaultTextScale,
                                      onPressed: _resetTextSize,
                                    ),
                                    _TextSizeChip(
                                      label: 'A+',
                                      selected: textScale > _defaultTextScale,
                                      onPressed: _increaseTextSize,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                NovenaTextView(
                                  text: dayContent.readingText,
                                  fontScale: textScale,
                                  allSaintsStyle: novena.usesAllSaintsStyle,
                                  holySpiritStyle: novena.usesHolySpiritStyle,
                                  stRitaStyle: novena.usesStRitaStyle,
                                ),
                              ],
                            );
                          },
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
    AppStrings strings,
  ) async {
    final nextLanguageCode = activeLanguageCode == 'sw' ? 'en' : 'sw';
    await ref
        .read(selectedLanguageProvider.notifier)
        .selectLanguage(nextLanguageCode);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.novenaDayLanguageChanged(nextLanguageCode)),
      ),
    );
  }

  Future<void> _shareNovenaDay({
    required NovenaModel novena,
    required String dayTitle,
    required String dayBody,
    required AppStrings strings,
  }) async {
    final shareText =
        '${novena.title}\n\n${strings.novenaDayDayProgress(widget.day, novena.days.length)}: '
        '$dayTitle\n\n$dayBody\n\n${strings.novenaDaySource}: Sala Katoliki App';

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
      ).showSnackBar(SnackBar(content: Text(strings.novenaDayShareFailed)));
    }
  }

  void _decreaseTextSize() {
    _textScale.value = (_textScale.value - _textScaleStep).clamp(
      _minTextScale,
      _maxTextScale,
    );
  }

  void _resetTextSize() {
    _textScale.value = _defaultTextScale;
  }

  void _increaseTextSize() {
    _textScale.value = (_textScale.value + _textScaleStep).clamp(
      _minTextScale,
      _maxTextScale,
    );
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

  final AppStrings strings;
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
            tooltip: strings.novenaDayBack,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          IconButton(
            tooltip: strings.novenaDayChangeLanguage,
            onPressed: onToggleLanguage,
            icon: const Icon(Icons.translate_outlined),
          ),
          IconButton(
            tooltip: strings.novenaDayShare,
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: isFavorite
                ? strings.novenaDayRemoveFavorite
                : strings.novenaDaySaveFavorite,
            onPressed: onToggleFavorite,
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
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
  final AppStrings strings;
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
                  completed
                      ? strings.novenaDayCompleted
                      : strings.novenaDayCompleteDay(day),
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
