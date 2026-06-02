import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      surface: AppColors.night,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.night,
      fontFamily: 'serif',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.text,
          fontSize: 34,
          height: 1.08,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: AppColors.text,
          fontSize: 28,
          height: 1.12,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontSize: 21,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.text,
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.mutedText,
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.mutedText,
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: AppColors.night,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.night,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.nightPanel,
        indicatorColor: AppColors.nightPanelAlt,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.mutedText,
            size: 24,
          ),
        ),
      ),
    );
  }
}
