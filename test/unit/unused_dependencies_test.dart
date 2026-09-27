import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The three packages below were in `dependencies` while nothing in `lib/`
/// imported them, so they were compiled into the app for no benefit.
///
/// This test fails if any of them comes back. If a future change genuinely
/// needs one, add the import to `lib/`, remove this entry, and note the reason.
void main() {
  final unused = ['easy_localization', 'intl', 'cupertino_icons'];

  test('unused packages stay out of dependencies', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final dependencyBlock = pubspec.split(RegExp(r'^dev_dependencies:', multiLine: true)).first;

    for (final package in unused) {
      expect(
        dependencyBlock,
        isNot(matches(RegExp('^\\s+$package\\s*:', multiLine: true))),
        reason:
            '$package is unused by lib/ but is listed in dependencies again. '
            'If it is now genuinely imported, delete it from this test and '
            'record why in app_optimization.md.',
      );
    }
  });

  test('unused packages are not imported anywhere in lib', () {
    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    final imported = sources.map((file) => file.readAsStringSync()).join('\n');

    for (final package in unused) {
      expect(
        imported,
        isNot(contains("package:$package/")),
        reason: 'lib/ now imports $package, so it is no longer unused',
      );
    }
  });
}
