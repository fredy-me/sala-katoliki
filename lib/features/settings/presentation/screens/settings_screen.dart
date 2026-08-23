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
            loading: () => AppLoading(label: strings.loading),
            error: (error, stackTrace) => _SettingsError(strings: strings),
            data: (settings) => ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.screenTop,
                AppSpacing.screenHorizontal,
                AppSpacing.screenBottom,
              ),
              children: [
                _SettingsHeader(strings: strings),
                const SizedBox(height: AppSpacing.section),
                _SectionLabel(strings.preferences),
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
                            _SegmentOption(
                              value: SupportedLanguages.english.code,
                              label: SupportedLanguages.english.name,
                              icon: Icons.translate,
                            ),
                            _SegmentOption(
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
                          activeThumbColor: _SettingsColors.selectedText(
                            context,
                          ),
                          activeTrackColor: _SettingsColors.accent(context),
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
                            _SegmentOption(
                              value: _TextSizeValue.small,
                              label: strings.small,
                              icon: Icons.text_decrease,
                            ),
                            _SegmentOption(
                              value: _TextSizeValue.medium,
                              label: strings.medium,
                              icon: Icons.text_fields,
                            ),
                            _SegmentOption(
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
                            _SegmentOption(
                              value: ThemeMode.system,
                              label: strings.system,
                              icon: Icons.phone_android,
                            ),
                            _SegmentOption(
                              value: ThemeMode.light,
                              label: strings.light,
                              icon: Icons.light_mode_outlined,
                            ),
                            _SegmentOption(
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
                _SectionLabel(strings.supportInfo),
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
              Text(title, style: _SettingsText.title(context)),
              const SizedBox(height: AppSpacing.lg),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: _SettingsColors.accent(context),
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: _SettingsColors.mutedText(context),
                    displayColor: _SettingsColors.text(context),
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
    required List<_SegmentOption<T>> options,
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
              Text(title, style: _SettingsText.title(context)),
              const SizedBox(height: AppSpacing.lg),
              _SegmentedControl<T>(
                value: value,
                options: options,
                onSelected: (selected) {
                  Navigator.of(sheetContext).pop();
                  onSelected(selected);
                },
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
    return Text(strings.title, style: _SettingsText.display(context));
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.strings});

  final _SettingsStrings strings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        Text(strings.title, style: _SettingsText.display(context)),
        const SizedBox(height: AppSpacing.lg),
        _NoticeCard(message: strings.loadError),
      ],
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
      AppSpacing.lg + _IconBadge.size + AppSpacing.md;

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
            _IconBadge(icon: icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(title, style: _SettingsText.titleSmall(context)),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: _SettingsColors.mutedText(context),
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
      child: Divider(height: 1, color: _SettingsColors.border(context)),
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
        Text(value, style: _SettingsText.value(context)),
        const SizedBox(width: AppSpacing.xs),
        Icon(
          Icons.chevron_right,
          size: 20,
          color: _SettingsColors.mutedText(context),
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
              const SizedBox(width: _IconBadge.size + AppSpacing.md),
              Expanded(
                child: Text(label, style: _SettingsText.titleSmall(context)),
              ),
              Text(time, style: _SettingsText.body(context)),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: _SettingsColors.mutedText(context),
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
      child: Text(message, style: _SettingsText.body(context)),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  static const size = 40.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _SettingsColors.iconBackground(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(icon, color: _SettingsColors.accent(context), size: 28),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: _SettingsText.section(context));
  }
}

class _SegmentedControl<T> extends StatelessWidget {
  const _SegmentedControl({
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final T value;
  final List<_SegmentOption<T>> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: _SettingsColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var index = 0; index < options.length; index++) ...[
              Expanded(
                child: _SegmentButton<T>(
                  option: options[index],
                  selected: value == options[index].value,
                  onTap: onSelected,
                ),
              ),
              if (index != options.length - 1)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: _SettingsColors.border(context),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SegmentButton<T> extends StatelessWidget {
  const _SegmentButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _SegmentOption<T> option;
  final bool selected;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? _SettingsColors.accent(context) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              color: selected
                  ? _SettingsColors.selectedText(context)
                  : _SettingsColors.text(context),
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _SettingsText.segmentLabel(context, selected: selected),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentOption<T> {
  const _SegmentOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

enum _TextSizeValue { small, medium, large }

abstract final class _SettingsColors {
  static Color iconBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.darkSurfaceElevated
      : AppColors.surfaceWarm;

  static Color border(BuildContext context) =>
      Theme.of(context).dividerTheme.color ??
      Theme.of(context).colorScheme.outlineVariant;

  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color mutedText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color accent(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.color ??
      Theme.of(context).colorScheme.secondary;

  static Color selectedText(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondary;
}

abstract final class _SettingsText {
  static TextStyle? display(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge;

  static TextStyle? title(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge;

  static TextStyle? titleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;

  static TextStyle? body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;

  static TextStyle? bodySmall(BuildContext context) => body(context);

  static TextStyle? section(BuildContext context) => Theme.of(
    context,
  ).textTheme.labelSmall?.copyWith(color: _SettingsColors.mutedText(context));

  static TextStyle? value(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: _SettingsColors.text(context),
        fontWeight: FontWeight.w700,
      );

  static TextStyle? segmentLabel(
    BuildContext context, {
    required bool selected,
  }) => Theme.of(context).textTheme.labelSmall?.copyWith(
    color: selected
        ? _SettingsColors.selectedText(context)
        : _SettingsColors.text(context),
    fontWeight: FontWeight.w700,
  );
}

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
