class NovenaModel {
  const NovenaModel({
    required this.id,
    required this.language,
    required this.title,
    required this.description,
    required this.days,
    this.source,
    this.version,
    this.lastUpdated,
    this.closingPrayer,
  });

  final String id;
  final String language;
  final String title;
  final String description;
  final List<NovenaDayModel> days;
  final String? source;
  final int? version;
  final DateTime? lastUpdated;
  final NovenaClosingPrayerModel? closingPrayer;

  factory NovenaModel.fromJson(Map<String, dynamic> json) {
    return NovenaModel(
      id: json['id'] as String,
      language: json['language'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      source: json['source'] as String?,
      version: json['version'] as int?,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      closingPrayer: json['closing_prayer'] == null
          ? null
          : NovenaClosingPrayerModel.fromJson(
              json['closing_prayer'] as Map<String, dynamic>,
            ),
      days: (json['days'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(NovenaDayModel.fromJson)
          .toList(growable: false),
    );
  }
}

class NovenaClosingPrayerModel {
  const NovenaClosingPrayerModel({
    required this.title,
    required this.description,
    required this.body,
  });

  final String title;
  final String description;
  final String body;

  factory NovenaClosingPrayerModel.fromJson(Map<String, dynamic> json) {
    return NovenaClosingPrayerModel(
      title: json['title'] as String,
      description: json['description'] as String,
      body: json['body'] as String,
    );
  }
}

class NovenaDayModel {
  const NovenaDayModel({
    required this.day,
    required this.title,
    required this.body,
  });

  final int day;
  final String title;
  final String body;

  factory NovenaDayModel.fromJson(Map<String, dynamic> json) {
    return NovenaDayModel(
      day: json['day'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
