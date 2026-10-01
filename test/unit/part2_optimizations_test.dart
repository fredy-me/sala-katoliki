import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

String _read(String path) => File(path).readAsStringSync();

/// Part 2 of `app_optimization.md` was a set of size and CPU wins that are
/// invisible at runtime, so nothing else would catch a regression. These guards
/// pin the properties that made those wins possible.
void main() {
  group('2.1 logo asset', () {
    // PNG signature is 8 bytes, then a 4-byte chunk length, then "IHDR",
    // then width and height as big-endian uint32 at offsets 16 and 20.
    final bytes = File('assets/images/logo/logo.png').readAsBytesSync();
    final data = ByteData.sublistView(Uint8List.fromList(bytes));

    test('is a PNG of a sane size', () {
      expect(bytes.length, greaterThan(8));
      expect(
        String.fromCharCodes(bytes.sublist(1, 4)),
        'PNG',
        reason: 'logo.png must still be a real PNG',
      );
    });

    test('is 312x312, matching the largest render size at 3x density', () {
      final width = data.getUint32(16);
      final height = data.getUint32(20);
      expect(width, 312);
      expect(height, 312);
    });

    test('is small enough to keep in the binary without quantization loss',
        () {
      expect(
        bytes.length,
        lessThan(64 * 1024),
        reason: 'logo.png regressed past the size budget; the original asset '
            'was over 1 MB',
      );
    });

    test('is 8-bit indexed color, not a full RGBA bitmap', () {
      final bitDepth = bytes[24];
      final colorType = bytes[25];
      expect(bitDepth, 8);
      expect(
        colorType,
        3,
        reason: 'color type 3 is the palette form; 6 would be full RGBA',
      );
    });
  });

  group('2.2 logo decode', () {
    final source = _read('lib/shared/widgets/sala_logo_mark.dart');

    test('passes a DPR-derived cacheWidth so the source is never decoded '
        'at full size', () {
      expect(source, contains('cacheWidth'));
      expect(source, contains('devicePixelRatioOf'));
    });

    test('bounds the decode so a dense screen cannot blow it up', () {
      expect(source, contains('clamp'));
    });
  });

  group('2.3 theme construction', () {
    final source = _read('lib/core/theme/app_theme.dart');

    test('light and dark are cached, not rebuilt on every access', () {
      expect(source, contains('static final ThemeData light'));
      expect(source, contains('static final ThemeData dark'));
    });

    test('theme construction lives in private builders', () {
      expect(source, contains('ThemeData _light()'));
      expect(source, contains('ThemeData _dark()'));
    });
  });

  group('2.4 reminder time zone', () {
    final source = _read('lib/shared/services/notification_service.dart');
    final mapMatch = RegExp(
      r'static const Map<int, String> _timeZoneNameByOffsetMinutes\s*=\s*\{(.*?)\n  \};',
      dotAll: true,
    ).firstMatch(source);

    setUpAll(tz_data.initializeTimeZones);

    test('the full time-zone database is kept, because the reduced datasets '
        'omit the zones the app actually ships to', () {
      expect(source, contains("package:timezone/data/latest_all.dart"));
      expect(
        source,
        isNot(contains('data/latest.dart')),
        reason: 'latest.dart has no Africa/Dar_es_Salaam or UTC',
      );
    });

    test('declares a resolvable offset map', () {
      expect(mapMatch, isNotNull, reason: 'offset map should still be declared');
    });

    test('the obsolete abbreviation map is gone', () {
      expect(
        source,
        isNot(contains('_timeZoneNameByAbbreviation')),
        reason: 'it mapped UTC+1 to Europe/London and UTC+2 to Europe/Paris, '
            'which are wrong for half of every year, and had no UTC+4 entry, '
            'so UAE devices fell back to UTC',
      );
    });

    test('validates a candidate against the device offset before accepting it',
        () {
      expect(source, contains('_matchesCurrentOffset'));
      expect(source, contains('deviceOffset'));
    });

    test('every mapped zone exists and has no daylight saving', () {
      final body = mapMatch!.group(1)!;
      final entries = RegExp(r"(-?\d+):\s*'([^']+)'")
          .allMatches(body)
          .map((m) => (int.parse(m.group(1)!), m.group(2)!))
          .toList();

      expect(entries, isNotEmpty, reason: 'map should not be empty');

      for (final entry in entries) {
        final (minutes, name) = entry;
        final expected = Duration(minutes: minutes);

        final tz.Location location;
        try {
          location = tz.getLocation(name);
        } catch (_) {
          fail('$name (for UTC${expected.inMinutes >= 0 ? '+' : ''}'
              '${expected.inHours}h) is not a known time-zone ID');
        }

        final offsets = <Duration>{};
        for (var month = 1; month <= 12; month++) {
          offsets.add(
            tz.TZDateTime(location, 2026, month, 15, 12).timeZoneOffset,
          );
        }

        expect(
          offsets.length,
          1,
          reason: '$name observes daylight saving, so a device mapped to it '
              'by a single observed offset would be wrong for half the year',
        );
        expect(
          offsets.single,
          expected,
          reason: '$name does not match the offset it is mapped from',
        );
      }
    });

    test('covers the app\'s primary markets', () {
      final body = mapMatch!.group(1)!;
      final mapped = <int, String>{};
      for (final match in RegExp(r"(-?\d+):\s*'([^']+)'").allMatches(body)) {
        mapped[int.parse(match.group(1)!)] = match.group(2)!;
      }

      expect(
        mapped[180],
        'Africa/Nairobi',
        reason: 'Tanzania, Kenya and Uganda are all UTC+3 with no DST',
      );
      expect(
        mapped[240],
        'Asia/Dubai',
        reason: 'UAE is UTC+4 and was previously unmapped, so reminders fired '
            'four hours late',
      );
      expect(mapped[60], isNotNull, reason: 'western DRC is UTC+1');
      expect(mapped[120], isNotNull, reason: 'southern DRC is UTC+2');
    });
  });

  group('2.6 recent-prayer recording', () {
    final screen =
        _read('lib/features/prayers/presentation/screens/prayer_detail_screen.dart');
    final provider = _read(
      'lib/features/prayers/presentation/providers/prayer_providers.dart',
    );

    test('build no longer registers the recording side effect', () {
      final helperIndex = screen.indexOf('void _recordRecentOnce');
      final buildIndex = screen.indexOf('Widget build(BuildContext context)');
      expect(helperIndex, isNot(-1), reason: 'the one-time helper must exist');
      expect(buildIndex, isNot(-1));

      final registrations = RegExp(
        r'addPostFrameCallback',
      ).allMatches(screen).length;
      expect(
        registrations,
        1,
        reason: 'the post-frame callback belongs to the one-time helper and '
            'must not be registered from anywhere else in the screen',
      );

      final callbackIndex = screen.indexOf('addPostFrameCallback');
      expect(
        callbackIndex,
        greaterThan(helperIndex),
        reason: 'the helper is what registers the post-frame callback',
      );
      expect(
        callbackIndex,
        lessThan(buildIndex),
        reason: 'build() must not register the post-frame callback itself; it '
            'delegates to _recordRecentOnce instead',
      );
      expect(
        screen,
        contains('_recordRecentOnce(prayer.id)'),
        reason: 'build() should call the helper and nothing more',
      );
    });

    test('recording is guarded so it happens at most once per prayer', () {
      expect(screen, contains('_recordRecentOnce'));
      expect(screen, contains('_recordedPrayerId'));
      expect(
        screen,
        contains('if (_recordedPrayerId == prayerId)'),
        reason: 'the guard must return before scheduling a second write',
      );
      expect(
        screen,
        contains('if (!mounted)'),
        reason: 'the helper must not touch ref after the widget is disposed',
      );
    });

    test('the notifier skips an unchanged list instead of writing again', () {
      expect(provider, contains('listEquals'));
      expect(provider, contains("package:flutter/foundation.dart"));
    });
  });

  group('2.7 home widget writes', () {
    final source = _read('lib/shared/services/home_widget_service.dart');

    test('the four key writes are issued together', () {
      expect(source, contains('Future.wait'));
    });

    test('an unchanged payload skips the platform round trip', () {
      expect(source, contains('_lastWrittenPayload'));
    });

    test('the dedupe cache is only set after a successful write', () {
      final setIndex = source.indexOf('_lastWrittenPayload = payload');
      final writeIndex = source.indexOf('await Future.wait');
      expect(writeIndex, isNot(-1));
      expect(
        setIndex,
        greaterThan(writeIndex),
        reason: 'caching before the write would suppress a retry after failure',
      );
    });
  });

  group('2.8 st rita litany set', () {
    final screen =
        _read('lib/features/prayers/presentation/screens/prayer_detail_screen.dart');
    final rules =
        _read('lib/shared/widgets/text_style_rules.dart');

    test('is a static const set rather than a per-build literal', () {
      // 4.8 moved the set out of the screen so the rule is content-editable
      // in one place. The requirement is unchanged: it must be a top-level
      // const, not a literal rebuilt on every build().
      expect(
        rules,
        contains('const Set<String> kStRitaLitanies'),
        reason: 'the set should live in text_style_rules.dart as a const',
      );
      expect(
        screen,
        isNot(contains('Set<String> {')),
        reason: 'the screen must not rebuild a set literal per build',
      );
    });
  });
}
