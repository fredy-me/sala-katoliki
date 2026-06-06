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
    final strings = _NovenasStrings(languageCode);
    final novenasState = ref.watch(novenasProvider);
    final activeSession = ref.watch(activeNovenaSessionProvider).asData?.value;

    return novenasState.when(
      loading: () => AppLoading(label: strings.loading),
      error: (error, stackTrace) => AppErrorState(
        title: strings.errorTitle,
        message: strings.errorMessage,
        actionLabel: strings.retry,
        onAction: () => ref.invalidate(novenasProvider),
      ),
      data: (novenas) {
        if (novenas.isEmpty) {
          return AppEmptyState(
            title: strings.emptyTitle,
            message: strings.emptyMessage,
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
              strings.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (activeSession != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _ActiveNovenaHero(
                session: activeSession,
                strings: strings,
                onContinue: () => context.push(
                  '/novenas/${activeSession.novena.id}/day/${activeSession.progress.nextDay}',
                ),
                onView: () =>
                    context.push('/novenas/${activeSession.novena.id}'),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            SectionHeader(title: strings.browse),
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
  final _NovenasStrings strings;
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
            strings.activeNovena,
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
            strings.dayProgress(session.progress.nextDay),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: session.progress.completionRatio,
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
                tooltip: strings.view,
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
  final _NovenasStrings strings;
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
                  isActive ? strings.inProgress : novena.description,
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

class _NovenasStrings {
  const _NovenasStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Novenas' : 'Novenas';
  String get subtitle => _sw
      ? 'Ibada za siku tisa zenye maendeleo ya ndani.'
      : 'Nine-day devotions with local progress.';
  String get loading => _sw ? 'Inapakia novenas...' : 'Loading novenas...';
  String get activeNovena => _sw ? 'Novena Inayoendelea' : 'Active Novena';
  String get browse => _sw ? 'Vinjari Novenas' : 'Browse Novenas';
  String get continueLabel => _sw ? 'Endelea' : 'Continue';
  String get view => _sw ? 'Tazama' : 'View';
  String get inProgress => _sw ? 'Inaendelea' : 'In progress';
  String get retry => _sw ? 'Jaribu tena' : 'Retry';
  String dayProgress(int day) =>
      _sw ? 'Siku ya $day kati ya 9' : 'Day $day of 9';
  String get errorTitle => _sw ? 'Novenas hazijapakia' : 'Novenas did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma novenas za ndani.'
      : 'There was a problem reading local novenas.';
  String get emptyTitle => _sw ? 'Hakuna novenas' : 'No novenas';
  String get emptyMessage => _sw
      ? 'Maudhui ya novena hayajapatikana.'
      : 'Novena content was not found.';
}
