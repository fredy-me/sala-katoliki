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
    this.showTitle = true,
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
  final bool showTitle;

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

  /// Returns a relevance score for the given [query].
  /// Higher score = better match. Returns 0 if no match.
  int score(String query, [String? languageCode]) {
    final effectiveLanguageCode = languageCode ?? language;
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 1;
    }

    final titleLower = title(effectiveLanguageCode).toLowerCase();
    final categoryLower = categoryLabel(effectiveLanguageCode).toLowerCase();
    final bodyLower = text(effectiveLanguageCode).toLowerCase();

    // Title scoring
    if (titleLower == normalized) return 100;
    if (titleLower.startsWith(normalized)) return 90;
    if (titleLower.contains(normalized)) return 80;

    // Tag scoring
    for (final tag in tags) {
      final tagLower = tag.toLowerCase();
      if (tagLower == normalized) return 70;
      if (tagLower.startsWith(normalized)) return 60;
      if (tagLower.contains(normalized)) return 50;
    }

    // Category scoring
    if (categoryLower == normalized) return 45;
    if (categoryLower.contains(normalized)) return 40;

    // Body scoring (only for queries 3+ chars to reduce noise)
    if (normalized.length >= 3 && bodyLower.contains(normalized)) {
      return 30;
    }

    return 0;
  }
}

/// Scores a novena against a search query.
/// Returns 0 if no match.
int scoreNovena(String title, String description, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return 1;
  }

  final titleLower = title.toLowerCase();
  final descLower = description.toLowerCase();

  if (titleLower == normalized) return 100;
  if (titleLower.startsWith(normalized)) return 90;
  if (titleLower.contains(normalized)) return 80;
  if (descLower.contains(normalized)) return 30;

  return 0;
}
