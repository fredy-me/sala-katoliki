import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/data/datasources/local_content_datasource.dart';

import '../helpers/test_asset_bundle.dart';

void main() {
  test('getNovenaById agrees with getNovenas for every id', () async {
    final a = LocalContentDataSource(bundle: TestAssetBundle());
    final all = await LocalContentDataSource(
      bundle: TestAssetBundle(),
    ).getNovenas(languageCode: 'en');
    expect(all.length, 9);
    for (final expected in all) {
      final single = await a.getNovenaById(expected.id, languageCode: 'en');
      expect(single, isNotNull, reason: '${expected.id} not found by id');
      expect(single!.id, expected.id);
      expect(single.title, expected.title);
      expect(single.days.length, expected.days.length);
    }
  });

  test('language is honoured, not ignored', () async {
    final a = LocalContentDataSource(bundle: TestAssetBundle());
    final en = await a.getNovenaById('st_rita_novena', languageCode: 'en');
    final sw = await a.getNovenaById('st_rita_novena', languageCode: 'sw');
    expect(en!.title, isNot(sw!.title));
  });

  test('an unknown id resolves to null rather than throwing', () async {
    final a = LocalContentDataSource(bundle: TestAssetBundle());
    expect(await a.getNovenaById('no_such_novena', languageCode: 'en'), isNull);
  });

  test('reads only the one novena file, not all nine', () async {
    final bundle = _RecordingBundle();
    final a = LocalContentDataSource(bundle: bundle);
    await a.getNovenaById('st_rita_novena', languageCode: 'en');
    expect(
      bundle.novenaFilesRead.length,
      1,
      reason: 'got ${bundle.novenaFilesRead}',
    );
    expect(bundle.novenaFilesRead.single, contains('st_rita_novena'));
  });

  test('a second call for the same id reads nothing again', () async {
    final bundle = _RecordingBundle();
    final a = LocalContentDataSource(bundle: bundle);
    await a.getNovenaById('st_rita_novena', languageCode: 'en');
    final after = bundle.novenaFilesRead.length;
    await a.getNovenaById('st_rita_novena', languageCode: 'en');
    expect(bundle.novenaFilesRead.length, after, reason: 'must be memoized');
  });

  // The two tests below pin the fallback added to `_readNovenaById`. The
  // filename-stem match is an optimisation, not the contract: the `id` field
  // inside the JSON is what the rest of the app identifies a novena by, and
  // `getNovenas` returns exactly the ids that `getNovenaById` must resolve.
  // Without the fallback, a file whose id differs from its name would be
  // invisible to a direct lookup, and `activeNovenaTitleProvider` would treat
  // the user's real, in-progress novena as missing and clear their progress.
  test('resolves by the JSON id when it differs from the filename', () async {
    final bundle = _RecordingBundle();
    const path = 'assets/content/novenas/en/st_rita_novena.json';
    final decoded = jsonDecode(bundle.files[path]!) as Map<String, dynamic>;
    expect(decoded['id'], 'st_rita_novena', reason: 'fixture precondition');

    // Rewrite so the id and the filename disagree, the case the fallback
    // exists for.
    decoded['id'] = 'moved_novena_id';
    bundle.files[path] = jsonEncode(decoded);

    final a = LocalContentDataSource(bundle: bundle);
    final found = await a.getNovenaById('moved_novena_id', languageCode: 'en');
    expect(found, isNotNull, reason: 'must fall back to the JSON id');
    expect(found!.id, 'moved_novena_id');
    expect(found.title, isNotEmpty);
  });

  test('an id matching no file at all is still null, not a false match', () async {
    final bundle = _RecordingBundle();
    const path = 'assets/content/novenas/en/st_rita_novena.json';
    final decoded = jsonDecode(bundle.files[path]!) as Map<String, dynamic>;
    decoded['id'] = 'moved_novena_id';
    bundle.files[path] = jsonEncode(decoded);

    final a = LocalContentDataSource(bundle: bundle);
    expect(await a.getNovenaById('still_absent', languageCode: 'en'), isNull);
  });
}

/// Reads the real content from disk and records which files were asked for.
class _RecordingBundle extends CachingAssetBundle {
  _RecordingBundle() : files = _readAll();

  final Map<String, String> files;
  // mutable so tests can model content whose id and filename disagree
  final List<String> novenaFilesRead = [];

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    if (key.contains('/novenas/')) {
      novenaFilesRead.add(key);
    }
    final contents = files[key];
    if (contents == null) {
      throw FlutterError('No bundled content asset found at "\$key".');
    }
    return SynchronousFuture<String>(contents);
  }

  @override
  Future<ByteData> load(String key) {
    return SynchronousFuture<ByteData>(
      ByteData.sublistView(Uint8List.fromList(utf8.encode(loadStringSync(key)))),
    );
  }

  String loadStringSync(String key) {
    final contents = files[key];
    if (contents == null) {
      throw FlutterError('No bundled content asset found at "\$key".');
    }
    return contents;
  }

  static Map<String, String> _readAll() {
    final out = <String, String>{};
    for (final entry
        in Directory('assets/content').listSync(recursive: true)) {
      if (entry is File && entry.path.endsWith('.json')) {
        out[entry.path] = entry.readAsStringSync();
      }
    }
    return out;
  }
}
