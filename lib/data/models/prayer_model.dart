import '../../features/prayers/domain/entities/prayer_entity.dart';

class PrayerModel extends PrayerEntity {
  const PrayerModel({
    required super.id,
    required super.type,
    required super.categoryId,
    required super.language,
    required super.localizedTitle,
    required super.body,
    required super.categoryTitles,
    super.description,
    super.tags,
    super.source,
    super.version,
    super.lastUpdated,
    super.isOfflineAvailable,
    super.isFavorite,
  });

  factory PrayerModel.fromJson(
    Map<String, dynamic> json, {
    required Map<String, String> categoryTitles,
  }) {
    return PrayerModel(
      id: json['id'] as String,
      type: json['type'] as String,
      categoryId: json['category'] as String,
      language: json['language'] as String,
      localizedTitle: json['title'] as String,
      description: json['description'] as String?,
      body: json['body'] as String,
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((tag) => tag as String)
              .toList(growable: false) ??
          const [],
      source: json['source'] as String?,
      version: json['version'] as int?,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      isOfflineAvailable: json['is_offline_available'] as bool? ?? true,
      categoryTitles: categoryTitles,
    );
  }
}
