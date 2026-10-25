import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/data/models/novena_model.dart';
import 'package:salakatoliki/data/models/prayer_model.dart';
import 'package:salakatoliki/shared/content/reading_markup.dart';

void main() {
  test('markers preserve body bytes for all 244 bundled readings', () {
    final expected =
        jsonDecode(
              File(
                'test/fixtures/pre_marker_body_hashes.json',
              ).readAsStringSync(),
            )
            as Map;
    final actual = <String, String>{};
    void add(String key, String markedBody) {
      final body = ReadingMarkup.plainText(markedBody);
      var hash = 0x811c9dc5;
      for (final byte in utf8.encode(body)) {
        hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
      }
      actual[key] = hash.toRadixString(16).padLeft(8, '0');
    }

    for (final language in ['en', 'sw']) {
      for (final file in Directory(
        'assets/content/prayers/$language',
      ).listSync().whereType<File>()) {
        for (final prayer in jsonDecode(file.readAsStringSync()) as List) {
          add('prayer:$language:${prayer['id']}', prayer['body'] as String);
        }
      }
      for (final file in Directory(
        'assets/content/novenas/$language',
      ).listSync().whereType<File>()) {
        final novena = jsonDecode(file.readAsStringSync()) as Map;
        for (final day in novena['days'] as List) {
          add(
            'novena:$language:${novena['id']}:day${day['day']}',
            day['body'] as String,
          );
        }
        for (final entry in {
          'closing_prayer': 'closing',
          'thanksgiving_section': 'thanks',
        }.entries) {
          final section = novena[entry.key] as Map?;
          if (section != null) {
            add(
              'novena:$language:${novena['id']}:${entry.value}',
              section['body'] as String,
            );
          }
        }
      }
    }
    // Pin existing IDs without requiring fixture edits for new prayers or
    // innocuous file reordering. Removing or changing a baseline still fails.
    expect(expected.length, 244);
    for (final entry in expected.entries) {
      expect(actual[entry.key], entry.value, reason: entry.key as String);
    }
  });

  test(
    'plain APIs used by search, sharing and widgets never contain markers',
    () {
      final prayers =
          jsonDecode(
                File(
                  'assets/content/prayers/en/litanies.json',
                ).readAsStringSync(),
              )
              as List;
      for (final json in prayers) {
        final prayer = PrayerModel.fromJson(
          json as Map<String, dynamic>,
          categoryTitles: const {},
        );
        expect(prayer.readingText, contains('[['));
        expect(prayer.body, isNot(contains('[[')));
        expect(prayer.text(), prayer.body);
        expect(prayer.matches('[[response]]'), isFalse);
        expect(prayer.score('[[heading]]'), 0);
      }
      final novena = NovenaModel.fromJson(
        jsonDecode(
              File(
                'assets/content/novenas/en/st_rita_novena.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>,
      );
      for (final day in novena.days) {
        expect(day.readingText, contains('[['));
        expect(day.body, isNot(contains('[[')));
      }
      expect(novena.closingPrayer!.body, isNot(contains('[[')));
      expect(novena.thanksgivingSection!.body, isNot(contains('[[')));
    },
  );

  test('marker grammar rejects malformed, unmatched and excessive nesting', () {
    for (final input in [
      '[[heading]]missing close',
      '[[heading]]mismatch[[/response]]',
      '[[unknown]]typo[[/unknown]]',
      '[[Heading]]case typo[[/Heading]]',
      '[[heading]bad brackets',
      '[[/plain]]stray close',
      '[[plain]]x[[/plain]]]]',
      '${List.filled(9, '[[group]]').join()}x${List.filled(9, '[[/group]]').join()}',
    ]) {
      expect(
        () => ReadingMarkup.parse(input),
        throwsFormatException,
        reason: input,
      );
    }
  });

  test('validation requires complete, supported block declarations', () {
    for (final input in [
      'Unmarked text',
      '[[plain]]Declared[[/plain]]\nForgotten line',
      '[[invocation]]Unsupported[[/invocation]]',
      '[[plain]]nested [[italic]]text[[/italic]][[/plain]]',
      '[[plain]]  [[/plain]]',
    ]) {
      expect(
        () => ReadingMarkup.validate(input, mode: 'prayer'),
        throwsFormatException,
      );
    }
    for (final input in [
      '[[group]]unmarked child[[/group]]',
      '[[rich]][[heading]]bad inline style[[/heading]][[/rich]]',
      '[[rich]][[italic]][[plain]]bad nesting[[/plain]][[/italic]][[/rich]]',
    ]) {
      expect(
        () => ReadingMarkup.validate(input, mode: 'novena'),
        throwsFormatException,
      );
    }
    expect(
      () => ReadingMarkup.validate(
        '[[panel_gold]]Ignored panel[[/panel_gold]]',
        mode: 'litany_st_rita',
      ),
      throwsFormatException,
    );
    expect(
      () => ReadingMarkup.validate(
        '[[response]]Ignored response[[/response]]',
        mode: 'litany',
      ),
      throwsFormatException,
    );
    ReadingMarkup.validate(
      '[[heading]]A rephrased heading[[/heading]]\n\n[[response]]Any language at all[[/response]]',
      mode: 'prayer',
    );
    ReadingMarkup.validate(
      '[[group]][[heading]]Rephrased[[/heading]][[plain]]Body[[/plain]][[/group]]',
      mode: 'novena',
    );
    ReadingMarkup.validate(
      '[[rich]]Before [[italic]]rephrased response[[/italic]] after[[/rich]]',
      mode: 'novena',
    );
  });
}
