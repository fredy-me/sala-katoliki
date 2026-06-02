import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    color: AppColors.text,
    fontFamily: 'serif',
    fontSize: 30,
    height: 1.12,
    fontWeight: FontWeight.w700,
  );

  static const headline = TextStyle(
    color: AppColors.text,
    fontFamily: 'serif',
    fontSize: 24,
    height: 1.16,
    fontWeight: FontWeight.w700,
  );

  static const title = TextStyle(
    color: AppColors.text,
    fontFamily: 'serif',
    fontSize: 18,
    height: 1.28,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(
    color: AppColors.mutedText,
    fontSize: 16,
    height: 1.48,
    fontWeight: FontWeight.w400,
  );

  static const bodySmall = TextStyle(
    color: AppColors.mutedText,
    fontSize: 13,
    height: 1.38,
    fontWeight: FontWeight.w400,
  );

  static const label = TextStyle(
    color: AppColors.gold,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  static const prayerBody = TextStyle(
    color: AppColors.text,
    fontFamily: 'serif',
    fontSize: 20,
    height: 1.62,
    fontWeight: FontWeight.w400,
  );
}
