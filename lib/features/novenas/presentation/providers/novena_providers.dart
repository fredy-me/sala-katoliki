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

class NovenaProgressNotifier extends AsyncNotifier<NovenaProgress> {
  @override
  Future<NovenaProgress> build() async {
    final preferences = await SharedPreferences.getInstance();
    return NovenaProgress(
      activeNovenaId: preferences.getString(StorageKeys.activeNovenaId),
      completedDays: _validCompletedDays(
        preferences.getStringList(StorageKeys.completedNovenaDays) ?? const [],
      ),
    );
  }

  Future<void> start(String novenaId) async {
    await _save(
      NovenaProgress(activeNovenaId: novenaId, completedDays: const {}),
    );
  }

  Future<void> completeDay(String novenaId, int day) async {
    if (day < 1 || day > 9) {
      return;
    }

    final current = state.asData?.value ?? await future;
    final completedDays = current.activeNovenaId == novenaId
        ? current.completedDays
        : const <int>{};

    await _save(
      NovenaProgress(
        activeNovenaId: novenaId,
        completedDays: {...completedDays, day},
      ),
    );
  }

  Future<void> clear() async {
    await _save(const NovenaProgress(activeNovenaId: null, completedDays: {}));
  }

  Future<void> _save(NovenaProgress progress) async {
    final preferences = await SharedPreferences.getInstance();
    if (progress.activeNovenaId == null) {
      await preferences.remove(StorageKeys.activeNovenaId);
    } else {
      await preferences.setString(
        StorageKeys.activeNovenaId,
        progress.activeNovenaId!,
      );
    }

    final completed =
        progress.completedDays.where((day) => day >= 1 && day <= 9).toList()
          ..sort();
    await preferences.setStringList(
      StorageKeys.completedNovenaDays,
      completed.map((day) => day.toString()).toList(growable: false),
    );

    state = AsyncData(
      NovenaProgress(
        activeNovenaId: progress.activeNovenaId,
        completedDays: completed.toSet(),
      ),
    );
    ref.invalidate(todayLocalStateProvider);
  }

  Set<int> _validCompletedDays(List<String> rawDays) {
    return rawDays
        .map(int.tryParse)
        .whereType<int>()
        .where((day) => day >= 1 && day <= 9)
        .toSet();
  }
}
