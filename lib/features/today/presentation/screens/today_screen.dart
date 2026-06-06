import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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
    final strings = _TodayStrings(languageCode);
    final prayersState = ref.watch(prayersProvider);
    final localState = ref.watch(todayLocalStateProvider).asData?.value;

    return prayersState.when(
      loading: () => AppLoading(label: strings.loading),
      error: (error, stackTrace) => _TodayContent(
        strings: strings,
        dailyPrayer: null,
        localState: localState,
      ),
      data: (prayers) => _TodayContent(
        strings: strings,
        dailyPrayer: _selectDailyPrayer(prayers),
        localState: localState,
      ),
    );
  }

  PrayerEntity? _selectDailyPrayer(List<PrayerEntity> prayers) {
    if (prayers.isEmpty) {
      return null;
    }

    final dayIndex = DateTime.now().day % prayers.length;
    return prayers[dayIndex];
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({
    required this.strings,
    required this.dailyPrayer,
    required this.localState,
  });

  final _TodayStrings strings;
  final PrayerEntity? dailyPrayer;
  final TodayLocalState? localState;

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
          strings.eyebrow,
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
          _ContinueNovenaCard(strings: strings, state: state!),
        const SizedBox(height: AppSpacing.lg),
        _RosaryTodayCard(strings: strings),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: strings.quickActions),
        const SizedBox(height: AppSpacing.md),
        _QuickActionGrid(strings: strings),
        const SizedBox(height: AppSpacing.lg),
        _ReminderStatusCard(strings: strings, state: state),
      ],
    );
  }
}

class _DailyPrayerCard extends StatelessWidget {
  const _DailyPrayerCard({required this.strings, required this.prayer});

  final _TodayStrings strings;
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
            strings.todaysPrayer,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            prayer?.title() ?? strings.noDailyPrayerTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.background,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            prayer?.description ?? strings.noDailyPrayerBody,
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
            label: Text(strings.prayNow),
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

  final _TodayStrings strings;

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
                  strings.novenas,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.noActiveNovena,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.go('/novenas'),
            child: Text(strings.browse),
          ),
        ],
      ),
    );
  }
}

class _ContinueNovenaCard extends StatelessWidget {
  const _ContinueNovenaCard({required this.strings, required this.state});

  final _TodayStrings strings;
  final TodayLocalState state;

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
                      strings.continueNovena,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatNovenaId(state.activeNovenaId!),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      strings.dayProgress(state.nextNovenaDay),
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
            child: Text(strings.continueAction),
          ),
        ],
      ),
    );
  }

  String _formatNovenaId(String id) {
    return id
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _RosaryTodayCard extends StatelessWidget {
  const _RosaryTodayCard({required this.strings});

  final _TodayStrings strings;

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
                  strings.rosaryToday,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.suggestedMystery,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  strings.todayDay,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.go('/rosary'),
            child: Text(strings.startRosary),
          ),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.strings});

  final _TodayStrings strings;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(Icons.menu_book_outlined, strings.commonPrayers, '/prayers'),
      _QuickAction(Icons.radio_button_checked, strings.rosary, '/rosary'),
      _QuickAction(Icons.calendar_month_outlined, strings.novenas, '/novenas'),
      _QuickAction(Icons.favorite_border, strings.favorites, '/favorites'),
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
            onTap: () => context.go(action.path),
            padding: const EdgeInsets.all(AppSpacing.md),
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
      ],
    );
  }
}

class _ReminderStatusCard extends StatelessWidget {
  const _ReminderStatusCard({required this.strings, required this.state});

  final _TodayStrings strings;
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
                      ? strings.reminderEnabled(reminderTime)
                      : strings.reminderDisabled,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  strings.availableOffline,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/settings'),
            child: Text(strings.edit),
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
  const _QuickAction(this.icon, this.label, this.path);

  final IconData icon;
  final String label;
  final String path;
}

class _TodayStrings {
  const _TodayStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia leo...' : 'Loading today...';
  String get eyebrow => _sw ? 'AMANI IWE NAWE' : 'PEACE BE WITH YOU';
  String get todaysPrayer => _sw ? 'SALA YA LEO' : "TODAY'S PRAYER";
  String get noDailyPrayerTitle =>
      _sw ? 'Sala haijapatikana' : 'Prayer unavailable';
  String get noDailyPrayerBody => _sw
      ? 'Fungua maktaba ya sala kuona sala zilizopo.'
      : 'Open the prayer library to view available prayers.';
  String get prayNow => _sw ? 'Sali Sasa' : 'Pray Now';
  String get quickActions => _sw ? 'Fikia Haraka' : 'Quick Actions';
  String get continueNovena => _sw ? 'Endelea Novena' : 'Continue Novena';
  String get continueAction => _sw ? 'Endelea' : 'Continue';
  String get novenas => _sw ? 'Novenas' : 'Novenas';
  String get noActiveNovena =>
      _sw ? 'Hakuna novena inayoendelea kwa sasa.' : 'No active novena yet.';
  String get browse => _sw ? 'Fungua' : 'Browse';
  String dayProgress(int day) =>
      _sw ? 'Siku ya $day kati ya 9' : 'Day $day of 9';
  String get rosaryToday => _sw ? 'Rozari Leo' : 'Rosary Today';
  String get suggestedMystery => _sw ? 'Mafumbo ya Leo' : "Today's Mysteries";
  String get todayDay => _sw ? 'Kulingana na siku ya leo' : 'Based on today';
  String get startRosary => _sw ? 'Anza Rozari' : 'Start Rosary';
  String get commonPrayers => _sw ? 'Sala za Kawaida' : 'Common Prayers';
  String get rosary => _sw ? 'Rozari' : 'Rosary';
  String get favorites => _sw ? 'Vipendwa' : 'Favorites';
  String reminderEnabled(String time) =>
      _sw ? 'Kikumbusho kimewekwa saa $time' : 'Reminder set for $time';
  String get reminderDisabled =>
      _sw ? 'Kikumbusho hakijawekwa' : 'No reminder set';
  String get availableOffline =>
      _sw ? 'Inapatikana nje ya mtandao' : 'Available offline';
  String get edit => _sw ? 'Hariri' : 'Edit';
}
