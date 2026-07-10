import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';

final todayLocalStateProvider = FutureProvider<TodayLocalState>((ref) async {
  final preferences = await SharedPreferences.getInstance();
  final activeNovenaId = preferences.getString(StorageKeys.activeNovenaId);
  final completedDays = activeNovenaId == null
      ? const <int>{}
      : _completedDaysForActiveNovena(preferences, activeNovenaId);

  return TodayLocalState(
    activeNovenaId: activeNovenaId,
    completedNovenaDays: completedDays,
    reminderEnabled: preferences.getBool(StorageKeys.reminderEnabled) ?? false,
    reminderTime: preferences.getString(StorageKeys.reminderTime),
  );
});

class TodayLocalState {
  const TodayLocalState({
    required this.activeNovenaId,
    required this.completedNovenaDays,
    required this.reminderEnabled,
    required this.reminderTime,
  });

  final String? activeNovenaId;
  final Set<int> completedNovenaDays;
  final bool reminderEnabled;
  final String? reminderTime;

  int get totalNovenaDays => activeNovenaId == 'st_rita_novena' ? 12 : 9;

  int get nextNovenaDay {
    if (completedNovenaDays.isEmpty) {
      return 1;
    }

    final nextDay = completedNovenaDays.reduce((a, b) => a > b ? a : b) + 1;
    return nextDay.clamp(1, totalNovenaDays);
  }

  double get novenaProgress {
    return (completedNovenaDays.length / totalNovenaDays).clamp(0, 1);
  }
}

Set<int> _completedDaysForActiveNovena(
  SharedPreferences preferences,
  String activeNovenaId,
) {
  final rawProgress = preferences.getString(StorageKeys.novenaProgressById);
  if (rawProgress != null && rawProgress.isNotEmpty) {
    final Object? decoded;
    try {
      decoded = jsonDecode(rawProgress);
    } on FormatException {
      return _validCompletedDays(
        activeNovenaId,
        preferences.getStringList(StorageKeys.completedNovenaDays) ?? const [],
      );
    }
    if (decoded is Map) {
      final activeDays = decoded[activeNovenaId];
      if (activeDays is List) {
        return _validCompletedDays(activeNovenaId, activeDays);
      }
    }
  }

  return _validCompletedDays(
    activeNovenaId,
    preferences.getStringList(StorageKeys.completedNovenaDays) ?? const [],
  );
}

Set<int> _validCompletedDays(String novenaId, Iterable<Object?> rawDays) {
  final maxDays = novenaId == 'st_rita_novena' ? 12 : 9;
  return rawDays
      .map((day) => int.tryParse(day.toString()))
      .whereType<int>()
      .where((day) => day >= 1 && day <= maxDays)
      .toSet();
}
