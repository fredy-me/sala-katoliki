import 'dart:convert';
import 'dart:io';

const supportedLanguages = {'en', 'sw'};
const contentRoot = 'assets/content';

void main() {
  final validator = _ContentValidator();
  validator.run();
}

class _ContentValidator {
  final _errors = <String>[];
  final _categoryIds = <String>{};
  final _prayerIds = <String>{};
  final _prayerIdsByLanguage = <String, Set<String>>{
    for (final language in supportedLanguages) language: <String>{},
  };

  void run() {
    _validateCategories();
    _validatePrayers();
    _validateNovenas();
    _validateRosary();
    _validateMetadata();

    if (_errors.isNotEmpty) {
      stderr.writeln('Content validation failed:');
      for (final error in _errors) {
        stderr.writeln('- $error');
      }
      exitCode = 1;
      return;
    }

    stdout.writeln('Content validation passed.');
  }

  void _validateCategories() {
    final categories = _readList('$contentRoot/categories/categories.json');
    for (final category in categories) {
      final id = _string(category, 'id', 'category');
      if (id == null) {
        continue;
      }
      _validateSnakeCase(id, 'category id');
      if (!_categoryIds.add(id)) {
        _errors.add('Duplicate category id: $id');
      }
      _requiredMap(category, 'title', 'category $id');
      _requiredInt(category, 'sort_order', 'category $id');
    }
  }

  void _validatePrayers() {
    for (final language in supportedLanguages) {
      final directory = Directory('$contentRoot/prayers/$language');
      if (!directory.existsSync()) {
        _errors.add('Missing prayer language directory: ${directory.path}');
        continue;
      }

      for (final file in _jsonFiles(directory)) {
        final prayers = _readList(file.path);
        for (final prayer in prayers) {
          final context = 'prayer in ${file.path}';
          final id = _string(prayer, 'id', context);
          final type = _string(prayer, 'type', context);
          final category = _string(prayer, 'category', context);
          final prayerLanguage = _string(prayer, 'language', context);
          _string(prayer, 'title', context);
          _string(prayer, 'body', context);

          if (id != null) {
            _validateSnakeCase(id, 'prayer id');
            if (!_prayerIds.add('$prayerLanguage:$id')) {
              _errors.add(
                'Duplicate prayer id/language pair: $prayerLanguage:$id',
              );
            }
            _prayerIdsByLanguage[language]?.add(id);
          }
          if (type != null && type != 'prayer') {
            _errors.add('Invalid prayer type for $id: $type');
          }
          if (category != null && !_categoryIds.contains(category)) {
            _errors.add('Prayer $id references unknown category: $category');
          }
          if (prayerLanguage != language) {
            _errors.add(
              'Prayer $id language "$prayerLanguage" does not match directory "$language"',
            );
          }
          if (prayerLanguage != null &&
              !supportedLanguages.contains(prayerLanguage)) {
            _errors.add('Unsupported prayer language: $prayerLanguage');
          }
        }
      }
    }
  }

  void _validateNovenas() {
    for (final language in supportedLanguages) {
      final directory = Directory('$contentRoot/novenas/$language');
      if (!directory.existsSync()) {
        _errors.add('Missing novena language directory: ${directory.path}');
        continue;
      }

      for (final file in _jsonFiles(directory)) {
        final novena = _readMap(file.path);
        final id = _string(novena, 'id', 'novena ${file.path}');
        final novenaLanguage = _string(novena, 'language', 'novena $id');
        _string(novena, 'title', 'novena $id');
        final days = novena['days'];
        if (days is! List) {
          _errors.add('Novena $id must include days array.');
          continue;
        }
        if (days.length != 9) {
          _errors.add('Novena $id must contain exactly 9 days.');
        }
        final closingPrayer = novena['closing_prayer'];
        if (closingPrayer != null) {
          if (closingPrayer is! Map<String, dynamic>) {
            _errors.add('Novena $id closing_prayer must be a JSON object.');
          } else {
            _string(closingPrayer, 'title', 'novena $id closing_prayer');
            _string(closingPrayer, 'description', 'novena $id closing_prayer');
            _string(closingPrayer, 'body', 'novena $id closing_prayer');
          }
        }
        final seenDays = <int>{};
        for (final day in days) {
          if (day is! Map<String, dynamic>) {
            _errors.add('Novena $id has invalid day entry.');
            continue;
          }
          final dayNumber = _requiredInt(day, 'day', 'novena $id day');
          _string(day, 'title', 'novena $id day $dayNumber');
          _string(day, 'body', 'novena $id day $dayNumber');
          if (dayNumber != null && !seenDays.add(dayNumber)) {
            _errors.add('Novena $id has duplicate day: $dayNumber');
          }
          if (dayNumber != null && (dayNumber < 1 || dayNumber > 9)) {
            _errors.add('Novena $id has out-of-range day: $dayNumber');
          }
        }
        for (var day = 1; day <= 9; day += 1) {
          if (!seenDays.contains(day)) {
            _errors.add('Novena $id is missing day: $day');
          }
        }
        if (novenaLanguage != language) {
          _errors.add(
            'Novena $id language does not match directory $language.',
          );
        }
      }
    }
  }

