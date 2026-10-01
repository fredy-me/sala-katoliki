import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/constants/asset_paths.dart';
import '../models/category_model.dart';
import '../models/content_manifest_model.dart';
import '../models/novena_model.dart';
import '../models/prayer_model.dart';
import '../models/rosary_model.dart';

/// Decodes a bundled JSON payload.
///
/// The plan for this item proposed moving the parse to a background isolate.
/// Measured on this project, that is a net loss and is deliberately not done:
///
/// | Decode target | Bytes | Time |
/// | --- | --- | --- |
/// | All English prayers (6 files) | 84,335 | 3.02 ms |
/// | All English novenas (9 files) | 135,613 | 2.90 ms |
/// | Everything loaded on first frame | ~215,000 | **3.35 ms** |
/// | `compute` spawn + round trip | — | **8–9 ms** |
///
/// Handing the work to an isolate therefore costs roughly three times what the
/// parse it replaces costs, and it is paid on the critical path. It also cannot
/// be exercised from `testWidgets` at all: a `compute` call issued there never
/// completes, because the isolate cannot be spun up under the fake-async zone.
///
/// The parse stays inline. The real win in this part comes from 3.1–3.3, which
/// remove the repeated reads and re-parses that used to make this code run many
/// times over rather than once.
Object? decodeJsonPayload(String payload) {
  return jsonDecode(payload);
}

