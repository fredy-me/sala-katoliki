import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/novena_model.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/novena_state.dart';
import '../providers/novena_providers.dart';

class NovenasScreen extends ConsumerWidget {
  const NovenasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = AppStrings(languageCode);
    final novenasState = ref.watch(novenasProvider);
    final activeSession = ref.watch(activeNovenaSessionProvider).asData?.value;

    return novenasState.when(
      loading: () => AppLoading(label: strings.novenasLoading),
      error: (error, stackTrace) => AppErrorState(
        title: strings.novenasErrorTitle,
        message: strings.novenasErrorMessage,
        actionLabel: strings.novenasRetry,
        onAction: () => ref.invalidate(novenasProvider),
      ),
      data: (novenas) {
        if (novenas.isEmpty) {
          return AppEmptyState(
            title: strings.novenasEmptyTitle,
            message: strings.novenasEmptyMessage,
            icon: Icons.calendar_month_outlined,
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.screenTop,
            AppSpacing.screenHorizontal,
            AppSpacing.screenBottom,
          ),
          children: [
            Text(
              strings.novenasTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings.novenasSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (activeSession != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _ActiveNovenaHero(
                session: activeSession,
                strings: strings,
                onContinue: () => context.push(
                  '/novenas/${activeSession.novena.id}/day/${activeSession.nextDay}',
                ),
                onView: () =>
                    context.push('/novenas/${activeSession.novena.id}'),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            SectionHeader(title: strings.novenasBrowse),
            const SizedBox(height: AppSpacing.md),
            for (final novena in novenas) ...[
              _NovenaListItem(
                novena: novena,
                isActive: activeSession?.novena.id == novena.id,
                strings: strings,
                onTap: () => context.push('/novenas/${novena.id}'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _ActiveNovenaHero extends StatelessWidget {
  const _ActiveNovenaHero({
    required this.session,
    required this.strings,
    required this.onContinue,
    required this.onView,
  });

  final NovenaSession session;
  final AppStrings strings;
  final VoidCallback onContinue;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.navy,
      borderColor: AppColors.navy,
      radius: AppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.novenasActiveNovena,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            session.novena.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.novenasDayProgress(session.nextDay, session.totalDays),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: session.completionRatio,
            minHeight: 8,
            color: AppColors.gold,
            backgroundColor: Colors.white.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.text,
                  ),
                  child: Text(strings.novenasContinueLabel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                tooltip: strings.novenasView,
                onPressed: onView,
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NovenaListItem extends StatelessWidget {
  const _NovenaListItem({
    required this.novena,
    required this.isActive,
    required this.strings,
    required this.onTap,
  });

  final NovenaModel novena;
  final bool isActive;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: isActive ? AppColors.gold : null,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.goldSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month, color: AppColors.navy),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  novena.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isActive ? strings.novenasInProgress : novena.description,
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
