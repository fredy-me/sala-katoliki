import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/constants/asset_paths.dart';
import '../models/category_model.dart';
import '../models/content_manifest_model.dart';
import '../models/novena_model.dart';
import '../models/prayer_model.dart';
import '../models/rosary_model.dart';

class LocalContentDataSource {
  LocalContentDataSource({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<ContentManifestModel> getManifest() async {
    final json = await _loadMap(AssetPaths.contentManifest);
    return ContentManifestModel.fromJson(json);
  }

  Future<List<CategoryModel>> getCategories() async {
    final manifest = await getManifest();
    final json = await _loadList(manifest.categoriesPath);
    final categories = json
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList(growable: false);

    return [...categories]
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
  }

  Future<List<PrayerModel>> getPrayers({String languageCode = 'sw'}) async {
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

  Future<List<NovenaModel>> getNovenas({String languageCode = 'sw'}) async {
    final manifest = await getManifest();
    final paths =
        manifest.novenaPaths[languageCode] ??
        manifest.novenaPaths[AssetPaths.defaultContentLanguage] ??
        const <String>[];

    final novenas = <NovenaModel>[];
    for (final path in paths) {
      novenas.add(NovenaModel.fromJson(await _loadMap(path)));
    }

    return novenas;
  }

  Future<List<RosaryPrayerModel>> getRosaryPrayers({
    String languageCode = 'sw',
  }) async {
    final path = 'assets/content/rosary/$languageCode/rosary_prayers.json';
    final json = await _loadList(path);
    return json
        .cast<Map<String, dynamic>>()
        .map(RosaryPrayerModel.fromJson)
        .toList(growable: false);
  }

  Future<List<RosaryMysteryModel>> getRosaryMysteries({
    String languageCode = 'sw',
  }) async {
    final path = 'assets/content/rosary/$languageCode/mysteries.json';
    final json = await _loadList(path);
    return json
        .cast<Map<String, dynamic>>()
        .map(RosaryMysteryModel.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _loadMap(String path) async {
    return jsonDecode(await _bundle.loadString(path)) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _loadList(String path) async {
    return jsonDecode(await _bundle.loadString(path)) as List<dynamic>;
  }
}
