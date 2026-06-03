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
import '../../domain/novena_state.dart';
import '../providers/novena_providers.dart';

class NovenaDetailScreen extends ConsumerWidget {
  const NovenaDetailScreen({required this.novenaId, super.key});

  final String novenaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _NovenaDetailStrings(languageCode);
    final sessionState = ref.watch(novenaSessionProvider(novenaId));

    return Scaffold(
      body: SafeArea(
        child: sessionState.when(
          loading: () => AppLoading(label: strings.loading),
          error: (error, stackTrace) => AppErrorState(
            title: strings.errorTitle,
            message: strings.errorMessage,
            actionLabel: strings.back,
            onAction: () => context.pop(),
          ),
          data: (session) {
            if (session == null) {
              return AppErrorState(
                title: strings.missingTitle,
                message: strings.missingMessage,
                actionLabel: strings.back,
                onAction: () => context.pop(),
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
                  backLabel: strings.back,
                  onBack: () => context.pop(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ProgressPanel(
                  session: session,
                  strings: strings,
                  onStart: () => _start(context, ref, session.novena.id),
                  onRestart: () => _start(context, ref, session.novena.id),
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
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    String novenaId,
  ) async {
    await ref.read(novenaProgressProvider.notifier).start(novenaId);
    if (context.mounted) {
      context.push('/novenas/$novenaId/day/1');
    }
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
    required this.onRestart,
  });

  final NovenaSession session;
  final _NovenaDetailStrings strings;
  final VoidCallback onStart;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final active = session.isActive;

    return AppCard(
      backgroundColor: active ? AppColors.surface : AppColors.surfaceWarm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            active ? strings.progress : strings.notStarted,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            active
                ? strings.dayProgress(session.progress.nextDay)
                : strings.startPrompt,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: active ? session.progress.completionRatio : 0,
            minHeight: 8,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: active ? onRestart : onStart,
            child: Text(active ? strings.restart : strings.start),
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
  final _NovenaDetailStrings strings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      NovenaDayStatus.completed => AppColors.success,
      NovenaDayStatus.current => AppColors.gold,
      NovenaDayStatus.open => AppColors.navy,
      NovenaDayStatus.locked => AppColors.dimText,
      NovenaDayStatus.notStarted => AppColors.mutedText,
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
      borderColor: status == NovenaDayStatus.current
          ? AppColors.gold
          : AppColors.border,
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
                  strings.statusLabel(status),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
        ],
      ),
    );
  }
}

class _NovenaDetailStrings {
  const _NovenaDetailStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia novena...' : 'Loading novena...';
  String get back => _sw ? 'Rudi' : 'Back';
  String get progress => _sw ? 'Maendeleo' : 'Progress';
  String get notStarted => _sw ? 'Haijaanza' : 'Not Started';
  String get startPrompt => _sw ? 'Anza Siku ya 1' : 'Start Day 1';
  String get start => _sw ? 'Anza Novena' : 'Start Novena';
  String get restart => _sw ? 'Anza Upya' : 'Restart';
  String dayProgress(int day) =>
      _sw ? 'Siku ya $day kati ya 9' : 'Day $day of 9';
  String get errorTitle => _sw ? 'Novena haijapakia' : 'Novena did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma novena hii.'
      : 'There was a problem reading this novena.';
  String get missingTitle => _sw ? 'Novena haikupatikana' : 'Novena not found';
  String get missingMessage =>
      _sw ? 'Jaribu kuchagua novena nyingine.' : 'Try choosing another novena.';

  String statusLabel(NovenaDayStatus status) {
    return switch (status) {
      NovenaDayStatus.completed => _sw ? 'Imekamilika' : 'Completed',
      NovenaDayStatus.current => _sw ? 'Siku ya sasa' : 'Current day',
      NovenaDayStatus.open => _sw ? 'Fungua' : 'Open',
      NovenaDayStatus.locked => _sw ? 'Imefungwa' : 'Locked',
      NovenaDayStatus.notStarted => _sw ? 'Haijaanza' : 'Not started',
    };
  }
}
