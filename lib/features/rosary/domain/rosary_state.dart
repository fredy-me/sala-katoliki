import 'package:flutter/foundation.dart';

import '../../../data/models/rosary_model.dart';
import '../../prayers/domain/entities/prayer_entity.dart';

class RosaryStep {
  const RosaryStep({
    required this.index,
    required this.prayer,
    required this.decadeIndex,
    required this.beadNumber,
    required this.beadTotal,
    this.mysteryTitle,
    this.mysteryVirtue,
  });

  final int index;
  final PrayerEntity prayer;
  final int decadeIndex;
  final int beadNumber;
  final int beadTotal;
  final String? mysteryTitle;
  final String? mysteryVirtue;

  // 5.6: `RosarySession` compares its step list by value, which is delegated
  // to this operator. Without it, a session rebuilt from the same rosary data
  // would still compare unequal to the previous one and the equality on
  // RosarySession would buy nothing. The prayer keeps identity equality,
  // which is correct: it is the cached content object, so two steps really do
  // hold the same instance.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RosaryStep &&
            runtimeType == other.runtimeType &&
            index == other.index &&
            prayer == other.prayer &&
            decadeIndex == other.decadeIndex &&
            beadNumber == other.beadNumber &&
            beadTotal == other.beadTotal &&
            mysteryTitle == other.mysteryTitle &&
            mysteryVirtue == other.mysteryVirtue;
  }

  @override
  int get hashCode => Object.hash(
    index,
    prayer,
    decadeIndex,
    beadNumber,
    beadTotal,
    mysteryTitle,
    mysteryVirtue,
  );

  bool get isIntro => decadeIndex == 0;
}

class RosarySession {
  const RosarySession({
    required this.mystery,
    required this.steps,
    required this.stepIndex,
  });

  final RosaryMysteryModel mystery;
  final List<RosaryStep> steps;
  final int stepIndex;

  // 5.6: the step list is rebuilt on every session read, so identity equality
  // made each read a "new" session and re-notified the rosary screens. The
  // list is never mutated in place — the providers construct a new
  // `RosarySession` for each index — so comparing it by value is safe.
  // `RosaryStep` and the models keep identity equality, which is correct:
  // they are the cached content objects and two sessions at the same index
  // genuinely hold the same instances.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RosarySession &&
            runtimeType == other.runtimeType &&
            mystery == other.mystery &&
            stepIndex == other.stepIndex &&
            listEquals(steps, other.steps);
  }

  @override
  int get hashCode => Object.hash(mystery, stepIndex, Object.hashAll(steps));

  RosaryStep get currentStep => steps[stepIndex];
  bool get canGoPrevious => stepIndex > 0;
  bool get canGoNext => stepIndex < steps.length - 1;
  double get progress => steps.isEmpty ? 0 : (stepIndex + 1) / steps.length;
}

class RosaryProgress {
  const RosaryProgress({required this.mysteryId, required this.stepIndex});

  final String mysteryId;
  final int stepIndex;

  // 5.6: two scalars, so value equality is exact and complete. Persisting an
  // unchanged step no longer produced a state that compared unequal.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RosaryProgress &&
            runtimeType == other.runtimeType &&
            mysteryId == other.mysteryId &&
            stepIndex == other.stepIndex;
  }

  @override
  int get hashCode => Object.hash(mysteryId, stepIndex);
}
