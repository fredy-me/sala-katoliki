import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../data/models/novena_model.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/novena_state.dart';
import '../providers/novena_providers.dart';

class NovenaDetailScreen extends ConsumerWidget {
  const NovenaDetailScreen({required this.novenaId, super.key});

  final String novenaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = AppStrings(languageCode);
    final sessionState = ref.watch(novenaSessionProvider(novenaId));

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        context.popOrGo('/novenas');
      },
      child: Scaffold(
        body: SafeArea(
          child: sessionState.when(
            loading: () => AppLoading(label: strings.novenaDetailLoading),
            error: (error, stackTrace) => AppErrorState(
              title: strings.novenaDetailErrorTitle,
              message: strings.novenaDetailErrorMessage,
              actionLabel: strings.novenaDetailBack,
              onAction: () => context.popOrGo('/novenas'),
            ),
            data: (session) {
              if (session == null) {
                return AppErrorState(
                  title: strings.novenaDetailMissingTitle,
                  message: strings.novenaDetailMissingMessage,
                  actionLabel: strings.novenaDetailBack,
                  onAction: () => context.popOrGo('/novenas'),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.screenBottom,
                ),
                children: [
                  _Header(
                    title: session.novena.title,
                    backLabel: strings.novenaDetailBack,
                    onBack: () => context.popOrGo('/novenas'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ProgressPanel(
                    session: session,
                    strings: strings,
                    onStart: () => _start(context, ref, session),
                    onContinue: () => _continue(context, ref, session),
                    onRestart: () => _restart(context, ref, session.novena.id),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    session.novena.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  for (final day in session.novena.days) ...[
                    _DayRow(
                      day: day,
                      status: session.statusForDay(day.day),
                      strings: strings,
                      onTap: session.canOpenDay(day.day)
                          ? () => context.push(
                              '/novenas/${session.novena.id}/day/${day.day}',
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (session.novena.thanksgivingSection?.afterDay ==
                        day.day) ...[
                      _ThanksgivingSectionRow(
                        section: session.novena.thanksgivingSection!,
                        onTap: () => context.push(
                          '/novenas/${session.novena.id}/thanksgiving',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                  if (session.novena.closingPrayer != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _ClosingPrayerCard(
                      title: session.novena.closingPrayer!.title,
                      description: session.novena.closingPrayer!.description,
                      strings: strings,
                      onTap: () => context.push(
                        '/novenas/${session.novena.id}/closing-prayer',
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    NovenaSession session,
  ) async {
    final novenaId = session.novena.id;
    final nextDay = session.nextDay;
    await ref.read(novenaProgressProvider.notifier).start(novenaId);
    if (context.mounted) {
      context.push('/novenas/$novenaId/day/$nextDay');
    }
  }

  Future<void> _restart(
    BuildContext context,
    WidgetRef ref,
    String novenaId,
  ) async {
    await ref.read(novenaProgressProvider.notifier).restart(novenaId);
    if (context.mounted) {
      context.push('/novenas/$novenaId/day/1');
    }
  }

  Future<void> _continue(
    BuildContext context,
    WidgetRef ref,
    NovenaSession session,
  ) async {
    await ref.read(novenaProgressProvider.notifier).start(session.novena.id);
    if (context.mounted) {
      context.push('/novenas/${session.novena.id}/day/${session.nextDay}');
    }
  }
}

class _ClosingPrayerCard extends StatelessWidget {
  const _ClosingPrayerCard({
    required this.title,
    required this.description,
    required this.strings,
    required this.onTap,
  });

  final String title;
  final String description;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: AppSpacing.radiusXl,
      borderColor: AppColors.gold,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.goldSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_list_bulleted,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.novenaDetailAfterNovena,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.backLabel,
    required this.onBack,
  });

  final String title;
  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: backLabel,
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
      ],
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.session,
    required this.strings,
    required this.onStart,
    required this.onContinue,
    required this.onRestart,
  });

  final NovenaSession session;
  final AppStrings strings;
  final VoidCallback onStart;
  final VoidCallback onContinue;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final started = session.hasStarted;
    final nextDay = session.nextDay;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      started
                          ? strings.novenaDetailProgress
                          : strings.novenaDetailNotStarted,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      started
                          ? strings.novenaDetailDayProgress(
                              nextDay,
                              session.totalDays,
                            )
                          : strings.novenaDetailStartPrompt,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary),
                ),
                child: Text(
                  '$nextDay',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LinearProgressIndicator(
            value: started ? session.completionRatio : 0,
            minHeight: 4,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: started ? onContinue : onStart,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  child: Text(
                    started
                        ? strings.novenaDetailContinueDay(nextDay)
                        : strings.novenaDetailStart,
                  ),
                ),
              ),
              if (started) ...[
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: onRestart,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  child: Text(strings.novenaDetailRestart),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.status,
    required this.strings,
    required this.onTap,
  });

  final NovenaDayModel day;
  final NovenaDayStatus status;
  final AppStrings strings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      NovenaDayStatus.completed => AppColors.success,
      NovenaDayStatus.current => AppColors.gold,
      NovenaDayStatus.open => Theme.of(context).colorScheme.primary,
      NovenaDayStatus.locked => Theme.of(context).colorScheme.onSurfaceVariant,
      NovenaDayStatus.notStarted => Theme.of(
        context,
      ).colorScheme.onSurfaceVariant,
    };
    final icon = switch (status) {
      NovenaDayStatus.completed => Icons.check,
      NovenaDayStatus.current => Icons.radio_button_checked,
      NovenaDayStatus.open => Icons.menu_book_outlined,
      NovenaDayStatus.locked => Icons.lock_outline,
      NovenaDayStatus.notStarted => Icons.lock_open_outlined,
    };

    return AppCard(
      onTap: onTap,
      borderColor: status == NovenaDayStatus.current ? AppColors.gold : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _statusLabel(strings, status),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _ThanksgivingSectionRow extends StatelessWidget {
  const _ThanksgivingSectionRow({required this.section, required this.onTap});

  final NovenaThanksgivingSectionModel section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      backgroundColor: Theme.of(context).colorScheme.surface,
      borderColor: AppColors.gold,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.volunteer_activism, color: AppColors.navy),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  section.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

String _statusLabel(AppStrings strings, NovenaDayStatus status) =>
    switch (status) {
      NovenaDayStatus.completed => strings.novenaDetailStatusCompleted,
      NovenaDayStatus.current => strings.novenaDetailStatusCurrent,
      NovenaDayStatus.open => strings.novenaDetailStatusOpen,
      NovenaDayStatus.locked => strings.novenaDetailStatusLocked,
      NovenaDayStatus.notStarted => strings.novenaDetailStatusNotStarted,
    };
