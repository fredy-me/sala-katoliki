import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/localization/localization_providers.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../today/presentation/providers/today_providers.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final userSettingsProvider =
    AsyncNotifierProvider<UserSettingsNotifier, UserSettings>(
      UserSettingsNotifier.new,
    );

class UserSettings {
  const UserSettings({
    required this.themeMode,
    required this.fontScale,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.permissionDenied,
  });

  final ThemeMode themeMode;
  final double fontScale;
  final bool reminderEnabled;
  final String reminderTime;
  final bool permissionDenied;

  UserSettings copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    bool? reminderEnabled,
    String? reminderTime,
    bool? permissionDenied,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}

class UserSettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    ref.listen<String>(activeLanguageProvider, (previous, next) {
      if (previous == null || previous == next) {
        return;
      }
      unawaited(_rescheduleEnabledReminder());
    });

    final preferences = await SharedPreferences.getInstance();
    return UserSettings(
      themeMode: _themeModeFromStorage(
        preferences.getString(StorageKeys.themeMode),
      ),
      fontScale: _validFontScale(preferences.getDouble(StorageKeys.fontSize)),
      reminderEnabled:
          preferences.getBool(StorageKeys.reminderEnabled) ?? false,
      reminderTime: _validTime(preferences.getString(StorageKeys.reminderTime)),
      permissionDenied: false,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final current = state.asData?.value ?? await future;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(StorageKeys.themeMode, themeMode.name);
    state = AsyncData(current.copyWith(themeMode: themeMode));
  }

  Future<void> setFontScale(double fontScale) async {
    final current = state.asData?.value ?? await future;
    final validScale = _validFontScale(fontScale);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(StorageKeys.fontSize, validScale);
    state = AsyncData(current.copyWith(fontScale: validScale));
  }

  Future<void> setReminderTime(String reminderTime) async {
    final current = state.asData?.value ?? await future;
    final validTime = _validTime(reminderTime);
    final updated = current.copyWith(reminderTime: validTime);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(StorageKeys.reminderTime, validTime);

    if (updated.reminderEnabled) {
      final scheduled = await _scheduleReminder(validTime);
      if (!scheduled) {
        final disabled = updated.copyWith(
          reminderEnabled: false,
          permissionDenied: true,
        );
        await preferences.setBool(StorageKeys.reminderEnabled, false);
        state = AsyncData(disabled);
        ref.invalidate(todayLocalStateProvider);
        return;
      }
    }

    state = AsyncData(updated.copyWith(permissionDenied: false));
    ref.invalidate(todayLocalStateProvider);
  }

  Future<void> setReminderEnabled(bool enabled) async {
    final current = state.asData?.value ?? await future;
    final preferences = await SharedPreferences.getInstance();

    if (!enabled) {
      await ref.read(notificationServiceProvider).cancelDailyReminder();
      await preferences.setBool(StorageKeys.reminderEnabled, false);
      state = AsyncData(
        current.copyWith(reminderEnabled: false, permissionDenied: false),
      );
      ref.invalidate(todayLocalStateProvider);
      return;
    }

    final scheduled = await _scheduleReminder(current.reminderTime);
    if (!scheduled) {
      await preferences.setBool(StorageKeys.reminderEnabled, false);
      state = AsyncData(
        current.copyWith(reminderEnabled: false, permissionDenied: true),
      );
      ref.invalidate(todayLocalStateProvider);
      return;
    }

    await preferences.setBool(StorageKeys.reminderEnabled, true);
    await preferences.setString(StorageKeys.reminderTime, current.reminderTime);
    state = AsyncData(
      current.copyWith(reminderEnabled: true, permissionDenied: false),
    );
    ref.invalidate(todayLocalStateProvider);
  }

  Future<bool> _scheduleReminder(String reminderTime) async {
    final (hour, minute) = _parseTime(reminderTime);
    final strings = _ReminderNotificationStrings(
      ref.read(activeLanguageProvider),
    );
    return ref
        .read(notificationServiceProvider)
        .scheduleDailyReminder(
          hour: hour,
          minute: minute,
          title: strings.title,
          body: strings.body,
        );
  }

  Future<void> _rescheduleEnabledReminder() async {
    final current = state.asData?.value;
    if (current == null || !current.reminderEnabled) {
      return;
    }

    final scheduled = await _scheduleReminder(current.reminderTime);
    if (scheduled) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(StorageKeys.reminderEnabled, false);
    state = AsyncData(
      current.copyWith(reminderEnabled: false, permissionDenied: true),
    );
    ref.invalidate(todayLocalStateProvider);
  }

  ThemeMode _themeModeFromStorage(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  double _validFontScale(double? value) {
    final raw = value ?? 1;
    if (raw < 0.9) {
      return 0.9;
    }
    if (raw > 1.3) {
      return 1.3;
    }
    return raw;
  }

  String _validTime(String? value) {
    if (value == null) {
      return '19:00';
    }
    final parts = value.split(':');
    if (parts.length != 2) {
      return '19:00';
    }
    final hour = int.tryParse(parts.first);
    final minute = int.tryParse(parts.last);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return '19:00';
    }
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  (int, int) _parseTime(String value) {
    final valid = _validTime(value);
    final parts = valid.split(':');
    return (int.parse(parts.first), int.parse(parts.last));
  }
}

class _ReminderNotificationStrings {
  const _ReminderNotificationStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => 'Sala Katoliki';

  String get body => _sw
      ? 'Chukua muda mfupi kwa ajili ya sala leo.'
      : 'Take a moment for prayer today.';
}
