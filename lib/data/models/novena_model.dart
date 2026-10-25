import '../../shared/content/reading_markup.dart';

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
    this.thanksgivingSection,
    this.style = 'standard',
  });

  final String id;
  final String style;

  bool get usesAllSaintsStyle =>
      style == 'all_saints' || usesHolySpiritStyle || usesStRitaStyle;
  bool get usesHolySpiritStyle => style == 'holy_spirit';
  bool get usesStRitaStyle => style == 'st_rita';
  final String language;
  final String title;
  final String description;
  final List<NovenaDayModel> days;

  /// The content array is the authority for progress bounds.
  int get dayCount => days.length;

  final String? source;
  final int? version;
  final DateTime? lastUpdated;
  final NovenaClosingPrayerModel? closingPrayer;
  final NovenaThanksgivingSectionModel? thanksgivingSection;

  factory NovenaModel.fromJson(Map<String, dynamic> json) {
    return NovenaModel(
      id: json['id'] as String,
      style: json['style'] as String? ?? 'standard',
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
      thanksgivingSection: json['thanksgiving_section'] == null
          ? null
          : NovenaThanksgivingSectionModel.fromJson(
              json['thanksgiving_section'] as Map<String, dynamic>,
            ),
      days: (json['days'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(NovenaDayModel.fromJson)
          .toList(growable: false),
    );
  }
}

class NovenaThanksgivingSectionModel {
  const NovenaThanksgivingSectionModel({
    required this.afterDay,
    required this.title,
    required this.description,
    required String body,
  }) : _body = body;

  final int afterDay;
  final String title;
  final String description;
  final String _body;
  String get body => ReadingMarkup.plainText(_body);
  String get readingText => _body;

  factory NovenaThanksgivingSectionModel.fromJson(Map<String, dynamic> json) {
    return NovenaThanksgivingSectionModel(
      afterDay: json['after_day'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      body: json['body'] as String,
    );
  }
}

class NovenaClosingPrayerModel {
  const NovenaClosingPrayerModel({
    required this.title,
    required this.description,
    required String body,
  }) : _body = body;

  final String title;
  final String description;
  final String _body;
  String get body => ReadingMarkup.plainText(_body);
  String get readingText => _body;

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
    required String body,
  }) : _body = body,
       _deferredBody = null;

  const NovenaDayModel._deferred({
    required this.day,
    required this.title,
    required Map<String, dynamic> source,
  }) : _body = null,
       _deferredBody = source;

  final int day;
  final String title;
  final String? _body;
  final Map<String, dynamic>? _deferredBody;

  /// The day text, read from the retained source map on first access.
  ///
  /// Day bodies are ~120 KB of the ~135 KB a novena file holds, and list views
  /// only need the day number and title. Deferring keeps the corpus cheap to
  /// open while the day screen still gets the same text.
  String get readingText => _body ?? _deferredBody!['body'] as String;
  String get body => ReadingMarkup.plainText(readingText);

  factory NovenaDayModel.fromJson(Map<String, dynamic> json) {
    return NovenaDayModel._deferred(
      day: json['day'] as int,
      title: json['title'] as String,
      source: json,
    );
  }
}