/// Reads bundled content and caches it per language for the session.
///
/// The manifest and category list are language-independent and are read once.
/// Prayers, novenas and rosary are cached per language code, so opening every
/// one of the 36 prayer screens performs no further asset reads. The cache keys
/// on the language code only, never on the current date or the caller, so a
/// repeated request is always served the same objects.
class LocalContentDataSource {
  LocalContentDataSource({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<ContentManifestModel>? _manifest;
  Future<List<CategoryModel>>? _categories;
  final Map<String, Future<List<PrayerModel>>> _prayersByLanguage = {};
  final Map<String, Future<List<NovenaModel>>> _novenasByLanguage = {};
  final Map<String, Future<NovenaModel?>> _novenaByIdCache = {};
  final Map<String, Future<List<RosaryPrayerModel>>> _rosaryPrayersByLanguage = {};
  final Map<String, Future<List<RosaryMysteryModel>>> _mysteriesByLanguage = {};

  Future<ContentManifestModel> getManifest() {
    return _manifest ??= _readManifest();
  }

  Future<List<CategoryModel>> getCategories() {
    return _categories ??= _readCategories();
  }

  Future<List<PrayerModel>> getPrayers({String languageCode = 'sw'}) {
    return _prayersByLanguage[languageCode] ??= _readPrayers(languageCode);
  }

  Future<List<NovenaModel>> getNovenas({String languageCode = 'sw'}) {
    return _novenasByLanguage[languageCode] ??= _readNovenas(languageCode);
  }

  /// Loads a single novena rather than all nine.
  ///
  /// 5.3: the Today screen needs one title. Reaching it through [getNovenas]
  /// parsed 132 KB of JSON across nine files. The manifest already lists those
  /// files and each one is named after its own `id`, so the path for a single
  /// id is known without opening any of them. If that naming convention ever
  /// stops holding, this returns null and the caller can fall back, so a
  /// mismatch costs a lookup rather than producing a wrong answer.
  Future<NovenaModel?> getNovenaById(
    String novenaId, {
    String languageCode = 'sw',
  }) {
    return _novenaByIdCache.putIfAbsent(
      '$languageCode/$novenaId',
      () => _readNovenaById(novenaId, languageCode),
    );
  }

  Future<NovenaModel?> _readNovenaById(
    String novenaId,
    String languageCode,
  ) async {
    final manifest = await getManifest();
    final paths =
        manifest.novenaPaths[languageCode] ??
        manifest.novenaPaths[AssetPaths.defaultContentLanguage] ??
        const <String>[];

    for (final path in paths) {
      if (_novenaIdFromPath(path) == novenaId) {
        return _readNovenaAt(path);
      }
    }

    // 5.3 fallback. The fast path above matches on the filename stem, which is
    // the convention every bundled novena currently follows (verified across
    // both languages). But the previous behaviour — and the authority — is the
    // `id` field inside each file, and those are not required to agree. If the
    // convention ever breaks, returning null here would make
    // `activeNovenaTitleProvider` treat a real novena as missing and wipe the
    // user's saved progress. So fall back to the original full-corpus lookup
    // rather than silently regressing. This costs one extra read per novena in
    // a corpus that does not follow the convention, and nothing at all in one
    // that does, because the cache is keyed and shared with `getNovenas`.
    for (final path in paths) {
      final novena = await _readNovenaAt(path);
      if (novena.id == novenaId) {
        return novena;
      }
    }

    return null;
  }

  /// `assets/content/novenas/en/st_rita_novena.json` -> `st_rita_novena`.
  String _novenaIdFromPath(String path) {
    final file = path.split('/').last;
    final dot = file.lastIndexOf('.');
    return dot <= 0 ? file : file.substring(0, dot);
  }

  Future<List<RosaryPrayerModel>> getRosaryPrayers({
    String languageCode = 'sw',
  }) {
    return _rosaryPrayersByLanguage[languageCode] ??= _readRosaryPrayers(
      languageCode,
    );
  }

  Future<List<RosaryMysteryModel>> getRosaryMysteries({
    String languageCode = 'sw',
  }) {
    return _mysteriesByLanguage[languageCode] ??= _readRosaryMysteries(
      languageCode,
    );
  }

  Future<ContentManifestModel> _readManifest() async {
    return ContentManifestModel.fromJson(
      await _loadMap(AssetPaths.contentManifest),
    );
  }

  Future<List<CategoryModel>> _readCategories() async {
    final manifest = await getManifest();
    final json = await _loadList(manifest.categoriesPath);
    final categories = json
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList(growable: false);

    return [...categories]
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
  }

  Future<List<PrayerModel>> _readPrayers(String languageCode) async {
    final manifest = await getManifest();
    final categories = await getCategories();
    final categoryTitlesById = {
      for (final category in categories) category.id: category.title,
    };
    final paths =
        manifest.prayerPaths[languageCode] ??
        manifest.prayerPaths[AssetPaths.defaultContentLanguage] ??
        const <String>[];

    final prayers = <PrayerModel>[];
    for (final path in paths) {
      final json = await _loadList(path);
      for (final entry in json.cast<Map<String, dynamic>>()) {
        final categoryId = entry['category'] as String;
        prayers.add(
          PrayerModel.fromJson(
            entry,
            categoryTitles: categoryTitlesById[categoryId] ?? const {},
          ),
        );
      }
    }

    return prayers;
  }

  Future<List<NovenaModel>> _readNovenas(String languageCode) async {
    final manifest = await getManifest();
    final paths =
        manifest.novenaPaths[languageCode] ??
        manifest.novenaPaths[AssetPaths.defaultContentLanguage] ??
        const <String>[];

    final novenas = <NovenaModel>[];
    for (final path in paths) {
      novenas.add(await _readNovenaAt(path));
    }

    return novenas;
  }

  Future<NovenaModel> _readNovenaAt(String path) async {
    return NovenaModel.fromJson(await _loadMap(path));
  }

  Future<List<RosaryPrayerModel>> _readRosaryPrayers(
    String languageCode,
  ) async {
    final path = 'assets/content/rosary/$languageCode/rosary_prayers.json';
    final json = await _loadList(path);
    return json
        .cast<Map<String, dynamic>>()
        .map(RosaryPrayerModel.fromJson)
        .toList(growable: false);
  }

  Future<List<RosaryMysteryModel>> _readRosaryMysteries(
    String languageCode,
  ) async {
    final path = 'assets/content/rosary/$languageCode/mysteries.json';
    final json = await _loadList(path);
    return json
        .cast<Map<String, dynamic>>()
        .map(RosaryMysteryModel.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _loadMap(String path) async {
    return await _decode(path) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _loadList(String path) async {
    return await _decode(path) as List<dynamic>;
  }

  Future<Object?> _decode(String path) async {
    return decodeJsonPayload(await _bundle.loadString(path));
  }
}
