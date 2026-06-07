import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/localization/localization_providers.dart';
import '../../../../data/models/rosary_model.dart';
import '../../../../data/repositories/rosary_repository.dart';
import '../../../prayers/presentation/providers/prayer_providers.dart';
import '../../../prayers/domain/entities/prayer_entity.dart';
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
    Future<void>.microtask(() {
      ref.read(rosaryProgressProvider.notifier).clear();
    });
    return null;
  }

  final steps = await ref.watch(rosaryStepsProvider(mystery.id).future);
  if (steps.isEmpty ||
      progress.stepIndex < 0 ||
      progress.stepIndex >= steps.length) {
    Future<void>.microtask(() {
      ref.read(rosaryProgressProvider.notifier).clear();
    });
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
  final prayerIds = {for (final prayerRef in rosaryPrayers) prayerRef.id};
  final apostlesCreed = prayerIds.contains('apostles_creed')
      ? prayersById['apostles_creed']
      : null;
  final ourFather = prayerIds.contains('our_father')
      ? prayersById['our_father']
      : null;
  final hailMary = prayerIds.contains('hail_mary')
      ? prayersById['hail_mary']
      : null;
  final gloryBe = prayerIds.contains('glory_be')
      ? prayersById['glory_be']
      : null;
  final litany = prayerIds.contains('bikira_maria_litany')
      ? prayersById['bikira_maria_litany']
      : null;
  final steps = <RosaryStep>[];

  void addIntroStep({required PrayerEntity prayer, required int beadNumber}) {
    steps.add(
      RosaryStep(
        index: steps.length,
        prayer: prayer,
        decadeIndex: 0,
        beadNumber: beadNumber,
        beadTotal: 6,
      ),
    );
  }

  if (apostlesCreed != null) {
    addIntroStep(prayer: apostlesCreed, beadNumber: 1);
  }
  if (ourFather != null) {
    addIntroStep(prayer: ourFather, beadNumber: 2);
  }
  if (hailMary != null) {
    for (var repeat = 0; repeat < 3; repeat += 1) {
      addIntroStep(prayer: hailMary, beadNumber: repeat + 3);
    }
  }
  if (gloryBe != null) {
    addIntroStep(prayer: gloryBe, beadNumber: 6);
  }

  for (var decade = 0; decade < mystery.mysteries.length; decade += 1) {
    final mysteryTitle = mystery.mysteries[decade];
    final mysteryVirtue = mystery.virtueAt(decade);

    void addDecadeStep({
      required PrayerEntity prayer,
      required int beadNumber,
      required int beadTotal,
    }) {
      steps.add(
        RosaryStep(
          index: steps.length,
          prayer: prayer,
          decadeIndex: decade + 1,
          beadNumber: beadNumber,
          beadTotal: beadTotal,
          mysteryTitle: mysteryTitle,
          mysteryVirtue: mysteryVirtue,
        ),
      );
    }

    if (ourFather != null) {
      addDecadeStep(prayer: ourFather, beadNumber: 1, beadTotal: 12);
    }
    if (hailMary != null) {
      for (var repeat = 0; repeat < 10; repeat += 1) {
        addDecadeStep(prayer: hailMary, beadNumber: repeat + 2, beadTotal: 12);
      }
    }
    if (gloryBe != null) {
      addDecadeStep(prayer: gloryBe, beadNumber: 12, beadTotal: 12);
    }
  }

  if (litany != null) {
    steps.add(
      RosaryStep(
        index: steps.length,
        prayer: litany,
        decadeIndex: 6,
        beadNumber: 1,
        beadTotal: 1,
      ),
    );
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
