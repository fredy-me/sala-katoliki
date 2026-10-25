import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/rosary_model.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/rosary_providers.dart';

class RosaryScreen extends ConsumerWidget {
  const RosaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = AppStrings(languageCode);
    final mysteriesState = ref.watch(rosaryMysteriesProvider);
    final suggestedState = ref.watch(suggestedRosaryMysteryProvider);
    final activeSessionState = ref.watch(activeRosarySessionProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        _goBack(context);
      },
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: mysteriesState.when(
            loading: () => AppLoading(label: strings.rosaryLoading),
            error: (error, stackTrace) => AppErrorState(
              title: strings.rosaryLoadErrorTitle,
              message: strings.rosaryLoadErrorMessage,
              actionLabel: strings.rosaryRetry,
              onAction: () {
                ref.invalidate(rosaryMysteriesProvider);
                ref.invalidate(suggestedRosaryMysteryProvider);
              },
            ),
            data: (mysteries) {
              if (mysteries.isEmpty) {
                return AppEmptyState(
                  title: strings.rosaryEmptyTitle,
                  message: strings.rosaryEmptyMessage,
                  icon: Icons.radio_button_checked,
                );
              }

              final suggested = suggestedState.asData?.value ?? mysteries.first;
              final activeSession = activeSessionState.asData?.value;

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.screenTop,
                  AppSpacing.screenHorizontal,
                  AppSpacing.screenBottom,
                ),
                children: [
                  Text(
                    strings.rosaryTitle,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    strings.rosarySubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _TodayMysteryCard(
                    mystery: suggested,
                    strings: strings,
                    onStart: () => _startRosary(context, ref, suggested.id),
                    onSelect: () => context.push('/rosary/select'),
                  ),
                  if (activeSession != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _ContinueCard(
                      mystery: activeSession.mystery,
                      progress: activeSession.progress,
                      stepLabel: strings.rosaryStepLabel(
                        activeSession.stepIndex + 1,
                        activeSession.steps.length,
                      ),
                      strings: strings,
                      onContinue: () => context.push(
                        '/rosary/step/${activeSession.mystery.id}',
                      ),
                      onRestart: () =>
                          _startRosary(context, ref, activeSession.mystery.id),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.section),
                  SectionHeader(title: strings.rosaryAllMysteries),
                  const SizedBox(height: AppSpacing.md),
                  for (final mystery in mysteries) ...[
                    _MysteryRow(
                      mystery: mystery,
                      isSuggested: mystery.id == suggested.id,
                      strings: strings,
                      onTap: () => _startRosary(context, ref, mystery.id),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _startRosary(
    BuildContext context,
    WidgetRef ref,
    String mysteryId,
  ) async {
    await ref.read(rosaryProgressProvider.notifier).start(mysteryId);
    if (context.mounted) {
      context.push('/rosary/step/$mysteryId');
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/today');
  }
}

class _TodayMysteryCard extends StatelessWidget {
  const _TodayMysteryCard({
    required this.mystery,
    required this.strings,
    required this.onStart,
    required this.onSelect,
  });

  final RosaryMysteryModel mystery;
  final AppStrings strings;
  final VoidCallback onStart;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppSpacing.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.rosaryTodayMystery,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mystery.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mystery.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: Text(strings.rosaryStart),
              ),
              OutlinedButton.icon(
                onPressed: onSelect,
                icon: const Icon(Icons.grid_view),
                label: Text(strings.rosaryChoose),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.mystery,
    required this.progress,
    required this.stepLabel,
    required this.strings,
    required this.onContinue,
    required this.onRestart,
  });

  final RosaryMysteryModel mystery;
  final double progress;
  final String stepLabel;
  final AppStrings strings;
  final VoidCallback onContinue;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.rosarySavedProgress,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(mystery.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(stepLabel, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onContinue,
                  child: Text(strings.rosaryContinueLabel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                tooltip: strings.rosaryRestart,
                onPressed: onRestart,
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MysteryRow extends StatelessWidget {
  const _MysteryRow({
    required this.mystery,
    required this.isSuggested,
    required this.strings,
    required this.onTap,
  });

  final RosaryMysteryModel mystery;
  final bool isSuggested;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.goldSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.radio_button_checked,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mystery.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isSuggested
                      ? strings.rosarySuggestedToday
                      : mystery.description,
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
