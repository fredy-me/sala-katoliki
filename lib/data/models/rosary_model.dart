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

class RosaryMysteryModel {
  const RosaryMysteryModel({
    required this.id,
    required this.language,
    required this.title,
    required this.description,
    required this.days,
    required this.mysteries,
  });

  final String id;
  final String language;
  final String title;
  final String description;
  final List<String> days;
  final List<String> mysteries;

  factory RosaryMysteryModel.fromJson(Map<String, dynamic> json) {
    return RosaryMysteryModel(
      id: json['id'] as String,
      language: json['language'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      days: (json['days'] as List<dynamic>).cast<String>(),
      mysteries: (json['mysteries'] as List<dynamic>).cast<String>(),
    );
  }
}
