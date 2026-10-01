import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/theme/app_theme.dart';
import 'package:salakatoliki/features/prayers/presentation/screens/prayer_detail_screen.dart';
import 'package:salakatoliki/shared/widgets/prayer_text_view.dart';
import 'package:salakatoliki/shared/utils/text_split_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_asset_bundle.dart';

void main() {
  group('4.4 body split cache', () {
    setUp(TextSplitCache.debugClear);

    test('lines are trimmed, empties dropped, and identical across calls', () {
      const body = '  first  \n\n second \n   \nthird\n';
      final first = TextSplitCache.lines(body);
      final second = TextSplitCache.lines(body);

      expect(first, ['first', 'second', 'third']);
      expect(identical(first, second), isTrue, reason: 'must be memoized');
    });

    test('paragraphs split on blank lines only', () {
      const body = 'one line\nstill one\n\nsecond para\n\n\nthird';
      final first = TextSplitCache.paragraphs(body);

      expect(first, ['one line\nstill one', 'second para', 'third']);
      expect(identical(first, TextSplitCache.paragraphs(body)), isTrue);
    });

    test('a single newline does not split a paragraph', () {
      const body = 'line one\nline two';
      expect(TextSplitCache.paragraphs(body), ['line one\nline two']);
      expect(TextSplitCache.lines(body), ['line one', 'line two']);
    });

    test('different bodies do not collide', () {
      expect(TextSplitCache.lines('a\nb'), ['a', 'b']);
      expect(TextSplitCache.lines('c'), ['c']);
      expect(TextSplitCache.lines('a\nb'), ['a', 'b']);
    });

    test('the cache stays bounded and stays correct after eviction', () {
      for (var i = 0; i < TextSplitCache.maxEntries + 20; i++) {
        TextSplitCache.lines('line $i');
      }
      expect(TextSplitCache.lines('line 0'), ['line 0']);
    });

    test('an empty body yields no parts', () {
      expect(TextSplitCache.lines(''), isEmpty);
      expect(TextSplitCache.paragraphs('   \n  \n '), isEmpty);
    });
  });

  group('4.5 text scale', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<void> pumpDetail(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localContentDataSourceProvider.overrideWithValue(
              testContentDataSource(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PrayerDetailScreen(prayerId: 'our_father'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    double fontSizeOf(WidgetTester tester) {
      return _leafFontSize(_prayerText(tester).text);
    }

    String textOf(WidgetTester tester) {
      return _prayerText(tester).text.toPlainText();
    }

    testWidgets('A+ grows the text, A- shrinks it, A restores it', (
      tester,
    ) async {
      await pumpDetail(tester);
      final base = fontSizeOf(tester);

      await tester.tap(find.text('A+'));
      await tester.pumpAndSettle();
      expect(fontSizeOf(tester), greaterThan(base));

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(fontSizeOf(tester), base);

      await tester.tap(find.text('A-'));
      await tester.pumpAndSettle();
      expect(fontSizeOf(tester), lessThan(base));
    });

    testWidgets('scaling never changes the text itself', (tester) async {
      await pumpDetail(tester);
      final before = textOf(tester);

      await tester.tap(find.text('A+'));
      await tester.pumpAndSettle();
      expect(textOf(tester), before);

      await tester.tap(find.text('A-'));
      await tester.pumpAndSettle();
      expect(textOf(tester), before);
    });

    testWidgets('scaling is clamped at both ends', (tester) async {
      await pumpDetail(tester);
      final base = fontSizeOf(tester);

      for (var i = 0; i < 8; i++) {
        await tester.tap(find.text('A+'));
        await tester.pumpAndSettle();
      }
      final largest = fontSizeOf(tester);
      await tester.tap(find.text('A+'));
      await tester.pumpAndSettle();
      expect(fontSizeOf(tester), largest, reason: 'A+ must stop at the max');

      for (var i = 0; i < 12; i++) {
        await tester.tap(find.text('A-'));
        await tester.pumpAndSettle();
      }
      final smallest = fontSizeOf(tester);
      await tester.tap(find.text('A-'));
      await tester.pumpAndSettle();
      expect(fontSizeOf(tester), smallest, reason: 'A- must stop at the min');

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(fontSizeOf(tester), base);
    });
  });

  group('4.1 and 4.5 structural guards', () {
    /// These read the source rather than the widget tree, because the property
    /// under test is *where* the state lives, which no widget test can observe.
    /// A regression to a plain `double` field plus `setState` would rebuild the
    /// whole screen on every A+ tap and would still pass every behavioural test
    /// above.
    test('no RegExp is constructed inside a build path', () {
      for (final path in const [
        'lib/shared/widgets/prayer_text_view.dart',
        'lib/shared/widgets/novena_text_view.dart',
        'lib/shared/widgets/litany_text_view.dart',
      ]) {
        final source = File(path).readAsStringSync();
        var index = source.indexOf('RegExp(');
        expect(index, isNot(-1), reason: '$path should still use RegExp');

        while (index != -1) {
          // Walk back to the start of the statement or block this expression
          // belongs to, and require that the statement is a static one.
          final before = source.substring(0, index);
          final boundary = before.lastIndexOf(RegExp(r'[;{}]'));
          final statement = before.substring(boundary + 1);
          expect(
            statement.contains('static'),
            isTrue,
            reason:
                '$path constructs a RegExp outside a static field near '
                '"${source.substring(index, (index + 40).clamp(0, source.length))}"',
          );
          index = source.indexOf('RegExp(', index + 1);
        }
      }
    });

    test('the text scale is a ValueNotifier, not a State field', () {
      for (final path in const [
        'lib/features/prayers/presentation/screens/prayer_detail_screen.dart',
        'lib/features/novenas/presentation/screens/novena_day_screen.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(
          source.contains('final ValueNotifier<double> _textScale'),
          isTrue,
          reason: '$path must hold the scale in a ValueNotifier',
        );
        expect(
          source.contains('_textScale.value ='),
          isTrue,
          reason: '$path must mutate the notifier directly',
        );
        expect(
          RegExp(
            r'setState\(\(\)\s*\{\s*_textScale',
          ).hasMatch(source),
          isFalse,
          reason: '$path must not change text scale through setState',
        );
      }
    });

    test('the heading split is gated behind a cheap prefix check', () {
      // 4.2. The point of the gate is that the 7 anchored, case-sensitive
      // regexes never run for a paragraph that cannot match. Asserting only
      // the outcome would pass whether the gate exists or not, because the
      // regexes are equivalent to the gate on real content. The order is the
      // behaviour, so the source has to be inspected.
      final source =
          File('lib/shared/widgets/novena_text_view.dart').readAsStringSync();

      final gate = source.indexOf('_couldBeHeading(displayLower)');
      final split = source.indexOf('_splitHeading(displayText)');
      expect(gate, isNot(-1), reason: 'the cheap gate should exist');
      expect(split, isNot(-1));
      expect(
        gate,
        lessThan(split),
        reason:
            'the regex-based heading split must be guarded by the cheap '
            'prefix check, not run unconditionally for every paragraph',
      );

      // And the gate itself must be substring/prefix work, not a regex.
      final gateBody = RegExp(
        r'bool _couldBeHeading\(String normalized\) \{\s*return containsAny\(',
      ).hasMatch(source);
      expect(
        gateBody,
        isTrue,
        reason: '_couldBeHeading should be a cheap list scan, not a regex',
      );
    });

    test('the text views read their split from the cache', () {
      for (final path in const [
        'lib/shared/widgets/prayer_text_view.dart',
        'lib/shared/widgets/novena_text_view.dart',
        'lib/shared/widgets/litany_text_view.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(
          source.contains('.split('),
          isFalse,
          reason: '$path must not re-split a body on every build',
        );
        expect(
          source.contains('TextSplitCache.'),
          isTrue,
          reason: '$path must read its split from the cache',
        );
      }
    });
  });
}

/// The RichText belonging to the prayer text itself, not the title above it —
/// a plain `Text` also builds a `RichText`, so the first one in the tree is
/// the title.
RichText _prayerText(WidgetTester tester) {
  return tester.widget<RichText>(
    find.descendant(
      of: find.byType(PrayerTextView),
      matching: find.byType(RichText),
    ),
  );
}

double _leafFontSize(InlineSpan span) {
  if (span is! TextSpan) {
    return 0;
  }
  final children = span.children ?? const <InlineSpan>[];
  if (children.isEmpty) {
    return span.style?.fontSize ?? 0;
  }
  return _leafFontSize(children.first);
}
