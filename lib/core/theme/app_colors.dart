import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFBF7EF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceWarm = Color(0xFFF3EDE2);
  static const navy = Color(0xFF233763);
  static const navyPressed = Color(0xFF1B2C52);
  static const gold = Color(0xFFD8A940);
  static const goldSoft = Color(0xFFF4E9CC);
  static const text = Color(0xFF17233E);
  static const mutedText = Color(0xFF64708A);
  static const dimText = Color(0xFF8B91A1);
  static const border = Color(0xFFE4D8C9);
  static const success = Color(0xFF5E7F4F);
  static const danger = Color(0xFF8E2F3A);

  static const darkBackground = Color(0xFF071326);
  static const darkSurface = Color(0xFF101D33);
  static const darkSurfaceElevated = Color(0xFF172A46);
  static const darkBorder = Color(0xFF263A59);
  static const darkText = Color(0xFFF8F3EA);
  static const darkMutedText = Color(0xFFC3CAD6);

  // Legacy names retained during the staged screen refactor.
  static const night = background;
  static const nightPanel = surface;
  static const nightPanelAlt = surfaceWarm;
  static const primary = navy;
  static const primaryStrong = navyPressed;
  static const warm = gold;
  static const sage = success;
}
