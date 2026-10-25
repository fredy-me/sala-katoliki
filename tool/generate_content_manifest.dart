import 'dart:convert';
import 'dart:io';

/// 6.4 — generates `assets/content/metadata/content_manifest.json` by scanning
/// the content directories on disk.
///
/// Before this existed the manifest was maintained by hand while the app read
/// its paths from the manifest and the validator read its files from disk. That
/// asymmetry is the highest-risk gap in the project (Part 6, item 6.5): a file
/// could sit on disk, never be listed, and be silently invisible to the app
/// with nothing complaining. Making disk the single source of truth and
/// deriving the manifest removes the hand-editing step entirely.
///
/// Usage:
///   dart run tool/generate_content_manifest.dart          # rewrite the manifest
///   dart run tool/generate_content_manifest.dart --check  # fail if stale
///
/// `--check` is what CI and the test suite use: it exits non-zero when the
/// committed manifest differs from what disk implies, so the generator cannot
/// drift from the manifest.
const contentRoot = 'assets/content';
const manifestPath = '$contentRoot/metadata/content_manifest.json';

/// Directory name under `assets/content/` mapped to its manifest key. The order
/// here is the key order in the emitted JSON.
const _groups = <String, String>{
  'prayers': 'prayers',
  'rosary': 'rosary',
  'novenas': 'novenas',
};

const languages = ['en', 'sw'];

void main(List<String> args) {
  final check = args.contains('--check');

  final manifest = _scan();

  if (check) {
    _check(manifest);
    return;
  }

  _write(manifest);
}

Map<String, Object?> _scan() {
  // Key order is fixed and explicit rather than assembled by a loop, because it
  // has to match the committed manifest byte-for-byte for `--check` to mean
  // anything.
  final manifest = <String, Object?>{
    'version': 1,
    'last_updated': _readExistingLastUpdated(),
    'languages': languages,
    'categories': '$contentRoot/categories/categories.json',
    'prayers': _pathsByLanguage('prayers'),
    'rosary': _pathsByLanguage('rosary'),
    'novenas': _pathsByLanguage('novenas'),
  };
  return manifest;
}

Map<String, List<String>> _pathsByLanguage(String group) {
  return {
    for (final language in languages)
      language: _pathsIn('$contentRoot/$group/$language'),
  };
}

