import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/localization/supported_languages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage =
        ref.watch(selectedLanguageProvider).asData?.value ??
        SupportedLanguages.english.code;
    final settingsState = ref.watch(userSettingsProvider);
    final strings = _SettingsStrings(selectedLanguage);

    return settingsState.when(
      loading: () => AppLoading(label: strings.loading),
      error: (error, stackTrace) => ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          Text(strings.title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            backgroundColor: AppColors.surfaceWarm,
            child: Text(
              strings.loadError,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      data: (settings) => ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.screenTop,
          AppSpacing.screenHorizontal,
          AppSpacing.screenBottom,
        ),
        children: [
          Text(strings.title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(strings.subtitle, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.section),
          SectionHeader(title: strings.language),
          const SizedBox(height: AppSpacing.md),
          for (final language in SupportedLanguages.all) ...[
            _LanguageSettingTile(
              language: language,
              selected: selectedLanguage == language.code,
              onTap: () {
                ref
                    .read(selectedLanguageProvider.notifier)
                    .selectLanguage(language.code);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.section),
          SectionHeader(title: strings.reminders),
          const SizedBox(height: AppSpacing.md),
          _ReminderCard(settings: settings, strings: strings),
          if (settings.permissionDenied) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              backgroundColor: AppColors.surfaceWarm,
              child: Text(
                strings.permissionDenied,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.section),
          SectionHeader(title: strings.reading),
          const SizedBox(height: AppSpacing.md),
          _FontScaleCard(settings: settings, strings: strings),
          const SizedBox(height: AppSpacing.section),
          SectionHeader(title: strings.information),
          const SizedBox(height: AppSpacing.md),
          _InfoTile(
            icon: Icons.info_outline,
            title: strings.about,
            subtitle: strings.aboutSubtitle,
            onTap: () => context.push('/about'),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoTile(
            icon: Icons.source_outlined,
            title: strings.contentSources,
            subtitle: strings.contentSourcesSubtitle,
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.settings, required this.strings});

  final UserSettings settings;
  final _SettingsStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_none, color: AppColors.gold),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.dailyReminder,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      settings.reminderEnabled
                          ? strings.reminderEnabled(
                              _formatDisplayTime(settings.reminderTime),
                            )
                          : strings.reminderDisabled,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.reminderEnabled,
                onChanged: (value) => ref
                    .read(userSettingsProvider.notifier)
                    .setReminderEnabled(value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickTime(context, ref, settings.reminderTime),
              icon: const Icon(Icons.schedule),
              label: Text(strings.changeTime),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    String currentValue,
  ) async {
    final parts = currentValue.split(':');
    final current = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 19,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0,
    );
    final selected = await showTimePicker(
      context: context,
      initialTime: current,
    );
    if (selected == null) {
      return;
    }

    await ref
        .read(userSettingsProvider.notifier)
        .setReminderTime(
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}',
        );
  }

  String _formatDisplayTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 19;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}

class _FontScaleCard extends ConsumerWidget {
  const _FontScaleCard({required this.settings, required this.strings});

  final UserSettings settings;
  final _SettingsStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.fontSize,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.fontSizeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: settings.fontScale,
            min: 0.9,
            max: 1.3,
            divisions: 4,
            label: '${(settings.fontScale * 100).round()}%',
            onChanged: (value) =>
                ref.read(userSettingsProvider.notifier).setFontScale(value),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.mutedText),
        ],
      ),
    );
  }
}

class _LanguageSettingTile extends StatelessWidget {
  const _LanguageSettingTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final SupportedLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: selected ? AppColors.gold : AppColors.border,
      backgroundColor: selected ? AppColors.goldSoft : AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  language.nativeName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: AppColors.gold)
          else
            const Icon(Icons.radio_button_unchecked, color: AppColors.dimText),
        ],
      ),
    );
  }
}

class _SettingsStrings {
  const _SettingsStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Mipangilio' : 'Settings';
  String get subtitle => _sw
      ? 'Dhibiti lugha, vikumbusho, na maandishi.'
      : 'Manage language, reminders, and text size.';
  String get loading => _sw ? 'Inapakia mipangilio...' : 'Loading settings...';
  String get loadError => _sw
      ? 'Kuna tatizo kusoma mipangilio.'
      : 'There was a problem reading settings.';
  String get language => _sw ? 'Lugha' : 'Language';
  String get reminders => _sw ? 'Vikumbusho' : 'Reminders';
  String get dailyReminder =>
      _sw ? 'Kikumbusho cha Kila Siku' : 'Daily Reminder';
  String reminderEnabled(String time) =>
      _sw ? 'Kimewekwa saa $time' : 'Set for $time';
  String get reminderDisabled =>
      _sw ? 'Kikumbusho hakijawekwa' : 'No reminder set';
  String get changeTime => _sw ? 'Badili Muda' : 'Change Time';
  String get permissionDenied => _sw
      ? 'Ruhusa ya arifa haijatolewa. Unaweza kuiwasha kwenye mipangilio ya kifaa.'
      : 'Notification permission was denied. You can enable it in device settings.';
  String get reading => _sw ? 'Kusoma' : 'Reading';
  String get fontSize => _sw ? 'Ukubwa wa Maandishi' : 'Text Size';
  String get fontSizeSubtitle =>
      _sw ? 'Badili ukubwa wa maandishi ya programu.' : 'Adjust app text size.';
  String get information => _sw ? 'Taarifa' : 'Information';
  String get about => _sw ? 'Kuhusu' : 'About';
  String get aboutSubtitle =>
      _sw ? 'Toleo, msanidi, na maelezo' : 'Version, developer, and notes';
  String get contentSources => _sw ? 'Vyanzo vya Maudhui' : 'Content Sources';
  String get contentSourcesSubtitle => _sw
      ? 'Sala za kimapokeo na ibada zilizoidhinishwa'
      : 'Traditional prayers and approved devotions';
}
