import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../novenas/presentation/providers/novena_providers.dart';

final todayLocalStateProvider = FutureProvider<TodayLocalState>((ref) async {
  final preferences = await SharedPreferences.getInstance();
  final activeNovenaId = preferences.getString(StorageKeys.activeNovenaId);

  // 6.2: the active novena's length comes from content, not a hardcoded per-id
  // literal. Resolved only for the active novena, so the Today path reads one
  // file — the 5.3 property that a corpus-wide day-count map destroyed.
  final knownDayCount = activeNovenaId == null
      ? null
      : await ref.watch(novenaDayCountProvider(activeNovenaId).future);
  final totalNovenaDays = knownDayCount ?? defaultNovenaDayCount;

  final completedDays = activeNovenaId == null
      ? const <int>{}
      : _completedDaysForActiveNovena(
          preferences,
          activeNovenaId,
          knownDayCount,
        );

  return TodayLocalState(
    activeNovenaId: activeNovenaId,
    completedNovenaDays: completedDays,
    reminderEnabled: preferences.getBool(StorageKeys.reminderEnabled) ?? false,
    reminderTime: preferences.getString(StorageKeys.reminderTime),
    totalNovenaDays: totalNovenaDays,
  );
});

class TodayLocalState {
  const TodayLocalState({
    required this.activeNovenaId,
    required this.completedNovenaDays,
    required this.reminderEnabled,
    required this.reminderTime,
    this.totalNovenaDays = defaultNovenaDayCount,
  });

  final String? activeNovenaId;
  final Set<int> completedNovenaDays;
  final bool reminderEnabled;
  final String? reminderTime;

  /// 6.2. How many days the active novena has, supplied by the provider from
  /// content. Was `activeNovenaId == 'st_rita_novena' ? 12 : 9` computed inline,
  /// which meant the Today progress bar and "next day" number were wrong for
  /// any novena of a different length.
  final int totalNovenaDays;

  // 5.6: this is built fresh on every read of the provider, so with identity
  // equality every unrelated settings change produced a state that compared
  // unequal and rebuilt the Today screen. The set is compared by value, which
  // is why the provider returns a new set each time rather than sharing one.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TodayLocalState &&
            runtimeType == other.runtimeType &&
            activeNovenaId == other.activeNovenaId &&
            setEquals(completedNovenaDays, other.completedNovenaDays) &&
            reminderEnabled == other.reminderEnabled &&
            reminderTime == other.reminderTime &&
            totalNovenaDays == other.totalNovenaDays;
  }

  @override
  int get hashCode => Object.hash(
    activeNovenaId,
    Object.hashAllUnordered(completedNovenaDays),
    reminderEnabled,
    reminderTime,
    totalNovenaDays,
  );

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
  int? totalNovenaDays,
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
        totalNovenaDays,
      );
    }
    if (decoded is Map) {
      final activeDays = decoded[activeNovenaId];
      if (activeDays is List) {
        return _validCompletedDays(activeNovenaId, activeDays, totalNovenaDays);
      }
    }
  }

  return _validCompletedDays(
    activeNovenaId,
    preferences.getStringList(StorageKeys.completedNovenaDays) ?? const [],
    totalNovenaDays,
  );
}

Set<int> _validCompletedDays(
  String novenaId,
  Iterable<Object?> rawDays,
  int? totalNovenaDays,
) {
  final maxDays = totalNovenaDays;
  return rawDays
      .map((day) => int.tryParse(day.toString()))
      .whereType<int>()
      .where((day) => day >= 1 && (maxDays == null || day <= maxDays))
      .toSet();
}