/// Every `.json` directly inside `directory`, in the order the committed
/// manifest already lists them, with any file not yet listed appended in sorted
/// order.
///
/// **Why the existing order is preserved rather than sorted.** Sorting is the
/// obvious choice for a generator, and it was tried first. It is wrong here for
/// two reasons:
///
/// 1. Reordering `prayers/*.json` rewrites bundled JSON, which §0 forbids
///    ("bundled JSON stays byte-identical").
/// 2. File order is observable. `getPrayers` concatenates files in manifest
///    order and the library sorts by search score with `List.sort`, which is not
///    stable, so manifest order is a tie-break input. Reordering could shuffle
///    equally-scoring search results.
///
/// So the generator owns *membership* — which files are listed — and the
/// manifest keeps owning *order*. New files are appended deterministically
/// (sorted) so two machines never disagree about where a new file lands.
List<String> _pathsIn(String directory) {
  final dir = Directory(directory);
  if (!dir.existsSync()) {
    return const [];
  }
  final onDisk = dir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .map((file) => file.path.replaceAll(r'\', '/'))
      .toSet();

  final existing = _existingPathsFor(directory);
  final ordered = <String>[
    // Keep committed entries first, but only those still on disk. A file that
    // was deleted from disk must drop out, which is what makes removal visible.
    for (final path in existing)
      if (onDisk.contains(path)) path,
  ];

  final added = onDisk.difference(ordered.toSet()).toList()..sort();
  return [...ordered, ...added];
}

/// The paths the committed manifest already lists for a directory, in order.
///
/// Searches every group's every language list rather than one representative
/// language. The first version only looked at `languages.first`, which
/// silently did nothing for the Kiswahili lists — they came back empty, every
/// `sw` file was treated as new, and the manifest got re-sorted. That is
/// exactly the bundled-JSON churn this function exists to prevent.
List<String> _existingPathsFor(String directory) {
  final paths = _readExistingManifest();
  if (paths == null) {
    return const [];
  }

  final prefix = '$directory/';
  for (final group in _groups.values) {
    final byLanguage = paths[group];
    if (byLanguage is! Map) {
      continue;
    }
    for (final listed in byLanguage.values) {
      if (listed is! List) {
        continue;
      }
      final matching = listed
          .whereType<String>()
          .where((path) => path.startsWith(prefix))
          .toList();
      if (matching.isNotEmpty) {
        return matching;
      }
    }
  }
  return const [];
}

Map<String, Object?>? _readExistingManifest() {
  final file = File(manifestPath);
  if (!file.existsSync()) {
    return null;
  }
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    return decoded is Map ? decoded.cast<String, Object?>() : null;
  } on FormatException {
    // A malformed manifest is regenerated wholesale; nothing to preserve.
    return null;
  }
}

String _readExistingLastUpdated() {
  final decoded = _readExistingManifest();
  final value = decoded?['last_updated'];
  return value is String ? value : '';
}

void _write(Map<String, Object?> manifest) {
  final file = File(manifestPath);
  final existing = file.existsSync() ? file.readAsStringSync() : null;
  final encoded = '${const JsonEncoder.withIndent('  ').convert(manifest)}\n';

  if (existing == encoded) {
    stdout.writeln('Content manifest already up to date.');
    return;
  }

  file.writeAsStringSync(encoded);
  stdout.writeln('Wrote $manifestPath');
}

void _check(Map<String, Object?> manifest) {
  final file = File(manifestPath);
  if (!file.existsSync()) {
    stderr.writeln(
      'Content manifest is missing: $manifestPath\n'
      'Run: dart run tool/generate_content_manifest.dart',
    );
    exitCode = 1;
    return;
  }

  // Compared as decoded values, not as text. The question `--check` answers is
  // "does the manifest agree with the files on disk", which is a question about
  // content, not about whitespace. A byte comparison would have flagged the
  // committed manifest as stale purely because `dart format` had reflowed its
  // short `"languages": ["en", "sw"]` array onto one line.
  final actual = _decodeOrNull(file.readAsStringSync());

  if (_deepEquals(actual, manifest)) {
    stdout.writeln('Content manifest matches disk.');
    return;
  }

  stderr.writeln(
    'Content manifest does not match the files on disk.\n'
    'Run: dart run tool/generate_content_manifest.dart\n'
    '${_diff(manifest, actual)}',
  );
  exitCode = 1;
}

Map<String, Object?>? _decodeOrNull(String source) {
  try {
    final decoded = jsonDecode(source);
    return decoded is Map ? decoded.cast<String, Object?>() : null;
  } on FormatException {
    return null;
  }
}

bool _deepEquals(Object? a, Object? b) {
  if (a is Map && b is Map) {
    if (a.length != b.length) {
      return false;
    }
    for (final key in a.keys) {
      if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) {
        return false;
      }
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index += 1) {
      if (!_deepEquals(a[index], b[index])) {
        return false;
      }
    }
    return true;
  }
  return a == b;
}

/// A per-path report of what drifted, naming the files involved so the author
/// does not have to diff two JSON blobs by hand.
String _diff(Map<String, Object?> expected, Map<String, Object?>? actual) {
  if (actual == null) {
    return '  the manifest on disk is not valid JSON';
  }

  final changes = <String>[];

  for (final group in ['prayers', 'rosary', 'novenas']) {
    final expectedByLanguage = expected[group];
    final actualByLanguage = actual[group];
    if (expectedByLanguage is! Map || actualByLanguage is! Map) {
      changes.add(
        '  $group: present in manifest but not generated, or vice versa',
      );
      continue;
    }

    for (final language in languages) {
      final expectedPaths = (expectedByLanguage[language] as List?) ?? const [];
      final actualPaths = (actualByLanguage[language] as List?) ?? const [];

      for (final path in expectedPaths.where((p) => !actualPaths.contains(p))) {
        changes.add(
          '  $group/$language: on disk but missing from the manifest: $path',
        );
      }
      for (final path in actualPaths.where((p) => !expectedPaths.contains(p))) {
        changes.add(
          '  $group/$language: in the manifest but not on disk: $path',
        );
      }
      if (expectedPaths.length != actualPaths.length) {
        changes.add(
          '  $group/$language: order or count differs '
          '(manifest ${actualPaths.length}, disk ${expectedPaths.length})',
        );
      }
    }
  }

  if (changes.isEmpty) {
    return '  (structure matches; some scalar field differs)';
  }
  return changes.take(20).join('\n');
}
