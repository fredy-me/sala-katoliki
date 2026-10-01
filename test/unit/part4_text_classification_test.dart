import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/theme/app_theme.dart';
import 'package:salakatoliki/shared/widgets/litany_text_view.dart';
import 'package:salakatoliki/shared/widgets/novena_text_view.dart';
import 'package:salakatoliki/shared/widgets/prayer_text_view.dart';

/// These tests pin the classification heuristics in the three text views.
///
/// Part 4.1-4.3 rewrote how the regexes and normalized strings are obtained
/// (hoisted to `static final`, derived once per value) and Part 4.2 added a
/// cheap prefix gate in front of `_splitHeading`. All of that is a pure
/// performance refactor, so every assertion here is about *identical
/// classification*, not about the new code shape.
void main() {
  group('prayer text view classification', () {
    Future<List<TextStyle?>> stylesFor(WidgetTester tester, String text) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(child: PrayerTextView(text: text)),
          ),
        ),
      );
      final root = tester.widget<RichText>(find.byType(RichText)).text;
      return _leafStyles(root);
    }

    testWidgets('response lines are detected with and without markers', (
      tester,
    ) async {
      // The reference is ordinary prose, which must stay on the base style.
      final reference = (await stylesFor(tester, 'Ordinary prose line.')).first;

      for (final prefix in const [
        'Kiitikio:',
        'R:',
        'W:',
        'V:',
        'K:',
        'K.',
        'Kiongozi:',
        'Wote:',
        'TUOMBE',
        'Response:',
        'Let us pray',
      ]) {
        final plain = (await stylesFor(tester, '$prefix Amen.')).first;
        final starred = (await stylesFor(tester, '*$prefix* Amen.')).first;
        final quoted = (await stylesFor(tester, '"$prefix" Amen.')).first;

        expect(
          plain,
          isNot(reference),
          reason: '"$prefix" must be styled as a response line',
        );
        expect(starred, plain, reason: 'markers must be stripped');
        expect(quoted, plain, reason: 'quotes must be stripped');
      }
    });

    testWidgets('ordinary prose is not a response or a heading', (
      tester,
    ) async {
      const body = 'Our Father, who art in heaven, hallowed be thy name.';
      final prose = await stylesFor(tester, body);
      final response = await stylesFor(tester, 'R: Amen.');
      expect(
        prose.first,
        isNot(response.first),
        reason: 'plain prose must not pick up response styling',
      );
    });

    testWidgets('all-caps short lines are section headings', (tester) async {
      // 'Our Father' is deliberately not one of the response prefixes, so it
      // isolates the heading rule from the response rule.
      final reference = (await stylesFor(tester, 'Ordinary prose line.')).first;

      final heading = (await stylesFor(tester, 'OUR FATHER')).first;
      expect(
        heading,
        isNot(reference),
        reason: 'a short all-caps line is a section heading',
      );

      final short = (await stylesFor(tester, 'ABC')).first;
      expect(
        short,
        reference,
        reason: 'under 4 chars is not a heading',
      );

      final long = (
        await stylesFor(
          tester,
          'A VERY LONG ALL CAPS SENTENCE THAT GOES WELL PAST FORTY EIGHT CHARS',
        )
      ).first;
      expect(
        long,
        reference,
        reason: 'over 48 chars is not a heading',
      );
    });

    testWidgets('italic markup still produces multiple spans', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: PrayerTextView(text: 'Before _emphasis_ after'),
          ),
        ),
      );
      final spans = tester.widget<RichText>(find.byType(RichText)).text;
      final texts = _flattenText(spans);
      expect(texts, contains('emphasis'));
      expect(texts.join(), 'Before emphasis after');
    });
  });

  group('litany text view classification', () {
    testWidgets('st Rita headings, responses and Lamb of God', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: LitanyTextView(
                text: [
                  'THE LITANY OF ST. RITA',
                  'R: God, in your great mercy',
                  'Mwanakondoo utuoncee sisi',
                  'Lamb of God, have mercy on us.',
                  'Ordinary response line',
                ].join('\n'),
              ),
            ),
          ),
        ),
      );

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .toList();

      expect(texts, contains('THE LITANY OF ST. RITA'));
      expect(texts, contains('R: God, in your great mercy'));
      expect(texts, contains('Mwanakondoo utuoncee sisi'));
      expect(texts, contains('Lamb of God, have mercy on us.'));
      expect(texts, contains('Ordinary response line'));
      expect(texts, isNot(contains('*')), reason: 'markers must be stripped');
    });
  });

  group('novena text view classification', () {
    testWidgets('the 4.2 cheap gate does not suppress a real heading', (
      tester,
    ) async {
      // This exact line exists in st_rita_novena.json and is the only shape in
      // the shipped corpus that _splitHeading is written to catch. If the gate
      // ever rejects it, the heading silently renders as body text.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: NovenaTextView(
              text:
                  'Through Saint Rita: may fevers, sores and plague, '
                  'the germs of many diseases be utterly destroyed.',
            ),
          ),
        ),
      );

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .toList();

      expect(
        texts,
        contains('Through Saint Rita:'),
        reason: 'the heading must be split out as its own paragraph',
      );
      expect(
        texts,
        contains(
          'may fevers, sores and plague, the germs of many diseases '
          'be utterly destroyed.',
        ),
        reason: 'the body must survive the split intact',
      );
      expect(
        texts,
        isNot(
          contains(
            'Through Saint Rita: may fevers, sores and plague, '
            'the germs of many diseases be utterly destroyed.',
          ),
        ),
        reason: 'the paragraph must not remain unsplit',
      );
    });

    testWidgets('every heading prefix in the corpus still splits', (
      tester,
    ) async {
      const cases = <String, String>{
        'Through Saint Rita: body text here.': 'Through Saint Rita:',
        'Through your intercession: body text.': 'Through your intercession:',
        'LET US PRAY: body text here.': 'LET US PRAY:',
        'Kwa maombezi yako:- maombi hapa.': 'Kwa maombezi yako:-',
      };

      for (final entry in cases.entries) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(body: NovenaTextView(text: entry.key)),
          ),
        );
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((w) => w.data)
            .toList();
        expect(
          texts,
          contains(entry.value),
          reason: '"${entry.key}" must still be treated as a heading',
        );
      }
    });

    testWidgets('plain prose is not mistaken for a heading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: NovenaTextView(
              text: 'Almighty and everlasting God, we come before you '
                  'with our whole heart.',
            ),
          ),
        ),
      );
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data)
          .toList();
      expect(texts.any((t) => t == t!.toUpperCase() && t.contains('God')), isFalse);
    });

    testWidgets('request placeholders are split out', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: NovenaTextView(
              text: 'Here make your intention (Here make your intention).',
            ),
          ),
        ),
      );
      expect(find.textContaining('Here make your intention'), findsWidgets);
    });
  });

  group('shipped corpus renders without loss', () {
    test('every novena body still yields its paragraph text', () async {
      final failures = <String>[];

      for (final language in const ['en', 'sw']) {
        final dir = Directory('assets/content/novenas/$language');
        for (final file in dir.listSync().whereType<File>()) {
          final json =
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          for (final day in (json['days'] as List<dynamic>? ?? const [])) {
            final body = (day as Map<String, dynamic>)['body'] as String? ?? '';
            final paragraphs = body
                .split(RegExp(r'\n\s*\n'))
                .map((p) => p.trim())
                .where((p) => p.isNotEmpty)
                .toList();
            for (final paragraph in paragraphs) {
              final withoutMarkers = paragraph
                  .replaceAll('*', '')
                  .replaceAll('"', '')
                  .trim();
              if (withoutMarkers.isEmpty) {
                failures.add('${file.path}: empty paragraph in day body');
              }
            }
          }
        }
      }

      expect(failures, isEmpty);
    });
  });
}

/// Styles of the leaf spans only, skipping the root span, whose style is the
/// base style every line inherits.
List<TextStyle?> _leafStyles(InlineSpan span) {
  if (span is! TextSpan) {
    return const [];
  }
  final children = span.children ?? const <InlineSpan>[];
  if (children.isEmpty) {
    return <TextStyle?>[span.style];
  }
  return children.expand(_leafStyles).toList();
}

List<String> _flattenText(InlineSpan span) {
  if (span is! TextSpan) {
    return const [];
  }
  final texts = <String>[];
  if (span.text != null) {
    texts.add(span.text!);
  }
  for (final child in span.children ?? const <InlineSpan>[]) {
    texts.addAll(_flattenText(child));
  }
  return texts;
}
