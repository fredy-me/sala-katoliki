import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salakatoliki/core/constants/storage_keys.dart';
import 'package:salakatoliki/core/localization/localization_providers.dart';
import 'package:salakatoliki/data/datasources/local_content_datasource.dart';
import 'package:salakatoliki/features/novenas/presentation/providers/novena_providers.dart';
import 'package:salakatoliki/features/today/presentation/providers/today_providers.dart';

import '../helpers/test_asset_bundle.dart';

void main() {
  ProviderContainer container() {
    final result = ProviderContainer(
      overrides: [
        activeLanguageProvider.overrideWithValue('en'),
        localContentDataSourceProvider.overrideWithValue(
          testContentDataSource(),
        ),
      ],
    );
    addTearDown(result.dispose);
    return result;
  }

  test('legacy St Rita days survive migration and restart', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.activeNovenaId: 'st_rita_novena',
      StorageKeys.completedNovenaDays: ['1', '9', '10', '11', '13'],
    });
    final first = container();
    final progress = await first.read(novenaProgressProvider.future);
    expect(progress.completedDays, {1, 9, 10, 11});
    final today = await first.read(todayLocalStateProvider.future);
    expect(today.totalNovenaDays, 12);
    expect(today.nextNovenaDay, 12);
    expect(today.completedNovenaDays, {1, 9, 10, 11});
    final reloaded = await container().read(novenaProgressProvider.future);
    expect(reloaded.completedDays, {1, 9, 10, 11});
  });

  test('map progress loads bounds before filtering saved days', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.activeNovenaId: 'st_rita_novena',
      StorageKeys.novenaProgressById: jsonEncode({
        'st_rita_novena': [1, 10, 11, 13],
        'holy_spirit_novena': [1, 9, 10],
      }),
    });
    final progress = await container().read(novenaProgressProvider.future);
    expect(progress.completedDaysFor('st_rita_novena'), {1, 10, 11});
    expect(progress.completedDaysFor('holy_spirit_novena'), {1, 9});
  });

  test('new St Rita session accepts day 10 and completes on day 12', () async {
    SharedPreferences.setMockInitialValues({});
    final ref = container();
    final notifier = ref.read(novenaProgressProvider.notifier);
    await notifier.start('st_rita_novena');
    await notifier.completeDay('st_rita_novena', 10);
    expect((await ref.read(novenaProgressProvider.future)).completedDays, {10});
    await notifier.completeDay('st_rita_novena', 13);
    expect((await ref.read(novenaProgressProvider.future)).completedDays, {10});
    await notifier.completeDay('st_rita_novena', 12);
    expect(
      (await ref.read(novenaProgressProvider.future)).activeNovenaId,
      isNull,
    );
  });

  test('unknown content preserves positive saved days across writes', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.activeNovenaId: 'unavailable',
      StorageKeys.completedNovenaDays: ['1', '10', '12', '-1'],
    });
    final ref = container();
    expect((await ref.read(novenaProgressProvider.future)).completedDays, {
      1,
      10,
      12,
    });
    final today = await ref.read(todayLocalStateProvider.future);
    expect(today.completedNovenaDays, {1, 10, 12});
    await ref.read(novenaProgressProvider.notifier).start('holy_spirit_novena');
    final reloaded = await container().read(novenaProgressProvider.future);
    expect(reloaded.completedDaysFor('unavailable'), {1, 10, 12});
  });

  test('count, single lookup and corpus share one read per file', () async {
    final bundle = _CountingBundle();
    final source = LocalContentDataSource(bundle: bundle);
    expect(
      await source.getNovenaDayCount('st_rita_novena', languageCode: 'en'),
      12,
    );
    await source.getNovenaById('st_rita_novena', languageCode: 'en');
    await source.getNovenas(languageCode: 'en');
    expect(bundle.reads.length, 9);
    expect(bundle.reads.values, everyElement(1));
  });

  test('filename match cannot return a different JSON id', () async {
    final bundle = _CountingBundle(renameId: true);
    final source = LocalContentDataSource(bundle: bundle);
    expect(
      await source.getNovenaById('st_rita_novena', languageCode: 'en'),
      isNull,
    );
    expect(await source.getNovenaDayCount('renamed', languageCode: 'en'), 12);
  });
}

class _CountingBundle extends TestAssetBundle {
  _CountingBundle({this.renameId = false});
  final bool renameId;
  final Map<String, int> reads = {};

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    if (key.contains('/novenas/'))
      reads.update(key, (n) => n + 1, ifAbsent: () => 1);
    if (renameId && key.endsWith('/en/st_rita_novena.json')) {
      // TestAssetBundle resolves synchronously; a transformed future is safe in
      // these plain unit tests (no widget fake-async zone).
      return super.loadString(key).then((body) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        json['id'] = 'renamed';
        return jsonEncode(json);
      });
    }
    return super.loadString(key, cache: cache);
  }
}
