import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static Color statusBarColorFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? AppColors.darkBackground
        : AppColors.lightStatusBarCream;
  }

  static SystemUiOverlayStyle systemOverlayStyleFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
      );
    }

    return const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.light,
      primary: AppColors.navy,
      secondary: AppColors.gold,
      surface: AppColors.surface,
    );

    return _baseTheme(
      scheme: scheme,
      background: AppColors.background,
      surface: AppColors.surface,
      inputFill: AppColors.surfaceWarm,
      primary: AppColors.navy,
      text: AppColors.text,
      mutedText: AppColors.mutedText,
      buttonText: AppColors.background,
      border: AppColors.border,
    );
  }

  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          brightness: Brightness.dark,
          primary: AppColors.gold,
          secondary: AppColors.gold,
          surface: AppColors.darkSurface,
        ).copyWith(
          surfaceContainer: AppColors.darkSurface,
          surfaceContainerHigh: AppColors.darkSurfaceElevated,
          surfaceContainerHighest: AppColors.darkSurfaceElevated,
          onSurface: AppColors.darkText,
          onSurfaceVariant: AppColors.darkMutedText,
          outlineVariant: AppColors.darkBorder,
        );

    return _baseTheme(
      scheme: scheme,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      inputFill: AppColors.darkSurfaceElevated,
      primary: AppColors.gold,
      text: AppColors.darkText,
      mutedText: AppColors.darkMutedText,
      buttonText: AppColors.text,
      border: AppColors.darkBorder,
    );
  }

  static ThemeData _baseTheme({
    required ColorScheme scheme,
    required Color background,
    required Color surface,
    required Color inputFill,
    required Color primary,
    required Color text,
    required Color mutedText,
    required Color buttonText,
    required Color border,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.display.copyWith(color: text),
        headlineMedium: AppTextStyles.headline.copyWith(color: text),
        titleLarge: AppTextStyles.title.copyWith(color: text),
        titleMedium: TextStyle(
          color: text,
          fontSize: 15,
          height: 1.32,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: AppTextStyles.body.copyWith(color: mutedText),
        bodyMedium: AppTextStyles.bodySmall.copyWith(color: mutedText),
        labelLarge: TextStyle(
          color: buttonText,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.label,
      ),
      dividerTheme: DividerThemeData(color: border),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: border,
      ),
      iconTheme: IconThemeData(color: primary),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: buttonText,
          minimumSize: const Size(0, 54),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: primary),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: Colors.transparent,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.gold
                : mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.gold
                : mutedText,
            size: 22,
          ),
        ),
      ),
    );
  }
}
