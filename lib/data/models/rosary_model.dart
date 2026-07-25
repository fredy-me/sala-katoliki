class RosaryPrayerModel {
  const RosaryPrayerModel({
    required this.id,
    required this.prayerId,
    required this.repeatCount,
  });

  final String id;
  final String prayerId;
  final int repeatCount;

  factory RosaryPrayerModel.fromJson(Map<String, dynamic> json) {
    return RosaryPrayerModel(
      id: json['id'] as String,
      prayerId: json['prayer_id'] as String,
      repeatCount: json['repeat_count'] as int,
    );
  }
}

class RosaryPrayerStep {
  const RosaryPrayerStep({
    required this.prayerId,
    required this.repeatCount,
  });

  final String prayerId;
  final int repeatCount;

  factory RosaryPrayerStep.fromJson(Map<String, dynamic> json) {
    return RosaryPrayerStep(
      prayerId: json['prayer_id'] as String,
      repeatCount: json['repeat_count'] as int,
    );
  }
}

class RosaryPrayerSequence {
  const RosaryPrayerSequence({
    this.intro = const [],
    this.decade = const [],
    this.closing = const [],
  });

  final List<RosaryPrayerStep> intro;
  final List<RosaryPrayerStep> decade;
  final List<RosaryPrayerStep> closing;

  bool get hasCustomSequence => intro.isNotEmpty || decade.isNotEmpty || closing.isNotEmpty;

  factory RosaryPrayerSequence.fromJson(Map<String, dynamic> json) {
    return RosaryPrayerSequence(
      intro: (json['intro'] as List<dynamic>?)
              ?.map((e) => RosaryPrayerStep.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      decade: (json['decade'] as List<dynamic>?)
              ?.map((e) => RosaryPrayerStep.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      closing: (json['closing'] as List<dynamic>?)
              ?.map((e) => RosaryPrayerStep.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
    );
  }
}

class RosaryMysteryModel {
  const RosaryMysteryModel({
    required this.id,
    required this.language,
    required this.title,
    required this.description,
    required this.days,
    required this.mysteries,
    this.virtues = const [],
    this.prayerSequence,
  });

  final String id;
  final String language;
  final String title;
  final String description;
  final List<String> days;
  final List<String> mysteries;
  final List<String> virtues;
  final RosaryPrayerSequence? prayerSequence;

  bool get hasCustomPrayerSequence => prayerSequence?.hasCustomSequence ?? false;

  factory RosaryMysteryModel.fromJson(Map<String, dynamic> json) {
    return RosaryMysteryModel(
      id: json['id'] as String,
      language: json['language'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      days: (json['days'] as List<dynamic>).cast<String>(),
      mysteries: (json['mysteries'] as List<dynamic>).cast<String>(),
      virtues: (json['virtues'] as List<dynamic>?)?.cast<String>() ?? const [],
      prayerSequence: json['prayer_sequence'] != null
          ? RosaryPrayerSequence.fromJson(
              json['prayer_sequence'] as Map<String, dynamic>)
          : null,
    );
  }

  String? virtueAt(int index) {
    if (index < 0 || index >= virtues.length) {
      return null;
    }
    final virtue = virtues[index].trim();
    return virtue.isEmpty ? null : virtue;
  }
}
