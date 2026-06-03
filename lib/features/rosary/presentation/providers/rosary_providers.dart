import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/localization/localization_providers.dart';
import '../../../../data/models/rosary_model.dart';
import '../../../../data/repositories/rosary_repository.dart';
import '../../../prayers/presentation/providers/prayer_providers.dart';
import '../../domain/rosary_state.dart';

final rosaryRepositoryProvider = Provider<RosaryRepository>((ref) {
  return RosaryRepository(ref.watch(localContentDataSourceProvider));
});

final rosaryMysteriesProvider = FutureProvider<List<RosaryMysteryModel>>((ref) {
  final languageCode = ref.watch(activeLanguageProvider);
  return ref
      .watch(rosaryRepositoryProvider)
      .getRosaryMysteries(languageCode: languageCode);
});

final rosaryPrayerSequenceProvider = FutureProvider<List<RosaryPrayerModel>>((
  ref,
) {
  final languageCode = ref.watch(activeLanguageProvider);
  return ref
      .watch(rosaryRepositoryProvider)
      .getRosaryPrayers(languageCode: languageCode);
});

final suggestedRosaryMysteryProvider = FutureProvider<RosaryMysteryModel?>((
  ref,
) async {
  final mysteries = await ref.watch(rosaryMysteriesProvider.future);
  final dayName = _dayName(DateTime.now().weekday);
  return _mysteryForDay(mysteries, dayName) ??
      (mysteries.isEmpty ? null : mysteries.first);
});

final rosaryProgressProvider =
    AsyncNotifierProvider<RosaryProgressNotifier, RosaryProgress?>(
      RosaryProgressNotifier.new,
    );

final activeRosarySessionProvider = FutureProvider<RosarySession?>((ref) async {
  final progress = await ref.watch(rosaryProgressProvider.future);
  if (progress == null) {
    return null;
  }

  final mysteries = await ref.watch(rosaryMysteriesProvider.future);
  final mystery = _mysteryById(mysteries, progress.mysteryId);
  if (mystery == null) {
    await ref.read(rosaryProgressProvider.notifier).clear();
    return null;
  }

  final steps = await ref.watch(rosaryStepsProvider(mystery.id).future);
  if (steps.isEmpty ||
      progress.stepIndex < 0 ||
      progress.stepIndex >= steps.length) {
    await ref.read(rosaryProgressProvider.notifier).clear();
    return null;
  }

  return RosarySession(
    mystery: mystery,
    steps: steps,
    stepIndex: progress.stepIndex,
  );
});

final rosarySessionProvider = FutureProvider.family<RosarySession?, String>((
  ref,
  mysteryId,
) async {
  final mysteries = await ref.watch(rosaryMysteriesProvider.future);
  final mystery = _mysteryById(mysteries, mysteryId);
  if (mystery == null) {
    return null;
  }

  final steps = await ref.watch(rosaryStepsProvider(mysteryId).future);
  if (steps.isEmpty) {
    return null;
  }

  final progress = await ref.watch(rosaryProgressProvider.future);
  final stepIndex = progress?.mysteryId == mysteryId
      ? progress!.stepIndex.clamp(0, steps.length - 1)
      : 0;

  return RosarySession(mystery: mystery, steps: steps, stepIndex: stepIndex);
});

final rosaryStepsProvider = FutureProvider.family<List<RosaryStep>, String>((
  ref,
  mysteryId,
) async {
  final mysteries = await ref.watch(rosaryMysteriesProvider.future);
  final mystery = _mysteryById(mysteries, mysteryId);
  if (mystery == null) {
    return const [];
  }

  final rosaryPrayers = await ref.watch(rosaryPrayerSequenceProvider.future);
  final prayers = await ref.watch(prayersProvider.future);
  final prayersById = {for (final prayer in prayers) prayer.id: prayer};
  final steps = <RosaryStep>[];

  for (final prayerRef in rosaryPrayers) {
    final prayer = prayersById[prayerRef.prayerId];
    if (prayer == null) {
      continue;
    }

    if (prayerRef.id == 'apostles_creed') {
      steps.add(
        RosaryStep(
          index: steps.length,
          prayer: prayer,
          decadeIndex: 0,
          beadNumber: 1,
          beadTotal: 1,
        ),
      );
      continue;
    }

    for (var decade = 0; decade < mystery.mysteries.length; decade += 1) {
      for (var repeat = 0; repeat < prayerRef.repeatCount; repeat += 1) {
        steps.add(
          RosaryStep(
            index: steps.length,
            prayer: prayer,
            decadeIndex: decade + 1,
            beadNumber: repeat + 1,
            beadTotal: prayerRef.repeatCount,
            mysteryTitle: mystery.mysteries[decade],
          ),
        );
      }
    }
  }

  return steps;
});

class RosaryProgressNotifier extends AsyncNotifier<RosaryProgress?> {
  @override
  Future<RosaryProgress?> build() async {
    final preferences = await SharedPreferences.getInstance();
    final mysteryId = preferences.getString(StorageKeys.rosaryMysteryId);
    final stepIndex = preferences.getInt(StorageKeys.rosaryStepIndex);
    if (mysteryId == null || stepIndex == null) {
      return null;
    }

    return RosaryProgress(mysteryId: mysteryId, stepIndex: stepIndex);
  }

  Future<void> start(String mysteryId) async {
    await save(mysteryId: mysteryId, stepIndex: 0);
  }

  Future<void> save({required String mysteryId, required int stepIndex}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(StorageKeys.rosaryMysteryId, mysteryId);
    await preferences.setInt(StorageKeys.rosaryStepIndex, stepIndex);
    state = AsyncData(
      RosaryProgress(mysteryId: mysteryId, stepIndex: stepIndex),
    );
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(StorageKeys.rosaryMysteryId);
    await preferences.remove(StorageKeys.rosaryStepIndex);
    state = const AsyncData(null);
  }
}

RosaryMysteryModel? _mysteryById(
  List<RosaryMysteryModel> mysteries,
  String mysteryId,
) {
  for (final mystery in mysteries) {
    if (mystery.id == mysteryId) {
      return mystery;
    }
  }
  return null;
}

RosaryMysteryModel? _mysteryForDay(
  List<RosaryMysteryModel> mysteries,
  String dayName,
) {
  for (final mystery in mysteries) {
    if (mystery.days.contains(dayName)) {
      return mystery;
    }
  }
  return null;
}

String _dayName(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'monday',
    DateTime.tuesday => 'tuesday',
    DateTime.wednesday => 'wednesday',
    DateTime.thursday => 'thursday',
    DateTime.friday => 'friday',
    DateTime.saturday => 'saturday',
    _ => 'sunday',
  };
}
