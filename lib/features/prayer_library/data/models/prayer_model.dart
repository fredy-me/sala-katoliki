import '../../domain/entities/prayer_entity.dart';

class PrayerModel extends PrayerEntity {
  const PrayerModel({
    required super.id,
    required super.category,
    required super.categorySw,
    required super.titles,
    required super.texts,
    super.isFavorite,
  });

  factory PrayerModel.fromJson(Map<String, dynamic> json) {
    return PrayerModel(
      id: json['id'] as String,
      category: json['category'] as String,
      categorySw: json['categorySw'] as String,
      titles: Map<String, String>.from(json['titles'] as Map),
      texts: Map<String, String>.from(json['texts'] as Map),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
