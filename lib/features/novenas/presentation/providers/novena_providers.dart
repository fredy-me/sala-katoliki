import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/localization/localization_providers.dart';
import '../../../../data/models/novena_model.dart';
import '../../../../data/repositories/novena_repository.dart';
import '../../../prayers/presentation/providers/prayer_providers.dart';
import '../../../today/presentation/providers/today_providers.dart';
import '../../domain/novena_state.dart';

final novenaRepositoryProvider = Provider<NovenaRepository>((ref) {
  return NovenaRepository(ref.watch(localContentDataSourceProvider));
});

final novenasProvider = FutureProvider<List<NovenaModel>>((ref) {
  final languageCode = ref.watch(activeLanguageProvider);
  return ref
      .watch(novenaRepositoryProvider)
      .getNovenas(languageCode: languageCode);
});

final novenaByIdProvider = FutureProvider.family<NovenaModel?, String>((
  ref,
  novenaId,
) async {
  final novenas = await ref.watch(novenasProvider.future);
  for (final novena in novenas) {
    if (novena.id == novenaId) {
      return novena;
    }
  }
  return null;
});

final activeNovenaSessionProvider = FutureProvider<NovenaSession?>((ref) async {
  final progress = await ref.watch(novenaProgressProvider.future);
  final activeId = progress.activeNovenaId;
  if (activeId == null) {
    return null;
  }

  final novena = await ref.watch(novenaByIdProvider(activeId).future);
  if (novena == null) {
    Future<void>.microtask(() {
      ref.read(novenaProgressProvider.notifier).clear();
    });
    return null;
  }

  return NovenaSession(novena: novena, progress: progress);
});

final novenaSessionProvider = FutureProvider.family<NovenaSession?, String>((
  ref,
  novenaId,
) async {
  final novena = await ref.watch(novenaByIdProvider(novenaId).future);
  if (novena == null) {
    return null;
  }

  final progress = await ref.watch(novenaProgressProvider.future);
  return NovenaSession(novena: novena, progress: progress);
});

final novenaProgressProvider =
    AsyncNotifierProvider<NovenaProgressNotifier, NovenaProgress>(
      NovenaProgressNotifier.new,
    );

final favoriteNovenaIdsProvider =
    AsyncNotifierProvider<FavoriteNovenaIdsNotifier, Set<String>>(
      FavoriteNovenaIdsNotifier.new,
    );

class FavoriteNovenaIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences
            .getStringList(StorageKeys.favoriteNovenaIds)
            ?.where((id) => id.trim().isNotEmpty)
            .toSet() ??
        <String>{};
  }

  Future<void> toggle(String novenaId) async {
    final current = state.asData?.value ?? await future;
    final updated = Set<String>.from(current);

    if (updated.contains(novenaId)) {
      updated.remove(novenaId);
    } else {
      updated.add(novenaId);
    }

    await _save(updated);
  }

  Future<void> remove(String novenaId) async {
    final current = state.asData?.value ?? await future;
    if (!current.contains(novenaId)) {
      return;
    }

    await _save(Set<String>.from(current)..remove(novenaId));
  }

  Future<void> _save(Set<String> ids) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      StorageKeys.favoriteNovenaIds,
      ids.toList()..sort(),
    );
    state = AsyncData(ids);
  }
}

class NovenaProgressNotifier extends AsyncNotifier<NovenaProgress> {
  @override
  Future<NovenaProgress> build() async {
    final preferences = await SharedPreferences.getInstance();
    final activeNovenaId = preferences.getString(StorageKeys.activeNovenaId);
    final completedDaysByNovenaId = _readCompletedDaysByNovenaId(preferences);

    if (activeNovenaId != null &&
        !completedDaysByNovenaId.containsKey(activeNovenaId)) {
      completedDaysByNovenaId[activeNovenaId] = _validCompletedDaysForNovena(
        activeNovenaId,
        preferences.getStringList(StorageKeys.completedNovenaDays) ?? const [],
      );
      await _writeProgressMap(preferences, completedDaysByNovenaId);
    }

    return NovenaProgress(
      activeNovenaId: activeNovenaId,
      completedDaysByNovenaId: completedDaysByNovenaId,
    );
  }

  Future<void> start(String novenaId) async {
    final current = state.asData?.value ?? await future;
    final completedDaysByNovenaId = _copyCompletedDaysByNovenaId(current);
    completedDaysByNovenaId.putIfAbsent(novenaId, () => const <int>{});

    await _save(
      NovenaProgress(
        activeNovenaId: novenaId,
        completedDaysByNovenaId: completedDaysByNovenaId,
      ),
    );
  }

