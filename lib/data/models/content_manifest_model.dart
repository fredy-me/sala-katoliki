class ContentManifestModel {
  const ContentManifestModel({
    required this.version,
    required this.languages,
    required this.categoriesPath,
    required this.prayerPaths,
    required this.rosaryPaths,
    required this.novenaPaths,
  });

  final int version;
  final List<String> languages;
  final String categoriesPath;
  final Map<String, List<String>> prayerPaths;
  final Map<String, List<String>> rosaryPaths;
  final Map<String, List<String>> novenaPaths;

  factory ContentManifestModel.fromJson(Map<String, dynamic> json) {
    return ContentManifestModel(
      version: json['version'] as int,
      languages: (json['languages'] as List<dynamic>).cast<String>(),
      categoriesPath: json['categories'] as String,
      prayerPaths: _pathsByLanguage(json['prayers'] as Map<String, dynamic>),
      rosaryPaths: _pathsByLanguage(json['rosary'] as Map<String, dynamic>),
      novenaPaths: _pathsByLanguage(json['novenas'] as Map<String, dynamic>),
    );
  }

  static Map<String, List<String>> _pathsByLanguage(
    Map<String, dynamic> value,
  ) {
    return value.map(
      (language, paths) =>
          MapEntry(language, (paths as List<dynamic>).cast<String>()),
    );
  }
}
