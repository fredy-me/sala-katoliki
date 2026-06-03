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
  });

  final int index;
  final PrayerEntity prayer;
  final int decadeIndex;
  final int beadNumber;
  final int beadTotal;
  final String? mysteryTitle;

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

  RosaryStep get currentStep => steps[stepIndex];
  bool get canGoPrevious => stepIndex > 0;
  bool get canGoNext => stepIndex < steps.length - 1;
  double get progress => steps.isEmpty ? 0 : (stepIndex + 1) / steps.length;
}

class RosaryProgress {
  const RosaryProgress({required this.mysteryId, required this.stepIndex});

  final String mysteryId;
  final int stepIndex;
}