  Future<void> restart(String novenaId) async {
    final current = state.asData?.value ?? await future;
    final completedDaysByNovenaId = _copyCompletedDaysByNovenaId(current);
    completedDaysByNovenaId[novenaId] = const <int>{};

    await _save(
      NovenaProgress(
        activeNovenaId: novenaId,
        completedDaysByNovenaId: completedDaysByNovenaId,
      ),
    );
  }

  Future<void> completeDay(String novenaId, int day) async {
    if (day < 1 || day > _maxDaysForNovena(novenaId)) {
      return;
    }

    final current = state.asData?.value ?? await future;
    final completedDaysByNovenaId = _copyCompletedDaysByNovenaId(current);
    final completedDays = current.completedDaysFor(novenaId);
    completedDaysByNovenaId[novenaId] = {...completedDays, day};

    final completedNovena = day == _maxDaysForNovena(novenaId);
    if (completedNovena) {
      completedDaysByNovenaId.remove(novenaId);
    }

    await _save(
      NovenaProgress(
        activeNovenaId: completedNovena
            ? (current.activeNovenaId == novenaId
                  ? null
                  : current.activeNovenaId)
            : novenaId,
        completedDaysByNovenaId: completedDaysByNovenaId,
      ),
    );
  }

  Future<void> clear() async {
    await _save(
      const NovenaProgress(activeNovenaId: null, completedDaysByNovenaId: {}),
    );
  }

  Future<void> _save(NovenaProgress progress) async {
    final preferences = await SharedPreferences.getInstance();
    if (progress.activeNovenaId == null) {
      await preferences.remove(StorageKeys.activeNovenaId);
      await preferences.remove(StorageKeys.completedNovenaDays);
    } else {
      await preferences.setString(
        StorageKeys.activeNovenaId,
        progress.activeNovenaId!,
      );
      await _writeLegacyActiveCompletedDays(preferences, progress);
    }

    await _writeProgressMap(preferences, progress.completedDaysByNovenaId);

    state = AsyncData(
      NovenaProgress(
        activeNovenaId: progress.activeNovenaId,
        completedDaysByNovenaId: _copyCompletedDaysByNovenaId(progress),
      ),
    );
    ref.invalidate(todayLocalStateProvider);
  }

  Map<String, Set<int>> _readCompletedDaysByNovenaId(
    SharedPreferences preferences,
  ) {
    final raw = preferences.getString(StorageKeys.novenaProgressById);
    if (raw == null || raw.isEmpty) {
      return {};
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return {};
    }
    if (decoded is! Map) {
      return {};
    }

    return {
      for (final entry in decoded.entries)
        if (entry.key is String && entry.value is List)
          entry.key as String: _validCompletedDaysForNovena(
            entry.key as String,
            entry.value as List,
          ),
    };
  }

  Map<String, Set<int>> _copyCompletedDaysByNovenaId(NovenaProgress progress) {
    return {
      for (final entry in progress.completedDaysByNovenaId.entries)
        entry.key: {...entry.value},
    };
  }

  Future<void> _writeProgressMap(
    SharedPreferences preferences,
    Map<String, Set<int>> completedDaysByNovenaId,
  ) async {
    if (completedDaysByNovenaId.isEmpty) {
      await preferences.remove(StorageKeys.novenaProgressById);
      return;
    }

    final encoded = jsonEncode({
      for (final entry in completedDaysByNovenaId.entries)
        entry.key: _sortedValidDaysForNovena(entry.key, entry.value),
    });
    await preferences.setString(StorageKeys.novenaProgressById, encoded);
  }

  Future<void> _writeLegacyActiveCompletedDays(
    SharedPreferences preferences,
    NovenaProgress progress,
  ) async {
    await preferences.setStringList(
      StorageKeys.completedNovenaDays,
      _sortedValidDaysForNovena(
        progress.activeNovenaId!,
        progress.completedDays,
      ).map((day) => day.toString()).toList(growable: false),
    );
  }

  List<int> _sortedValidDaysForNovena(String novenaId, Iterable<int> days) {
    final maxDays = _maxDaysForNovena(novenaId);
    return days.where((day) => day >= 1 && day <= maxDays).toList()..sort();
  }

  Set<int> _validCompletedDaysForNovena(
    String novenaId,
    Iterable<Object?> rawDays,
  ) {
    final maxDays = _maxDaysForNovena(novenaId);
    return rawDays
        .map((day) => int.tryParse(day.toString()))
        .whereType<int>()
        .where((day) => day >= 1 && day <= maxDays)
        .toSet();
  }

  int _maxDaysForNovena(String novenaId) =>
      novenaId == 'st_rita_novena' ? 12 : 9;
}
