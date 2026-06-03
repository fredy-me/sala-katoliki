import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/novena_model.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/prayer_text_view.dart';
import '../providers/novena_providers.dart';

class NovenaDayScreen extends ConsumerWidget {
  const NovenaDayScreen({required this.novenaId, required this.day, super.key});

  final String novenaId;
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _NovenaDayStrings(languageCode);
    final novenaState = ref.watch(novenaByIdProvider(novenaId));
    final progress = ref.watch(novenaProgressProvider).asData?.value;

    return Scaffold(
      body: SafeArea(
        child: novenaState.when(
          loading: () => AppLoading(label: strings.loading),
          error: (error, stackTrace) => AppErrorState(
            title: strings.errorTitle,
            message: strings.errorMessage,
            actionLabel: strings.back,
            onAction: () => context.pop(),
          ),
          data: (novena) {
            if (novena == null || day < 1 || day > novena.days.length) {
              return AppErrorState(
                title: strings.missingTitle,
                message: strings.missingMessage,
                actionLabel: strings.back,
                onAction: () => context.pop(),
              );
            }

            final dayContent = novena.days.firstWhere(
              (item) => item.day == day,
            );
            final completed =
                progress?.activeNovenaId == novenaId &&
                (progress?.completedDays.contains(day) ?? false);

            return Column(
              children: [
                _TopBar(
                  title: novena.title,
                  backLabel: strings.back,
                  onBack: () => context.pop(),
                ),
                const Divider(height: 1, color: AppColors.border),
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
                        strings.dayLabel(day),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        dayContent.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppCard(child: PrayerTextView(text: dayContent.body)),
                      if (novena.source != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        AppCard(
                          backgroundColor: AppColors.surfaceWarm,
                          child: Text(
                            novena.source!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _CompleteBar(
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
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.backLabel,
    required this.onBack,
  });

  final String title;
  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            tooltip: backLabel,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.minTouchTarget),
        ],
      ),
    );
  }
}

class _CompleteBar extends StatelessWidget {
  const _CompleteBar({
    required this.completed,
    required this.strings,
    required this.onComplete,
  });

  final bool completed;
  final _NovenaDayStrings strings;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: FilledButton.icon(
          onPressed: onComplete,
          icon: Icon(completed ? Icons.check : Icons.check_circle_outline),
          label: Text(completed ? strings.completed : strings.markComplete),
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
  String get markComplete => _sw ? 'Weka Imekamilika' : 'Mark Complete';
  String get completed => _sw ? 'Imekamilika' : 'Completed';
  String dayLabel(int day) => _sw ? 'Siku ya $day' : 'Day $day';
  String get errorTitle => _sw ? 'Siku haijapakia' : 'Day did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma siku hii ya novena.'
      : 'There was a problem reading this novena day.';
  String get missingTitle => _sw ? 'Siku haikupatikana' : 'Day not found';
  String get missingMessage => _sw
      ? 'Siku hii haipo kwenye novena hii.'
      : 'This day is not available in this novena.';
}
