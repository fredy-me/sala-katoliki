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
    final strings = _RosaryStrings(languageCode);
    final mysteriesState = ref.watch(rosaryMysteriesProvider);
    final suggestedState = ref.watch(suggestedRosaryMysteryProvider);
    final activeSessionState = ref.watch(activeRosarySessionProvider);

    return mysteriesState.when(
      loading: () => AppLoading(label: strings.loading),
      error: (error, stackTrace) => AppErrorState(
        title: strings.loadErrorTitle,
        message: strings.loadErrorMessage,
        actionLabel: strings.retry,
        onAction: () {
          ref.invalidate(rosaryMysteriesProvider);
          ref.invalidate(suggestedRosaryMysteryProvider);
        },
      ),
      data: (mysteries) {
        if (mysteries.isEmpty) {
          return AppEmptyState(
            title: strings.emptyTitle,
            message: strings.emptyMessage,
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
              strings.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings.subtitle,
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
                stepLabel: strings.stepLabel(
                  activeSession.stepIndex + 1,
                  activeSession.steps.length,
                ),
                strings: strings,
                onContinue: () =>
                    context.push('/rosary/step/${activeSession.mystery.id}'),
                onRestart: () =>
                    _startRosary(context, ref, activeSession.mystery.id),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            SectionHeader(title: strings.allMysteries),
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
}

class _TodayMysteryCard extends StatelessWidget {
  const _TodayMysteryCard({
    required this.mystery,
    required this.strings,
    required this.onStart,
    required this.onSelect,
  });

  final RosaryMysteryModel mystery;
  final _RosaryStrings strings;
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
            strings.todayMystery,
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
                label: Text(strings.start),
              ),
              OutlinedButton.icon(
                onPressed: onSelect,
                icon: const Icon(Icons.grid_view),
                label: Text(strings.choose),
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
  final _RosaryStrings strings;
  final VoidCallback onContinue;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.savedProgress,
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
                  child: Text(strings.continueLabel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                tooltip: strings.restart,
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
  final _RosaryStrings strings;
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
                  isSuggested ? strings.suggestedToday : mystery.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.mutedText),
        ],
      ),
    );
  }
}

class _RosaryStrings {
  const _RosaryStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Rozari Takatifu' : 'Holy Rosary';
  String get subtitle => _sw
      ? 'Fuata mafumbo na sala hatua kwa hatua.'
      : 'Pray the mysteries step by step.';
  String get loading => _sw ? 'Inapakia rozari...' : 'Loading Rosary...';
  String get todayMystery => _sw ? 'Fumbo la Leo' : "Today's Mystery";
  String get start => _sw ? 'Anza' : 'Start';
  String get choose => _sw ? 'Chagua' : 'Choose';
  String get savedProgress =>
      _sw ? 'Maendeleo Yaliyohifadhiwa' : 'Saved Progress';
  String get continueLabel => _sw ? 'Endelea' : 'Continue';
  String get restart => _sw ? 'Anza Upya' : 'Restart';
  String get allMysteries => _sw ? 'Mafumbo Yote' : 'All Mysteries';
  String get suggestedToday => _sw ? 'Limependekezwa leo' : 'Suggested today';
  String stepLabel(int current, int total) =>
      _sw ? 'Hatua $current kati ya $total' : 'Step $current of $total';
  String get retry => _sw ? 'Jaribu tena' : 'Retry';
  String get loadErrorTitle =>
      _sw ? 'Rozari haijapakia' : 'Rosary did not load';
  String get loadErrorMessage => _sw
      ? 'Kuna tatizo kusoma maudhui ya rozari ya ndani.'
      : 'There was a problem reading local Rosary content.';
  String get emptyTitle =>
      _sw ? 'Hakuna maudhui ya rozari' : 'No Rosary content';
  String get emptyMessage => _sw
      ? 'Mafumbo ya rozari hayajapatikana kwenye maudhui ya ndani.'
      : 'Rosary mysteries were not found in local content.';
}
