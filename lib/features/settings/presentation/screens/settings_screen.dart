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
          _SettingsGroup(
            title: strings.language,
            children: [
              for (final language in SupportedLanguages.all)
                _LanguageSettingRow(
                  language: language,
                  selected: selectedLanguage == language.code,
                  onTap: () {
                    ref
                        .read(selectedLanguageProvider.notifier)
                        .selectLanguage(language.code);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: strings.reminders,
            children: [_ReminderRow(settings: settings, strings: strings)],
          ),
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
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: strings.reading,
            children: [
              _FontScaleRow(settings: settings, strings: strings),
              _ThemeRow(settings: settings, strings: strings),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: strings.information,
            children: [
              _InfoRow(
                icon: Icons.info_outline,
                title: strings.about,
                subtitle: strings.aboutSubtitle,
                onTap: () => context.push('/about'),
              ),
              _InfoRow(
                icon: Icons.source_outlined,
                title: strings.contentSources,
                subtitle: strings.contentSourcesSubtitle,
                onTap: () => context.push('/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                    color: AppColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReminderRow extends ConsumerWidget {
  const _ReminderRow({required this.settings, required this.strings});

  final UserSettings settings;
  final _SettingsStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            onTap: () => _pickTime(context, ref, settings.reminderTime),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: AppColors.mutedText,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      strings.changeTime,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    _formatDisplayTime(settings.reminderTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.chevron_right, color: AppColors.mutedText),
                ],
              ),
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

class _FontScaleRow extends ConsumerWidget {
  const _FontScaleRow({required this.settings, required this.strings});

  final UserSettings settings;
  final _SettingsStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
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

class _ThemeRow extends ConsumerWidget {
  const _ThemeRow({required this.settings, required this.strings});

  final UserSettings settings;
  final _SettingsStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.theme, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.phone_android),
                label: Text(strings.system),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode),
                label: Text(strings.light),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode),
                label: Text(strings.dark),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (selection) => ref
                .read(userSettingsProvider.notifier)
                .setThemeMode(selection.first),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Icon(icon, color: AppColors.gold),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right, color: AppColors.mutedText),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
    );
  }
}

class _LanguageSettingRow extends StatelessWidget {
  const _LanguageSettingRow({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final SupportedLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Icon(
              selected ? Icons.check_circle : Icons.language,
              color: selected ? AppColors.gold : AppColors.mutedText,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    language.nativeName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
      ? 'Dhibiti lugha, vikumbusho, maandishi, na mandhari.'
      : 'Manage language, reminders, text size, and theme.';
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
  String get theme => _sw ? 'Mandhari' : 'Theme';
  String get system => _sw ? 'Mfumo' : 'System';
  String get light => _sw ? 'Mwanga' : 'Light';
  String get dark => _sw ? 'Giza' : 'Dark';
  String get information => _sw ? 'Taarifa' : 'Information';
  String get about => _sw ? 'Kuhusu' : 'About';
  String get aboutSubtitle =>
      _sw ? 'Toleo, msanidi, na maelezo' : 'Version, developer, and notes';
  String get contentSources => _sw ? 'Vyanzo vya Maudhui' : 'Content Sources';
  String get contentSourcesSubtitle => _sw
      ? 'Sala za kimapokeo na ibada zilizoidhinishwa'
      : 'Traditional prayers and approved devotions';
}
