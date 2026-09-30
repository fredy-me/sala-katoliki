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

  /// 4.7: the lowercased search haystack, computed once per language.
  ///
  /// `score()` previously lowercased the title, the category label and the body
  /// on every call, and the library calls it for all 36 prayers on every
  /// keystroke — roughly 82 KB of allocation per character typed. The haystack
  /// cannot change while the entity lives, so it is derived on first use.
  ///
  /// This hangs off an [Expando] keyed by the entity rather than a `static`
  /// map keyed by id, so the memo cannot outlive the entity it describes. A
  /// `static` map keyed by id would also be wrong in principle: two entities
  /// with the same id but different text would share one index.
  static final Expando<Map<String, _PrayerSearchIndex>> _searchIndexes =
      Expando<Map<String, _PrayerSearchIndex>>('prayerSearchIndexes');

  _PrayerSearchIndex _searchIndexFor(String languageCode) {
    final cache =
        _searchIndexes[this] ??= <String, _PrayerSearchIndex>{};
    return cache.putIfAbsent(languageCode, () {
      return _PrayerSearchIndex(
        title: title(languageCode).toLowerCase(),
        category: categoryLabel(languageCode).toLowerCase(),
        body: text(languageCode).toLowerCase(),
        tags: [for (final tag in tags) tag.toLowerCase()],
      );
    });
  }

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

    final index = _searchIndexFor(effectiveLanguageCode);

    return index.title.contains(normalized) ||
        index.category.contains(normalized) ||
        index.body.contains(normalized) ||
        index.tags.any((tag) => tag.contains(normalized));
  }

  /// Returns a relevance score for the given [query].
  /// Higher score = better match. Returns 0 if no match.
  int score(String query, [String? languageCode]) {
    final effectiveLanguageCode = languageCode ?? language;
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 1;
    }

    final index = _searchIndexFor(effectiveLanguageCode);

    // Title scoring
    if (index.title == normalized) return 100;
    if (index.title.startsWith(normalized)) return 90;
    if (index.title.contains(normalized)) return 80;

    // Tag scoring
    for (final tagLower in index.tags) {
      if (tagLower == normalized) return 70;
      if (tagLower.startsWith(normalized)) return 60;
      if (tagLower.contains(normalized)) return 50;
    }

    // Category scoring
    if (index.category == normalized) return 45;
    if (index.category.contains(normalized)) return 40;

    // Body scoring (only for queries 3+ chars to reduce noise)
    if (normalized.length >= 3 && index.body.contains(normalized)) {
      return 30;
    }

    return 0;
  }
}

/// The precomputed lowercase form of everything [PrayerEntity.score] compares a
/// query against. Derived once per language; see [_searchIndexFor].
class _PrayerSearchIndex {
  const _PrayerSearchIndex({
    required this.title,
    required this.category,
    required this.body,
    required this.tags,
  });

  final String title;
  final String category;
  final String body;
  final List<String> tags;
}

/// Returns the prayer featured for today, rotating deterministically by day.
PrayerEntity? dailyPrayerFor(List<PrayerEntity> prayers) {
  if (prayers.isEmpty) {
    return null;
  }
  return prayers[DateTime.now().day % prayers.length];
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
