import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/theme/app_colors.dart';
import 'package:salakatoliki/core/theme/app_theme.dart';

void main() {
  test('progress indicators use explicit light theme colors', () {
    final progressTheme = AppTheme.light.progressIndicatorTheme;

    expect(progressTheme.color, AppColors.navy);
    expect(progressTheme.linearTrackColor, AppColors.border);
  });

  test('progress indicators use explicit dark theme colors', () {
    final progressTheme = AppTheme.dark.progressIndicatorTheme;

    expect(progressTheme.color, AppColors.gold);
    expect(progressTheme.linearTrackColor, AppColors.darkBorder);
  });
}
