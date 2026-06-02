class PrayerEntity {
  const PrayerEntity({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.language,
    required this.localizedTitle,
    required this.body,
    required this.categoryTitles,
    this.description,
    this.tags = const [],
    this.source,
    this.version,
    this.lastUpdated,
    this.isOfflineAvailable = true,
    this.isFavorite = false,
  });

  final String id;
  final String type;
  final String categoryId;
  final String language;
  final String localizedTitle;
  final String body;
  final Map<String, String> categoryTitles;
  final String? description;
  final List<String> tags;
  final String? source;
  final int? version;
  final DateTime? lastUpdated;
  final bool isOfflineAvailable;
  final bool isFavorite;

  String title([String? languageCode]) {
    return localizedTitle;
  }

  String text([String? languageCode]) {
    return body;
  }

  String categoryLabel([String? languageCode]) {
    final effectiveLanguageCode = languageCode ?? language;
    return categoryTitles[effectiveLanguageCode] ??
        categoryTitles['en'] ??
        categoryId.replaceAll('_', ' ');
  }

  bool matches(String query, [String? languageCode]) {
    final effectiveLanguageCode = languageCode ?? language;
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }

    return title(effectiveLanguageCode).toLowerCase().contains(normalized) ||
        categoryLabel(
          effectiveLanguageCode,
        ).toLowerCase().contains(normalized) ||
        text(effectiveLanguageCode).toLowerCase().contains(normalized) ||
        tags.any((tag) => tag.toLowerCase().contains(normalized));
  }
}
