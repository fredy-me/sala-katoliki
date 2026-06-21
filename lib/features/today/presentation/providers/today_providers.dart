import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';

final todayLocalStateProvider = FutureProvider<TodayLocalState>((ref) async {
  final preferences = await SharedPreferences.getInstance();
  final activeNovenaId = preferences.getString(StorageKeys.activeNovenaId);
  final completedDays =
      preferences.getStringList(StorageKeys.completedNovenaDays) ?? const [];

  return TodayLocalState(
    activeNovenaId: activeNovenaId,
    completedNovenaDays: completedDays
        .map(int.tryParse)
        .whereType<int>()
        .where((day) => day >= 1 && day <= 12)
        .toSet(),
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
