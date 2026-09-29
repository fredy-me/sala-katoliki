import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:salakatoliki/data/datasources/local_content_datasource.dart';

export 'package:salakatoliki/features/prayers/presentation/providers/prayer_providers.dart'
    show localContentDataSourceProvider;

/// Serves the real `assets/content` JSON to widget tests.
///
/// `rootBundle` is unusable under `testWidgets`: the binding's fake-async zone
/// never settles the multi-file read chain that `LocalContentDataSource`
/// performs, so every content provider stays `AsyncLoading` forever. Reading the
/// files synchronously and returning them as `SynchronousFuture` settles inside
/// the fake-async zone, so these tests exercise the real bundled content.
class TestAssetBundle extends CachingAssetBundle {
  TestAssetBundle();

  static final Map<String, String> _files = _readContentFiles();

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return SynchronousFuture<String>(_read(key));
  }

  @override
  Future<ByteData> load(String key) {
    return SynchronousFuture<ByteData>(
      ByteData.sublistView(Uint8List.fromList(utf8.encode(_read(key)))),
    );
  }

  String _read(String key) {
    final contents = _files[key];
    if (contents == null) {
      throw FlutterError('No bundled content asset found at "$key".');
    }
    return contents;
  }

  static Map<String, String> _readContentFiles() {
    final files = <String, String>{};
    for (final entry
        in Directory('assets/content').listSync(recursive: true)) {
      if (entry is File && entry.path.endsWith('.json')) {
        files[entry.path] = entry.readAsStringSync();
      }
    }
    return files;
  }
}

LocalContentDataSource testContentDataSource() {
  return LocalContentDataSource(bundle: TestAssetBundle());
}
