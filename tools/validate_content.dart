import 'dart:convert';
import 'dart:io';

import '../lib/shared/content/reading_markup.dart';

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

  void _validateStyle(
    Map<String, dynamic> content,
    Set<String> allowed,
    String context,
  ) {
    if (!allowed.contains(content['style'])) {
      _errors.add(
        '$context must declare a valid style (${allowed.join(', ')}).',
      );
    }
  }

  void _validateReadingBodies(
    Map<String, dynamic> content,
    String context, {
    required bool prayer,
  }) {
    void walk(Object? value, String path, String mode) {
      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          walk(value[i], '$path[$i]', mode);
        }
      } else if (value is Map<String, dynamic>) {
        for (final entry in value.entries) {
          if (entry.key == 'body' && entry.value is String) {
            try {
              ReadingMarkup.validate(entry.value as String, mode: mode);
            } on FormatException catch (error) {
              _errors.add('$path body: ${error.message}');
            }
          } else {
            walk(
              entry.value,
              '$path.${entry.key}',
              entry.key == 'closing_prayer'
                  ? (content['style'] == 'st_rita'
                        ? 'litany_st_rita'
                        : 'litany')
                  : mode,
            );
          }
        }
      }
    }

    walk(
      content,
      context,
      prayer
          ? (content['style'] == 'litany_st_rita'
                ? 'litany_st_rita'
                : content['style'] == 'litany'
                ? 'litany'
                : 'prayer')
          : 'novena',
    );
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
          _validateReadingBodies(prayer, context, prayer: true);
          _validateStyle(prayer, const {
            'standard',
            'litany',
            'litany_st_rita',
          }, context);

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

      final seenIds = <String>{};
      for (final file in _jsonFiles(directory)) {
        final novena = _readMap(file.path);
        final id = _string(novena, 'id', 'novena ${file.path}');
        if (id != null) {
          _validateSnakeCase(id, 'novena id');
          if (!seenIds.add(id)) {
            _errors.add('Duplicate novena id: $language:$id');
          }
        }
        final novenaLanguage = _string(novena, 'language', 'novena $id');
        _string(novena, 'title', 'novena $id');
        _validateReadingBodies(novena, 'novena $id', prayer: false);
        _validateStyle(novena, const {
          'standard',
          'all_saints',
          'holy_spirit',
          'st_rita',
        }, 'novena $id');
        final days = novena['days'];
        if (days is! List) {
          _errors.add('Novena $id must include days array.');
          continue;
        }
        if (days.isEmpty) _errors.add('Novena $id must have at least one day.');
        if (novena.containsKey('day_count') &&
            novena['day_count'] != days.length) {
          _errors.add('Novena $id day_count must match days array length.');
        }
        // 6.3. Was a hardcoded `id == 'st_rita_novena' ? 12 : 9`, the fourth
        // copy of the same literal the app no longer carries. That check could
        // only ever be right about the nine novenas that exist today: it hard
        // -coded today's corpus into the tool meant to police the corpus. Any
        // new novena of a different length was reported as an error, and a
        // novena renamed away from `st_rita_novena` silently lost its length
        // check.
        //
        // Replaced with two checks that are true of every novena regardless of
        // length. Day numbering is the one invariant that actually needs
        // enforcing, because the app derives a day's number from its position
        // in this array and stores that number as the user's progress key: a
        // duplicated or skipped `day` value would attach a completed day to the
        // wrong prayer. Length parity across languages is checked in
        // `_validateIdParity`.
        // The day-numbering loop below derives its own bound from
        // `days.length`, so nothing here needs to know how long a novena is.
        final thanksgivingSection = novena['thanksgiving_section'];
        if (thanksgivingSection != null) {
          if (thanksgivingSection is! Map<String, dynamic>) {
            _errors.add(
              'Novena $id thanksgiving_section must be a JSON object.',
            );
          } else {
            _requiredInt(
              thanksgivingSection,
              'after_day',
              'novena $id thanksgiving_section',
            );
            _string(
              thanksgivingSection,
              'title',
              'novena $id thanksgiving_section',
            );
            _string(
              thanksgivingSection,
              'description',
              'novena $id thanksgiving_section',
            );
            _string(
              thanksgivingSection,
              'body',
              'novena $id thanksgiving_section',
            );
          }
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
        // `totalDays` is the array's own length, not a per-id literal. This was
        // `id == 'st_rita_novena' ? 12 : 9`, which hard-coded today's corpus
        // into the tool meant to police the corpus.
        final totalDays = days.length;
        final seenDays = <int>{};
        for (final day in days) {
          if (day is! Map<String, dynamic>) {
            _errors.add('Novena $id has invalid day entry.');
            continue;
          }
          final dayNumber = _requiredInt(day, 'day', 'novena $id day');
          if (dayNumber != seenDays.length + 1) {
            _errors.add('Novena $id days must be ordered from 1 without gaps.');
          }
          _string(day, 'title', 'novena $id day $dayNumber');
          _string(day, 'body', 'novena $id day $dayNumber');
          if (dayNumber != null && !seenDays.add(dayNumber)) {
            _errors.add('Novena $id has duplicate day: $dayNumber');
          }
          if (dayNumber != null && (dayNumber < 1 || dayNumber > totalDays)) {
            _errors.add('Novena $id has out-of-range day: $dayNumber');
          }
        }
        for (var day = 1; day <= totalDays; day += 1) {
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
        final hasPrayerSequence = mystery['prayer_sequence'] != null;
        if (!hasPrayerSequence) {
          if (mysteryItems is! List || mysteryItems.length != 5) {
            _errors.add('Rosary mystery $id must contain exactly 5 mysteries.');
          }
        } else {
          if (mysteryItems is! List || mysteryItems.isEmpty) {
            // Custom prayer sequence Rosaries can have empty mysteries
          }
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

    // 6.5. The app reads its file paths from the manifest; the validators above
    // read their files from disk. Before this check nothing compared the two, so
    // a JSON file could sit on disk, never be listed, and be invisible to the
    // app with every other check passing. The plan calls this the highest-risk
    // gap in the project, and it was correct.
    if (manifest['categories'] != '$contentRoot/categories/categories.json') {
      _errors.add(
        'Content manifest categories path must match the category file.',
      );
    }
    _validateManifestAgainstDisk(manifest);

    // 6.6. EN and SW must ship the same set of ids. A mismatch today is a
    // silent hole: the prayer exists in one language only, so switching language
    // lands the user on a missing-prayer screen. The one legitimate exception
    // in the content is declared in the metadata below rather than living as a
    // comment in Dart, which is what APP_INDEXES.md Note A flagged as open.
    _validateIdParity(manifest);
  }

  /// Declared EN/SW id differences, read from
  /// `assets/content/metadata/id_aliases.json`. Format: sw-only id -> en-only id.
  ///
  /// Kept in content rather than in `deep_link_service.dart`'s
  /// `prayerIdAliases` so that the validator and the app read the same
  /// declaration instead of two constants that can drift. The existing
  /// `divine_mercy_prayer` pair is declared there.
  Map<String, String> _declaredIdAliases() {
    const path = '$contentRoot/metadata/id_aliases.json';
    final file = File(path);
    if (!file.existsSync()) {
      return const {};
    }
    final decoded = _readJson(path);
    if (decoded is! Map<String, dynamic>) {
      return const {};
    }
    final aliases = decoded['prayer_id_aliases'];
    if (aliases is! Map || aliases.values.any((value) => value is! String)) {
      _errors.add('id_aliases.json prayer_id_aliases must map ids to strings.');
      return const {};
    }
    if (aliases.values.toSet().length != aliases.length) {
      _errors.add('Prayer aliases must have unique English targets.');
    }
    return {
      for (final entry in aliases.entries)
        if (entry.key is String && entry.value is String)
          entry.key as String: entry.value as String,
    };
  }

  void _validateIdParity(Map<String, dynamic> manifest) {
    final aliases = _declaredIdAliases();

    for (final kind in ['prayer', 'novena']) {
      final singular = kind == 'prayer' ? 'prayers' : 'novenas';
      final idsByLanguage = <String, Set<String>>{};
      // 6.3: novena day counts per language, so EN/SW length parity is checked
      // from the content itself instead of a per-id literal. Null for prayers,
      // which have no length.
      final dayCountsByLanguage = <String, Map<String, int>>{};

      for (final language in supportedLanguages) {
        final group = manifest[singular];
        final listed = group is Map ? group[language] : null;
        if (listed is! List) {
          continue;
        }
        final ids = <String>{};
        for (final path in listed.whereType<String>()) {
          final file = File(path);
          if (!file.existsSync()) {
            continue; // already reported by the manifest/disk check
          }
          final decoded = _readJson(path);
          if (decoded is List) {
            for (final entry in decoded.whereType<Map<String, dynamic>>()) {
              final id = entry['id'];
              if (id is String) {
                ids.add(id);
              }
            }
          } else if (decoded is Map<String, dynamic>) {
            final id = decoded['id'];
            if (id is String) {
              ids.add(id);
            }
          }
        }
        idsByLanguage[language] = ids;

        if (kind == 'novena') {
          final counts = <String, int>{};
          for (final path in listed.whereType<String>()) {
            final file = File(path);
            if (!file.existsSync()) {
              continue;
            }
            final decoded = _readJson(path);
            if (decoded is! Map<String, dynamic>) {
              continue;
            }
            final id = decoded['id'];
            final days = decoded['days'];
            if (id is String && days is List) {
              counts[id] = days.length;
            }
          }
          dayCountsByLanguage[language] = counts;
        }
      }

      if (idsByLanguage.length != supportedLanguages.length) {
        continue; // manifest is broken; already reported above
      }

      final english = idsByLanguage['en']!;
      final swahili = idsByLanguage['sw']!;
      final aliasable = kind == 'prayer' ? aliases : const <String, String>{};

      // Aliases are one-directional in meaning but must be mirrored when
      // checking, so an EN id is excluded from the "English-only" set if it is
      // the target of a declared alias.
      final aliasedEnglishIds = aliasable.values.toSet();

      for (final id in english.difference(swahili)) {
        if (aliasedEnglishIds.contains(id)) {
          continue;
        }
        final alias = aliasable.entries
            .where((e) => e.value == id)
            .map((e) => e.key);
        final hint = alias.isEmpty
            ? ''
            : ' (did you mean to declare it in id_aliases.json? sw-only '
                  '${alias.join(', ')})';
        _errors.add(
          '$kind id exists in en but not sw: $id. The two languages must ship '
          'the same content, otherwise switching language shows a missing '
          'screen.$hint',
        );
      }

      for (final id in swahili.difference(english)) {
        if (aliasable.containsKey(id)) {
          continue;
        }
        _errors.add(
          '$kind id exists in sw but not en: $id. If this is the same content '
          'under a different id, declare it in '
          'assets/content/metadata/id_aliases.json instead.',
        );
      }

      // 6.3 length parity. A novena whose EN and SW files disagree on day count
      // is a progress-corruption bug waiting to happen: the user completes day
      // 10 in one language, switches, and the same day is out of range and
      // discarded. This is the invariant the removed `? 12 : 9` literal was
      // reaching for, expressed so it holds for any novena rather than only the
      // two lengths present today.
      if (kind == 'novena') {
        final englishCounts = dayCountsByLanguage['en'] ?? const {};
        final swahiliCounts = dayCountsByLanguage['sw'] ?? const {};
        for (final id in englishCounts.keys.toSet().intersection(
          swahiliCounts.keys.toSet(),
        )) {
          if (englishCounts[id] != swahiliCounts[id]) {
            _errors.add(
              'Novena $id has a different day count in en '
              '(${englishCounts[id]}) and sw (${swahiliCounts[id]}). The two '
              'languages must agree, or a day completed in one language is '
              'dropped as out-of-range in the other.',
            );
          }
        }
      }

      // An alias pointing at an id that does not exist is worse than no alias:
      // it looks declared but resolves nothing. Checked only on the prayer pass,
      // because `aliases` describes prayers — checking it against the novena id
      // sets reported a spurious failure on every run.
      if (kind != 'prayer') {
        continue;
      }
      for (final entry in aliases.entries) {
        if (!swahili.contains(entry.key)) {
          _errors.add(
            'Declared id alias ${entry.key} -> ${entry.value} does not match '
            'any sw prayer id.',
          );
        }
        if (!english.contains(entry.value)) {
          _errors.add(
            'Declared id alias ${entry.key} -> ${entry.value} does not match '
            'any en prayer id.',
          );
        }
      }
    }
  }

  /// Every group/language pair in the manifest must list exactly the `.json`
  /// files present in the corresponding directory, no more and no fewer.
  void _validateManifestAgainstDisk(Map<String, dynamic> manifest) {
    for (final entry in const {
      'prayers': 'prayers',
      'rosary': 'rosary',
      'novenas': 'novenas',
    }.entries) {
      final key = entry.key;
      final byLanguage = manifest[key];
      if (byLanguage is! Map) {
        _errors.add('Content manifest is missing the "$key" section.');
        continue;
      }

      for (final language in supportedLanguages) {
        final listed = byLanguage[language];
        if (listed is! List) {
          _errors.add(
            'Content manifest "$key.$language" must be a list of file paths.',
          );
          continue;
        }

        final listedPaths = listed.whereType<String>().toSet();
        if (listedPaths.length != listed.length) {
          _errors.add(
            'Content manifest "$key.$language" has duplicate or non-string paths.',
          );
        }
        final directory = Directory('$contentRoot/${entry.value}/$language');
        if (!directory.existsSync()) {
          _errors.add('Missing content directory: ${directory.path}');
          continue;
        }
        final diskPaths = _jsonFiles(
          directory,
        ).map((file) => file.path).toSet();

        for (final path in diskPaths.difference(listedPaths).toList()..sort()) {
          _errors.add(
            'File on disk is missing from content_manifest.json and would be '
            'invisible to the app: $path. '
            'Run: dart run tool/generate_content_manifest.dart',
          );
        }
        for (final path in listedPaths.difference(diskPaths).toList()..sort()) {
          _errors.add(
            'Content manifest lists a file that does not exist: $path. '
            'Run: dart run tool/generate_content_manifest.dart',
          );
        }
      }
    }
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
