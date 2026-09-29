import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/localization/localization_providers.dart';
import 'package:salakatoliki/data/datasources/local_content_datasource.dart';
import 'package:salakatoliki/data/datasources/prayer_local_datasource.dart';
import 'package:salakatoliki/data/models/novena_model.dart';
import 'package:salakatoliki/data/repositories/novena_repository.dart';
import 'package:salakatoliki/data/repositories/prayer_repository_impl.dart';
import 'package:salakatoliki/data/repositories/rosary_repository.dart';
import 'package:salakatoliki/features/prayers/presentation/providers/prayer_providers.dart';
import 'package:salakatoliki/shared/services/deep_link_providers.dart';

class _CountingBundle extends CachingAssetBundle {
  _CountingBundle(this._files);

  final Map<String, String> _files;
  final Map<String, int> counts = {};

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    counts.update(key, (value) => value + 1, ifAbsent: () => 1);
    final contents = _files[key];
    if (contents == null) {
      throw FlutterError('asset not found in test bundle: $key');
    }
    return SynchronousFuture<String>(contents);
  }

  @override
  Future<ByteData> load(String key) =>
      SynchronousFuture<ByteData>(ByteData.sublistView(Uint8List(0)));

  int get totalReads => counts.values.fold(0, (sum, value) => sum + value);

  int readsOf(String pathSuffix) => counts.entries
      .where((entry) => entry.key.endsWith(pathSuffix))
      .fold(0, (sum, entry) => sum + entry.value);
}

Map<String, String> _realContent() {
  final files = <String, String>{};
  for (final entry in Directory('assets/content').listSync(recursive: true)) {
    if (entry is File && entry.path.endsWith('.json')) {
      files[entry.path] = entry.readAsStringSync();
    }
  }
  return files;
}

void main() {
  group('part3 data layer caching', () {
    test('opening every prayer performs zero extra asset reads', () async {
      final bundle = _CountingBundle(_realContent());
      final repository = PrayerRepositoryImpl(
        PrayerLocalDataSource(
          contentDataSource: LocalContentDataSource(bundle: bundle),
        ),
      );

      final prayers = await repository.getPrayers(languageCode: 'en');
      expect(prayers, hasLength(36));
      final readsAfterLoad = bundle.totalReads;

      for (final prayer in prayers) {
        final resolved = await repository.getPrayerById(
          prayer.id,
          languageCode: 'en',
        );
        expect(resolved?.id, prayer.id, reason: 'every prayer must resolve');
      }

      expect(
        bundle.totalReads - readsAfterLoad,
        0,
        reason: 'prayerById must be served from the cached index',
      );
    });

    test('manifest and categories are read once regardless of call count', () async {
      final bundle = _CountingBundle(_realContent());
      final dataSource = LocalContentDataSource(bundle: bundle);

      await dataSource.getManifest();
      await dataSource.getManifest();
      await dataSource.getManifest();
      expect(bundle.readsOf('content_manifest.json'), 1);

      await dataSource.getCategories();
      await dataSource.getCategories();
      expect(bundle.readsOf('categories.json'), 1);
    });

    test('each language corpus is read exactly once', () async {
      final bundle = _CountingBundle(_realContent());
      final repository = PrayerRepositoryImpl(
        PrayerLocalDataSource(
          contentDataSource: LocalContentDataSource(bundle: bundle),
        ),
      );

      await repository.getPrayers(languageCode: 'en');
      await repository.getPrayers(languageCode: 'en');
      await repository.getPrayers(languageCode: 'sw');
      await repository.getPrayers(languageCode: 'en');

      expect(bundle.counts['assets/content/prayers/en/common_prayers.json'], 1);
      expect(bundle.counts['assets/content/prayers/sw/common_prayers.json'], 1);
    });

    test('novenas and rosary corpora are cached per language', () async {
      final bundle = _CountingBundle(_realContent());
      final dataSource = LocalContentDataSource(bundle: bundle);

      await NovenaRepository(dataSource).getNovenas(languageCode: 'sw');
      final readsAfterFirst = bundle.totalReads;
      await NovenaRepository(dataSource).getNovenas(languageCode: 'sw');
      expect(
        bundle.totalReads - readsAfterFirst,
        0,
        reason: 'a second novena load must come entirely from cache',
      );
      expect(bundle.readsOf('novenas/sw/divine_mercy_novena.json'), 1);

      await RosaryRepository(dataSource).getRosaryMysteries(
        languageCode: 'sw',
      );
      await RosaryRepository(dataSource).getRosaryMysteries(
        languageCode: 'sw',
      );
      expect(bundle.readsOf('mysteries.json'), 1);
    });

    test('deep link resolution reuses the cached corpus', () async {
      final bundle = _CountingBundle(_realContent());
      final container = ProviderContainer(
        overrides: [
          activeLanguageProvider.overrideWithValue('sw'),
          localContentDataSourceProvider.overrideWithValue(
            LocalContentDataSource(bundle: bundle),
          ),
        ],
      );
      addTearDown(container.dispose);

      final service = await container.read(deepLinkContextProvider.future);

      expect(service, isNotNull);
      expect(
        bundle.counts.containsKey('assets/content/prayers/en/common_prayers.json'),
        isFalse,
        reason: 'a Swahili session must not load the English corpus',
      );
    });

    test('novena day bodies stay readable after deferral', () async {
      final bundle = _CountingBundle(_realContent());
      final novenas = await NovenaRepository(
        LocalContentDataSource(bundle: bundle),
      ).getNovenas(languageCode: 'en');

      final novena = novenas.firstWhere((item) => item.id == 'st_rita_novena');
      expect(novena.days, hasLength(12));
      expect(novena.days.first.title, isNotEmpty);
      expect(novena.days.first.body, isNotEmpty);
      expect(novena.days.last.body, isNotEmpty);
    });

    test('an eagerly built day model still exposes the same text', () {
      const day = NovenaDayModel(
        day: 2,
        title: 'Day 2',
        body: 'Day two prayer.',
      );
      expect(day.body, 'Day two prayer.');
      expect(day.title, 'Day 2');
    });
  });
}
