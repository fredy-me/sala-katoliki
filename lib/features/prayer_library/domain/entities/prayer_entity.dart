class PrayerEntity {
  const PrayerEntity({
    required this.id,
    required this.category,
    required this.categorySw,
    required this.titles,
    required this.texts,
    this.isFavorite = false,
  });

  final String id;
  final String category;
  final String categorySw;
  final Map<String, String> titles;
  final Map<String, String> texts;
  final bool isFavorite;

  String title([String languageCode = 'sw']) {
    return titles[languageCode] ?? titles['en'] ?? titles.values.first;
  }

  String text([String languageCode = 'sw']) {
    return texts[languageCode] ?? texts['en'] ?? texts.values.first;
  }

  String categoryLabel([String languageCode = 'sw']) {
    return languageCode == 'sw' ? categorySw : category;
  }

  bool matches(String query, [String languageCode = 'sw']) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }

    return title(languageCode).toLowerCase().contains(normalized) ||
        categoryLabel(languageCode).toLowerCase().contains(normalized) ||
        text(languageCode).toLowerCase().contains(normalized);
  }
}