  void _validateRosary() {
    for (final language in supportedLanguages) {
      final prayers = _readList(
        '$contentRoot/rosary/$language/rosary_prayers.json',
      );
      for (final prayer in prayers) {
        final prayerId = _string(
          prayer,
          'prayer_id',
          'rosary prayer $language',
        );
        _requiredInt(prayer, 'repeat_count', 'rosary prayer $language');
        if (prayerId != null &&
            !(_prayerIdsByLanguage[language]?.contains(prayerId) ?? false)) {
          _errors.add(
            'Rosary $language references unknown prayer_id: $prayerId',
          );
        }
      }

      final mysteries = _readList(
        '$contentRoot/rosary/$language/mysteries.json',
      );
      for (final mystery in mysteries) {
        final id = _string(mystery, 'id', 'rosary mystery $language');
        final mysteryLanguage = _string(
          mystery,
          'language',
          'rosary mystery $id',
        );
        _string(mystery, 'title', 'rosary mystery $id');
        final mysteryItems = mystery['mysteries'];
        if (mysteryItems is! List || mysteryItems.length != 5) {
          _errors.add('Rosary mystery $id must contain exactly 5 mysteries.');
        }
        if (mysteryLanguage != language) {
          _errors.add(
            'Rosary mystery $id language does not match directory $language.',
          );
        }
      }
    }
  }

  void _validateMetadata() {
    final manifest = _readMap('$contentRoot/metadata/content_manifest.json');
    final languages = manifest['languages'];
    if (languages is! List ||
        languages.toSet().containsAll(supportedLanguages) == false) {
      _errors.add('Content manifest must list all supported languages.');
    }
    _readList('$contentRoot/metadata/languages.json');
    _readMap('$contentRoot/metadata/app_info.json');
  }

  List<File> _jsonFiles(Directory directory) {
    return directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path));
  }

  Map<String, dynamic> _readMap(String path) {
    final decoded = _readJson(path);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    _errors.add('$path must contain a JSON object.');
    return {};
  }

  List<dynamic> _readList(String path) {
    final decoded = _readJson(path);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    _errors.add('$path must contain a JSON array.');
    return [];
  }

  Object? _readJson(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      _errors.add('Missing content file: $path');
      return null;
    }

    try {
      return jsonDecode(file.readAsStringSync());
    } on FormatException catch (error) {
      _errors.add('Invalid JSON in $path: ${error.message}');
      return null;
    }
  }

  String? _string(Map<String, dynamic> json, String key, String context) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    _errors.add('Missing or invalid "$key" in $context.');
    return null;
  }

  Map<String, dynamic>? _requiredMap(
    Map<String, dynamic> json,
    String key,
    String context,
  ) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    _errors.add('Missing or invalid "$key" map in $context.');
    return null;
  }

  int? _requiredInt(Map<String, dynamic> json, String key, String context) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    _errors.add('Missing or invalid "$key" integer in $context.');
    return null;
  }

  void _validateSnakeCase(String value, String context) {
    final isSnakeCase = RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$').hasMatch(value);
    if (!isSnakeCase) {
      _errors.add('$context must be lowercase snake_case: $value');
    }
  }
}
