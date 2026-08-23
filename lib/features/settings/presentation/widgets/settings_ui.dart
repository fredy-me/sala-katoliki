import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class SettingsIconBadge extends StatelessWidget {
  const SettingsIconBadge({
    required this.icon,
    this.size = defaultSize,
    this.foreground,
    super.key,
  });

  static const double defaultSize = 40;

  final IconData icon;
  final double size;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: SettingsColors.iconBackground(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(
        icon,
        color: foreground ?? SettingsColors.accent(context),
        size: size * 0.55,
      ),
    );
  }
}

class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: SettingsColors.mutedText(context),
      ),
    );
  }
}

abstract final class SettingsColors {
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

  static Color danger(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFE58F98)
      : AppColors.danger;

  static Color dangerBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.danger.withValues(alpha: 0.16)
      : AppColors.danger.withValues(alpha: 0.08);

  static Color dangerBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.danger.withValues(alpha: 0.45)
      : AppColors.danger.withValues(alpha: 0.28);
}

abstract final class SettingsTextStyles {
  static TextStyle? display(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge;

  static TextStyle? heading(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium;

  static TextStyle? title(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge;

  static TextStyle? titleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;

  static TextStyle? body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;

  static TextStyle? bodySmall(BuildContext context) => body(context);

  static TextStyle? section(BuildContext context) => Theme.of(
    context,
  ).textTheme.labelSmall?.copyWith(color: SettingsColors.mutedText(context));

  static TextStyle? value(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: SettingsColors.text(context),
        fontWeight: FontWeight.w700,
      );

  static TextStyle? labelText(BuildContext context) => Theme.of(
    context,
  ).textTheme.labelSmall?.copyWith(color: AppTextStyles.label.color);
}
