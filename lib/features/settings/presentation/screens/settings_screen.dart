import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/localization/supported_languages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/legal_links.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_ui.dart';

const EdgeInsets _listPadding = EdgeInsets.fromLTRB(
  AppSpacing.screenHorizontal,
  AppSpacing.screenTop,
  AppSpacing.screenHorizontal,
  AppSpacing.screenBottom,
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage =
        ref.watch(selectedLanguageProvider).asData?.value ??
        SupportedLanguages.english.code;
    final settingsState = ref.watch(userSettingsProvider);
    final strings = _SettingsStrings(selectedLanguage);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemOverlayStyle(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: settingsState.when(
            loading: () => ListView(
              padding: _listPadding,
              children: [
                _SettingsHeader(strings: strings),
                const SizedBox(height: AppSpacing.section),
                AppLoading(label: strings.loading),
              ],
            ),
            error: (error, stackTrace) => ListView(
              padding: _listPadding,
              children: [
                _SettingsHeader(strings: strings),
                const SizedBox(height: AppSpacing.section),
                _NoticeCard(
                  message: strings.loadError,
                  icon: Icons.error_outline_rounded,
                ),
              ],
            ),
            data: (settings) => ListView(
              padding: _listPadding,
              children: [
                _SettingsHeader(strings: strings),
                const SizedBox(height: AppSpacing.section),
                SettingsSectionLabel(strings.preferences),
                const SizedBox(height: AppSpacing.md),
                _SettingsPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.language,
                        title: strings.language,
                        trailing: _TileValue(
                          value: _languageLabel(selectedLanguage),
                        ),
                        onTap: () => _showOptionPickerSheet<String>(
                          context,
                          title: strings.language,
                          value: selectedLanguage,
                          options: [
                            _PickerOption(
                              value: SupportedLanguages.english.code,
                              label: SupportedLanguages.english.name,
                              icon: Icons.translate,
                            ),
                            _PickerOption(
                              value: SupportedLanguages.kiswahili.code,
                              label: SupportedLanguages.kiswahili.name,
                              icon: Icons.record_voice_over_outlined,
                            ),
                          ],
                          onSelected: (languageCode) => ref
                              .read(selectedLanguageProvider.notifier)
                              .selectLanguage(languageCode),
                        ),
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.alarm,
                        title: strings.dailyReminder,
                        trailing: Switch(
                          value: settings.reminderEnabled,
                          activeThumbColor: SettingsColors.selectedText(
                            context,
                          ),
                          activeTrackColor: SettingsColors.accent(context),
                          onChanged: (value) => ref
                              .read(userSettingsProvider.notifier)
                              .setReminderEnabled(value),
                        ),
                      ),
                      _ReminderTimeTile(
                        enabled: settings.reminderEnabled,
                        label: strings.changeTime,
                        time: _formatDisplayTime(settings.reminderTime),
                        onTap: () =>
                            _pickTime(context, ref, settings.reminderTime),
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.text_fields,
                        title: strings.fontSize,
                        trailing: _TileValue(
                          value: strings.textSizeLabel(
                            _textSizeValue(settings.fontScale),
                          ),
                        ),
                        onTap: () => _showOptionPickerSheet<_TextSizeValue>(
                          context,
                          title: strings.fontSize,
                          value: _textSizeValue(settings.fontScale),
                          options: [
                            _PickerOption(
                              value: _TextSizeValue.small,
                              label: strings.small,
                              icon: Icons.text_decrease,
                            ),
                            _PickerOption(
                              value: _TextSizeValue.medium,
                              label: strings.medium,
                              icon: Icons.text_fields,
                            ),
                            _PickerOption(
                              value: _TextSizeValue.large,
                              label: strings.large,
                              icon: Icons.text_increase,
                            ),
                          ],
                          onSelected: (value) => ref
                              .read(userSettingsProvider.notifier)
                              .setFontScale(_fontScaleFor(value)),
                        ),
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.contrast,
                        title: strings.theme,
                        trailing: _TileValue(
                          value: _themeLabel(settings.themeMode, strings),
                        ),
                        onTap: () => _showOptionPickerSheet<ThemeMode>(
                          context,
                          title: strings.theme,
                          value: settings.themeMode,
                          options: [
                            _PickerOption(
                              value: ThemeMode.system,
                              label: strings.system,
                              icon: Icons.phone_android,
                            ),
                            _PickerOption(
                              value: ThemeMode.light,
                              label: strings.light,
                              icon: Icons.light_mode_outlined,
                            ),
                            _PickerOption(
                              value: ThemeMode.dark,
                              label: strings.dark,
                              icon: Icons.dark_mode_outlined,
                            ),
                          ],
                          onSelected: (value) => ref
                              .read(userSettingsProvider.notifier)
                              .setThemeMode(value),
                        ),
                      ),
                    ],
                  ),
                ),
                if (settings.permissionDenied) ...[
                  const SizedBox(height: AppSpacing.md),
                  _NoticeCard(message: strings.permissionDenied),
                ],
                const SizedBox(height: AppSpacing.section),
                SettingsSectionLabel(strings.supportInfo),
                const SizedBox(height: AppSpacing.md),
                _SettingsPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: strings.about,
                        onTap: () => context.push('/about'),
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.verified_user_outlined,
                        title: strings.privacyTitle,
                        onTap: () => _showLegalSheet(
                          context,
                          selectedLanguage,
                          strings.privacyTitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLegalSheet(
    BuildContext context,
    String languageCode,
    String title,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: SettingsTextStyles.title(context)),
              const SizedBox(height: AppSpacing.lg),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: SettingsColors.accent(context),
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: SettingsColors.mutedText(context),
                    displayColor: SettingsColors.text(context),
                  ),
                ),
                child: LegalLinks(languageCode: languageCode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionPickerSheet<T>(
    BuildContext context, {
    required String title,
    required T value,
    required List<_PickerOption<T>> options,
    required ValueChanged<T> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: SettingsTextStyles.title(context)),
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: SettingsColors.border(context)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var index = 0; index < options.length; index++) ...[
                      _PickerRow<T>(
                        option: options[index],
                        selected: value == options[index].value,
                        onTap: (selected) {
                          Navigator.of(sheetContext).pop();
                          onSelected(selected);
                        },
                      ),
                      if (index != options.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: SettingsIconBadge.defaultSize + AppSpacing.md,
                          ),
                          child: Divider(
                            height: 1,
                            color: SettingsColors.border(context),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
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

  String _languageLabel(String languageCode) {
    if (languageCode == SupportedLanguages.kiswahili.code) {
      return SupportedLanguages.kiswahili.name;
    }
    return SupportedLanguages.english.name;
  }

  String _themeLabel(ThemeMode mode, _SettingsStrings strings) {
    return switch (mode) {
      ThemeMode.light => strings.light,
      ThemeMode.dark => strings.dark,
      ThemeMode.system => strings.system,
    };
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

SystemUiOverlayStyle _systemOverlayStyle(BuildContext context) {
  return AppTheme.systemOverlayStyleFor(Theme.of(context).brightness);
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.strings});

  final _SettingsStrings strings;

  @override
  Widget build(BuildContext context) {
    return Text(strings.title, style: SettingsTextStyles.display(context));
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.message, this.icon = Icons.warning_amber_rounded});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: SettingsColors.dangerBackground(context),
      borderColor: SettingsColors.dangerBorder(context),
      child: Row(
        children: [
          SettingsIconBadge(
            icon: icon,
            foreground: SettingsColors.danger(context),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: SettingsTextStyles.body(context)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  static const double contentIndent =
      AppSpacing.lg + SettingsIconBadge.defaultSize + AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            SettingsIconBadge(icon: icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(title, style: SettingsTextStyles.titleSmall(context)),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: SettingsColors.mutedText(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: _SettingsTile.contentIndent),
      child: Divider(height: 1, color: SettingsColors.border(context)),
    );
  }
}

class _TileValue extends StatelessWidget {
  const _TileValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: SettingsTextStyles.value(context)),
        const SizedBox(width: AppSpacing.xs),
        Icon(
          Icons.chevron_right,
          size: 20,
          color: SettingsColors.mutedText(context),
        ),
      ],
    );
  }
}

