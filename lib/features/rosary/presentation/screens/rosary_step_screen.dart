import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/prayer_text_view.dart';
import '../../domain/rosary_state.dart';
import '../providers/rosary_providers.dart';

class RosaryStepScreen extends ConsumerWidget {
  const RosaryStepScreen({required this.mysteryId, super.key});

  final String mysteryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _RosaryStepStrings(languageCode);
    final sessionState = ref.watch(rosarySessionProvider(mysteryId));

    return Scaffold(
      body: SafeArea(
        child: sessionState.when(
          loading: () => AppLoading(label: strings.loading),
          error: (error, stackTrace) => AppErrorState(
            title: strings.errorTitle,
            message: strings.errorMessage,
            actionLabel: strings.back,
            onAction: () => _goBack(context),
          ),
          data: (session) {
            if (session == null) {
              return AppErrorState(
                title: strings.missingTitle,
                message: strings.missingMessage,
                actionLabel: strings.back,
                onAction: () => _goBack(context),
              );
            }

            final step = session.currentStep;

            return Column(
              children: [
                _TopBar(
                  title: session.mystery.title,
                  strings: strings,
                  onBack: () => _goBack(context),
                  onRestart: () => _restart(context, ref),
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
                      _ProgressHeader(session: session, strings: strings),
                      const SizedBox(height: AppSpacing.xl),
                      _BeadProgress(step: step),
                      const SizedBox(height: AppSpacing.xl),
                      if (step.mysteryTitle != null) ...[
                        Text(
                          step.mysteryTitle!,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.prayer.title(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PrayerTextView(text: step.prayer.text()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _StepControls(
                  session: session,
                  strings: strings,
                  onPrevious: () => _move(ref, session, session.stepIndex - 1),
                  onPause: () => context.go('/rosary'),
                  onNext: () => _next(context, ref, session),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _move(
    WidgetRef ref,
    RosarySession session,
    int stepIndex,
  ) async {
    await ref
        .read(rosaryProgressProvider.notifier)
        .save(mysteryId: session.mystery.id, stepIndex: stepIndex);
  }

  Future<void> _next(
    BuildContext context,
    WidgetRef ref,
    RosarySession session,
  ) async {
    if (session.canGoNext) {
      await _move(ref, session, session.stepIndex + 1);
      return;
    }

    await ref.read(rosaryProgressProvider.notifier).clear();
    if (context.mounted) {
      context.go('/rosary');
    }
  }

  Future<void> _restart(BuildContext context, WidgetRef ref) async {
    await ref.read(rosaryProgressProvider.notifier).start(mysteryId);
    ref.invalidate(rosarySessionProvider(mysteryId));
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/rosary');
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.strings,
    required this.onBack,
    required this.onRestart,
  });

  final String title;
  final _RosaryStepStrings strings;
  final VoidCallback onBack;
  final VoidCallback onRestart;

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
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: strings.restart,
            onPressed: onRestart,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.session, required this.strings});

  final RosarySession session;
  final _RosaryStepStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.stepLabel(session.stepIndex + 1, session.steps.length),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: session.progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
      ],
    );
  }
}

class _BeadProgress extends StatelessWidget {
  const _BeadProgress({required this.step});

  final RosaryStep step;

  @override
  Widget build(BuildContext context) {
    final label = step.isIntro
        ? 'Intro'
        : 'Decade ${step.decadeIndex} - ${step.beadNumber}/${step.beadTotal}';

    return AppCard(
      backgroundColor: AppColors.surfaceWarm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (var index = 1; index <= step.beadTotal; index += 1)
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: index <= step.beadNumber
                        ? AppColors.gold
                        : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepControls extends StatelessWidget {
  const _StepControls({
    required this.session,
    required this.strings,
    required this.onPrevious,
    required this.onPause,
    required this.onNext,
  });

  final RosarySession session;
  final _RosaryStepStrings strings;
  final VoidCallback onPrevious;
  final VoidCallback onPause;
  final VoidCallback onNext;

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
        child: Row(
          children: [
            IconButton(
              tooltip: strings.previous,
              onPressed: session.canGoPrevious ? onPrevious : null,
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              tooltip: strings.pause,
              onPressed: onPause,
              icon: const Icon(Icons.pause),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: onNext,
                icon: Icon(
                  session.canGoNext ? Icons.chevron_right : Icons.check,
                ),
                label: Text(session.canGoNext ? strings.next : strings.finish),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RosaryStepStrings {
  const _RosaryStepStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia hatua...' : 'Loading step...';
  String get back => _sw ? 'Rudi' : 'Back';
  String get restart => _sw ? 'Anza Upya' : 'Restart';
  String get previous => _sw ? 'Iliyotangulia' : 'Previous';
  String get pause => _sw ? 'Sitisha' : 'Pause';
  String get next => _sw ? 'Inayofuata' : 'Next';
  String get finish => _sw ? 'Maliza' : 'Finish';
  String get errorTitle => _sw ? 'Rozari haijapakia' : 'Rosary did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma hatua za rozari.'
      : 'There was a problem reading Rosary steps.';
  String get missingTitle =>
      _sw ? 'Maendeleo yameondolewa' : 'Progress was reset';
  String get missingMessage => _sw
      ? 'Maendeleo ya zamani hayakulingana na maudhui ya sasa.'
      : 'Saved progress did not match the current Rosary content.';
  String stepLabel(int current, int total) =>
      _sw ? 'Hatua $current kati ya $total' : 'Step $current of $total';
}
