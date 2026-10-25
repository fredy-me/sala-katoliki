import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/novenas/presentation/providers/novena_providers.dart';
import '../../../../features/prayers/domain/entities/prayer_entity.dart';
import '../../../../features/prayers/presentation/providers/prayer_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/today_providers.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = AppStrings(languageCode);
    final prayersState = ref.watch(prayersProvider);
    final localState = ref.watch(todayLocalStateProvider).asData?.value;
    // 5.3: the title alone, not a whole novena session. The other novena
    // screens still use activeNovenaSessionProvider, which needs the days.
    final activeNovenaTitle = ref
        .watch(activeNovenaTitleProvider)
        .asData
        ?.value;
    final recentIds =
        ref.watch(recentPrayerIdsProvider).asData?.value ?? const <String>[];

    return prayersState.when(
      loading: () => AppLoading(label: strings.todayLoading),
      error: (error, stackTrace) => _TodayContent(
        strings: strings,
        dailyPrayer: null,
        recentPrayer: null,
        localState: localState,
        activeNovenaTitle: activeNovenaTitle,
      ),
      data: (prayers) => _TodayContent(
        strings: strings,
        dailyPrayer: dailyPrayerFor(prayers),
        recentPrayer: _selectRecentPrayer(prayers, recentIds),
        localState: localState,
        activeNovenaTitle: activeNovenaTitle,
      ),
    );
  }

  PrayerEntity? _selectRecentPrayer(
    List<PrayerEntity> prayers,
    List<String> recentIds,
  ) {
    if (recentIds.isEmpty) {
      return null;
    }

    final prayersById = {for (final prayer in prayers) prayer.id: prayer};
    for (final id in recentIds) {
      final prayer = prayersById[id];
      if (prayer != null) {
        return prayer;
      }
    }

    return null;
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({
    required this.strings,
    required this.dailyPrayer,
    required this.recentPrayer,
    required this.localState,
    required this.activeNovenaTitle,
  });

  final AppStrings strings;
  final PrayerEntity? dailyPrayer;
  final PrayerEntity? recentPrayer;
  final TodayLocalState? localState;
  final String? activeNovenaTitle;

  @override
  Widget build(BuildContext context) {
    final state = localState;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenTop,
        AppSpacing.screenHorizontal,
        AppSpacing.screenBottom,
      ),
      children: [
        Text(
          strings.todayEyebrow,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.gold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Sala Katoliki', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.xxl),
        _DailyPrayerCard(strings: strings, prayer: dailyPrayer),
        const SizedBox(height: AppSpacing.lg),
        if (state?.activeNovenaId == null)
          _NoActiveNovenaCard(strings: strings)
        else
          _ContinueNovenaCard(
            strings: strings,
            state: state!,
            title: activeNovenaTitle,
          ),
        const SizedBox(height: AppSpacing.lg),
        _RosaryTodayCard(strings: strings),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: strings.todayQuickActions),
        const SizedBox(height: AppSpacing.md),
        _QuickActionGrid(strings: strings, recentPrayer: recentPrayer),
        const SizedBox(height: AppSpacing.lg),
        _ReminderStatusCard(strings: strings, state: state),
      ],
    );
  }
}

class _DailyPrayerCard extends StatelessWidget {
  const _DailyPrayerCard({required this.strings, required this.prayer});

  final AppStrings strings;
  final PrayerEntity? prayer;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.navy,
      borderColor: AppColors.navy,
      radius: AppSpacing.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.todayTodaysPrayer,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            prayer?.title() ?? strings.todayNoDailyPrayerTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.background,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            prayer?.description ?? strings.todayNoDailyPrayerBody,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.background.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: prayer == null
                ? () => context.go('/prayers')
                : () => context.push('/prayers/${prayer!.id}'),
            icon: const Icon(Icons.chevron_right),
            label: Text(strings.todayPrayNow),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.text,
              minimumSize: const Size(128, 44),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoActiveNovenaCard extends StatelessWidget {
  const _NoActiveNovenaCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const _IconBadge(icon: Icons.calendar_month_outlined),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.todayNovenas,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.todayNoActiveNovena,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.go('/novenas'),
            child: Text(strings.todayBrowse),
          ),
        ],
      ),
    );
  }
}

class _ContinueNovenaCard extends StatelessWidget {
  const _ContinueNovenaCard({
    required this.strings,
    required this.state,
    required this.title,
  });

  final AppStrings strings;
  final TodayLocalState state;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBadge(icon: Icons.calendar_month_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.todayContinueNovena,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title ?? strings.todayActiveNovenaUnavailable,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      strings.todayDayProgress(
                        state.nextNovenaDay,
                        state.totalNovenaDays,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: state.novenaProgress,
            minHeight: 4,
            backgroundColor: Theme.of(context).dividerTheme.color,
            color: AppColors.gold,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () => context.push(
              '/novenas/${state.activeNovenaId}/day/${state.nextNovenaDay}',
            ),
            child: Text(strings.todayContinueAction),
          ),
        ],
      ),
    );
  }
}

class _RosaryTodayCard extends StatelessWidget {
  const _RosaryTodayCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const _IconBadge(icon: Icons.radio_button_checked),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.todayRosaryToday,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.todaySuggestedMystery,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  strings.todayTodayDay,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.push('/rosary'),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(strings.todayStartRosary),
          ),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.strings, required this.recentPrayer});

  final AppStrings strings;
  final PrayerEntity? recentPrayer;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        Icons.menu_book_outlined,
        strings.todayCommonPrayers,
        '/prayers',
      ),
      _QuickAction(
        Icons.history,
        strings.todayRecentlyOpened,
        recentPrayer == null ? null : '/prayers/${recentPrayer!.id}',
        usePush: true,
      ),
      _QuickAction(
        Icons.favorite_border,
        strings.todayFavorites,
        '/favorites',
        usePush: true,
      ),
      _QuickAction(
        Icons.calendar_month_outlined,
        strings.todayNovenas,
        '/novenas',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      children: [
        for (final action in actions)
          AppCard(
            onTap: action.path == null
                ? null
                : () => _openAction(context, action),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Opacity(
              opacity: action.path == null ? 0.55 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _IconBadge(icon: action.icon, compact: true),
                  Text(
                    action.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _openAction(BuildContext context, _QuickAction action) {
    final path = action.path;
    if (path == null) {
      return;
    }

    if (action.usePush) {
      context.push(path);
      return;
    }

    context.go(path);
  }
}

class _ReminderStatusCard extends StatelessWidget {
  const _ReminderStatusCard({required this.strings, required this.state});

  final AppStrings strings;
  final TodayLocalState? state;

  @override
  Widget build(BuildContext context) {
    final reminderEnabled = state?.reminderEnabled ?? false;
    final reminderTime = state?.reminderTime ?? '7:00 PM';

    return AppCard(
      child: Row(
        children: [
          const _IconBadge(icon: Icons.notifications_none, compact: true),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminderEnabled
                      ? strings.todayReminderEnabled(reminderTime)
                      : strings.todayReminderDisabled,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  strings.todayAvailableOffline,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/settings'),
            child: Text(strings.todayEdit),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.compact = false});

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 42.0;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.goldSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.gold, size: compact ? 18 : 21),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.icon, this.label, this.path, {this.usePush = false});

  final IconData icon;
  final String label;
  final String? path;
  final bool usePush;
}