class _ReminderTimeTile extends StatelessWidget {
  const _ReminderTimeTile({
    required this.enabled,
    required this.label,
    required this.time,
    required this.onTap,
  });

  final bool enabled;
  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              const SizedBox(width: SettingsIconBadge.defaultSize + AppSpacing.md),
              Expanded(
                child: Text(label, style: SettingsTextStyles.titleSmall(context)),
              ),
              Text(time, style: SettingsTextStyles.body(context)),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: SettingsColors.mutedText(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_TextSizeValue _textSizeValue(double scale) {
  if (scale < 0.98) {
    return _TextSizeValue.small;
  }
  if (scale > 1.12) {
    return _TextSizeValue.large;
  }
  return _TextSizeValue.medium;
}

double _fontScaleFor(_TextSizeValue value) {
  return switch (value) {
    _TextSizeValue.small => 0.9,
    _TextSizeValue.medium => 1.0,
    _TextSizeValue.large => 1.3,
  };
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _SettingsPanel(
      child: Text(message, style: SettingsTextStyles.body(context)),
    );
  }
}

class _PickerRow<T> extends StatelessWidget {
  const _PickerRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _PickerOption<T> option;
  final bool selected;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(option.value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            SettingsIconBadge(icon: option.icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                option.label,
                style: selected
                    ? SettingsTextStyles.titleSmall(context)
                    : SettingsTextStyles.body(context),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _PickerOption<T> {
  const _PickerOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

enum _TextSizeValue { small, medium, large }

class _SettingsStrings {
  const _SettingsStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Mipangilio' : 'Settings';
  String get loading => _sw ? 'Inapakia mipangilio...' : 'Loading settings...';
  String get loadError => _sw
      ? 'Kuna tatizo kusoma mipangilio.'
      : 'There was a problem reading settings.';
  String get preferences => _sw ? 'Mapendeleo' : 'Preferences';
  String get supportInfo => _sw ? 'Msaada na Taarifa' : 'Support & Info';
  String get language => _sw ? 'Lugha' : 'Language';
  String get languageSubtitle =>
      _sw ? 'Chagua lugha ya programu' : 'Choose app language';
  String get reminders => _sw ? 'Vikumbusho' : 'Reminders';
  String get dailyReminder =>
      _sw ? 'Kikumbusho cha Kila Siku' : 'Daily Reminder';
  String get reminderSubtitle =>
      _sw ? 'Pokea ukumbusho wa kusali' : 'Receive a reminder to pray';
  String reminderEnabled(String time) =>
      _sw ? 'Kimewekwa saa $time' : 'Set for $time';
  String get reminderDisabled =>
      _sw ? 'Kikumbusho hakijawekwa' : 'No reminder set';
  String get changeTime => _sw ? 'Muda wa Kikumbusho' : 'Reminder Time';
  String get permissionDenied => _sw
      ? 'Ruhusa ya arifa haijatolewa. Unaweza kuiwasha kwenye mipangilio ya kifaa.'
      : 'Notification permission was denied. You can enable it in device settings.';
  String get fontSize => _sw ? 'Ukubwa wa Maandishi' : 'Text Size';
  String get fontSizeSubtitle =>
      _sw ? 'Badili ukubwa wa kusoma' : 'Adjust reading size';
  String get small => _sw ? 'Ndogo' : 'Small';
  String get medium => _sw ? 'Wastani' : 'Medium';
  String get large => _sw ? 'Kubwa' : 'Large';
  String textSizeLabel(_TextSizeValue value) {
    return switch (value) {
      _TextSizeValue.small => small,
      _TextSizeValue.medium => medium,
      _TextSizeValue.large => large,
    };
  }

  String get theme => _sw ? 'Mandhari' : 'Theme';
  String get themeSubtitle =>
      _sw ? 'Chagua mwonekano wa programu' : 'Select app appearance';
  String get system => _sw ? 'Mfumo' : 'System';
  String get light => _sw ? 'Mwanga' : 'Light';
  String get dark => _sw ? 'Giza' : 'Dark';
  String get information => _sw ? 'Taarifa' : 'Information';
  String get about => _sw ? 'Kuhusu Programu' : 'About App';
  String get aboutSubtitle =>
      _sw ? 'Toleo, msanidi, na zaidi' : 'Version, developer and more';
  String get privacyTitle => _sw ? 'Faragha na Sera' : 'Privacy & Policies';
  String get privacySubtitle => _sw
      ? 'Sera ya Faragha, Masharti na Tahadhari'
      : 'Privacy Policy, Terms & Disclaimer';
}
