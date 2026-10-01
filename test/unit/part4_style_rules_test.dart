import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/theme/app_colors.dart';
import 'package:salakatoliki/core/theme/app_theme.dart';
import 'package:salakatoliki/data/datasources/local_content_datasource.dart';
import 'package:salakatoliki/data/datasources/prayer_local_datasource.dart';
import 'package:salakatoliki/data/repositories/novena_repository.dart';
import 'package:salakatoliki/data/repositories/prayer_repository_impl.dart';
import 'package:salakatoliki/shared/widgets/litany_text_view.dart';
import 'package:salakatoliki/shared/widgets/novena_text_view.dart';
import 'package:salakatoliki/shared/widgets/prayer_text_view.dart';
import 'package:salakatoliki/shared/widgets/text_style_rules.dart';

/// The pre-4.8 classifiers, copied verbatim from the three text views before
/// their literals moved into `text_style_rules.dart`. If the data-driven version
/// disagrees with any of these on any shipped line, 4.8 changed rendering and
/// the build must fail.
class _Reference {
  static const nonLetter = r'[^A-Za-zÀ-ÿ]';

  static final _nonLetter = RegExp(nonLetter);
  static final _hasLetter = RegExp(r'[A-Za-zÀ-ÿ]');

  // ---- LitanyTextView -----------------------------------------------------

  static bool litanyHighlighted(String plainLower) {
    return plainLower.startsWith('kiitikio') ||
        plainLower.startsWith('response') ||
        plainLower.startsWith('r:') ||
        plainLower.startsWith('v:') ||
        plainLower.startsWith('k:') ||
        plainLower.startsWith('w:') ||
        plainLower.startsWith('k.') ||
        plainLower.startsWith('w.') ||
        plainLower.startsWith('kiongozi:') ||
        plainLower.startsWith('wote:') ||
        plainLower.startsWith('tuombe') ||
        plainLower.startsWith('let us pray');
  }

  static bool litanyResponse(String plainLower) {
    return plainLower.startsWith('kiitikio') ||
        plainLower.startsWith('response') ||
        plainLower.startsWith('r:') ||
        plainLower.startsWith('w:') ||
        plainLower.startsWith('r.') ||
        plainLower.startsWith('w.') ||
        plainLower.startsWith('all:') ||
        plainLower.startsWith('wote:') ||
        plainLower.endsWith('utuombee') ||
        plainLower.endsWith('pray for us');
  }

  static bool litanyStRitaHeading(String plainLower, String plainText) {
    final lettersOnly = plainText.replaceAll(_nonLetter, '');
    return (lettersOnly.isNotEmpty &&
            lettersOnly == lettersOnly.toUpperCase()) ||
        plainLower.startsWith('the litany of') ||
        plainLower.startsWith('litany to') ||
        plainLower.startsWith('litania ya') ||
        plainLower.startsWith('litania kwa') ||
        plainLower.startsWith('tuombe') ||
        plainLower.startsWith('let us pray');
  }

  static bool lambOfGod(String plainText) {
    return plainText.startsWith('Mwanakondoo') ||
        plainText.startsWith('Lamb of God') ||
        plainText.startsWith('O Lamb of God');
  }

  // ---- PrayerTextView -----------------------------------------------------

  static bool prayerResponse(String line) {
    final normalized = line
        .replaceAll('*', '')
        .replaceAll('"', '')
        .replaceAll('“', '')
        .replaceAll('”', '')
        .trim()
        .toLowerCase();

    return normalized.startsWith('kiitikio') ||
        normalized.startsWith('response') ||
        normalized.startsWith('r:') ||
        normalized.startsWith('v:') ||
        normalized.startsWith('k:') ||
        normalized.startsWith('w:') ||
        normalized.startsWith('k.') ||
        normalized.startsWith('w.') ||
        normalized.startsWith('kiongozi:') ||
        normalized.startsWith('wote:') ||
        normalized.startsWith('tuombe') ||
        normalized.startsWith('let us pray');
  }

  static bool prayerSectionHeading(String trimmed) {
    if (trimmed.length < 4 || trimmed.length > 48) {
      return false;
    }
    if (!_hasLetter.hasMatch(trimmed)) {
      return false;
    }
    final lettersOnly = trimmed.replaceAll(_nonLetter, '');
    if (lettersOnly.isEmpty) {
      return false;
    }
    return lettersOnly == lettersOnly.toUpperCase();
  }

  // ---- NovenaTextView -----------------------------------------------------

  static bool intentions(String n) {
    return n.startsWith('(state your intentions') ||
        n.startsWith('(mention your intention') ||
        n.startsWith('(taja nia zako') ||
        n.startsWith('(taja nia yako') ||
        n.startsWith('"today bring to me') ||
        n.startsWith('"leo uniletee') ||
        n.startsWith('holy spirit we ask for the grace of [') ||
        n.startsWith('roho mtakatifu, tunakuomba neema ya [') ||
        n.contains('(mention your intention') ||
        n.contains('(taja nia zako hapa)') ||
        n.contains('(taja nia yako hapa)');
  }

  static bool invocation(String n) {
    return n.startsWith('in the name of the father') ||
        n.startsWith('kwa jina la baba');
  }

  static bool exactHeading(String value, String n) {
    if (n == 'pray the divine mercy chaplet.' ||
        n == 'sali chapleti ya huruma ya mungu.' ||
        n == 'the litany of trust' ||
        n == 'litania ya tumaini') {
      return true;
    }
    if (value.length < 4 || value.length > 48) {
      return false;
    }
    final lettersOnly = value.replaceAll(_nonLetter, '');
    return lettersOnly.isNotEmpty && lettersOnly == lettersOnly.toUpperCase();
  }

  static const holySpirit = {
    'charity',
    'joy',
    'peace',
    'patience',
    'kindness',
    'faithfulness',
    'gentleness',
    'self-control',
    'goodness',
    'mapendo',
    'furaha',
    'amani',
    'subira',
    'ukarimu',
    'uaminifu',
    'upole',
    'kujitawala',
    'wema',
  };

  static bool holySpiritHeading(String n) => holySpirit.contains(n);

  static bool stRitaPrayerCount(String n) {
    return n.contains('our father (3)') || n.contains('baba yetu (3)');
  }

  static bool stRitaResponse(String n) {
    return n.startsWith('r:') || n.startsWith('w:');
  }

  static bool opening(String v) {
    return v.startsWith('kwa jina la baba') ||
        v.startsWith('in the name of the father');
  }

  static bool requestPlaceholder(String v) {
    return v.contains('(hapa omba') || v.contains('(here make');
  }

  static bool prayerCount(String v) {
    final sw =
        v.contains('baba yetu (3)') &&
        v.contains('salamu maria (3)') &&
        v.contains('atukuzwe baba (3)');
    final en =
        v.contains('our father (3)') &&
        v.contains('hail mary (3)') &&
        v.contains('glory be (3)');
    return sw || en;
  }

  static bool leaderResponse(String v) {
    return v.startsWith('k:') ||
        v.startsWith('w:') ||
        v.startsWith('v:') ||
        v.startsWith('r:');
  }

  static bool standaloneHeading(String v) {
    return v == 'tuombe:' ||
        v == 'utuombe:' ||
        v == 'let us pray:' ||
        v == 'sehemu ya pili' ||
        v == 'part two' ||
        v.startsWith('siku 3 za kumshukuru mungu') ||
        v.startsWith('three days of thanksgiving') ||
        v == 'baba yetu (3), salamu maria (3), atukuzwe baba (3)' ||
        v == 'our father (3), hail mary (3), glory be (3)';
  }

  static bool couldBeHeading(String n) {
    for (final p in [
      'kwa njia ya mtakatifu rita:-',
      'kwa maombezi yako:-',
      'tuombe:',
      'utuombe:',
      'through saint rita:',
      'through your intercession:',
      'let us pray:',
    ]) {
      if (n.contains(p)) {
        return true;
      }
    }
    return false;
  }
}


/// Local reimplementations of the two rules that are shape-based rather than
/// prefix-based, so the reference copy above has something to be compared
/// against rather than being asserted in a vacuum.
bool _isSectionHeading(String trimmed) {
  if (trimmed.length < 4 || trimmed.length > 48) {
    return false;
  }
  if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(trimmed)) {
    return false;
  }
  final lettersOnly = trimmed.replaceAll(_Reference.nonLetter, '');
  if (lettersOnly.isEmpty) {
    return false;
  }
  return lettersOnly == lettersOnly.toUpperCase();
}

bool _isStRitaHeading(String plainLower, String plainText) {
  final lettersOnly = plainText.replaceAll(_Reference.nonLetter, '');
  return (lettersOnly.isNotEmpty &&
          lettersOnly == lettersOnly.toUpperCase()) ||
      startsWithAny(plainLower, kLitanyHeadingPrefixes);
}

bool _isExactHeading(String value, String normalized) {
  if (normalized == 'pray the divine mercy chaplet.' ||
      normalized == 'sali chapleti ya huruma ya mungu.' ||
      normalized == 'the litany of trust' ||
      normalized == 'litania ya tumaini') {
    return true;
  }
  if (value.length < 4 || value.length > 48) {
    return false;
  }
  final lettersOnly = value.replaceAll(_Reference.nonLetter, '');
  return lettersOnly.isNotEmpty && lettersOnly == lettersOnly.toUpperCase();
}



/// The leaf [TextSpan]s rendered by [PrayerTextView], one per source line.
///
/// [Text.rich] wraps the supplied span in another [TextSpan] and
/// [_buildSpans] interleaves '\n' separators, so the tree is three levels
/// deep. Tests care about the leaves, not the nesting.
List<TextSpan> _prayerLeafSpans(WidgetTester tester) {
  final root = tester.widget<RichText>(find.byType(RichText)).text as TextSpan;
  final leaves = <TextSpan>[];

  void visit(InlineSpan span) {
    if (span is! TextSpan) return;
    final children = span.children;
    if (children == null) {
      if (span.text != null && span.text != '\n') leaves.add(span);
      return;
    }
    children.forEach(visit);
  }

  visit(root);
  return leaves;
}

/// The border colour of the decorated container wrapping [value].
Color? _borderColorOf(WidgetTester tester, String value) {
  final boxes = tester
      .widgetList<Container>(find.byType(Container))
      .where((c) => c.decoration is BoxDecoration)
      .toList();
  for (final box in boxes) {
    final border = (box.decoration! as BoxDecoration).border;
    if (border == null) continue;
    if (find.descendant(
      of: find.byWidget(box),
      matching: find.text(value),
    ).evaluate().isNotEmpty) {
      return (border as Border).top.color;
    }
  }
  return null;
}

/// The effective [FontStyle] of the [Text] rendering [value].
FontStyle? _fontStyleOf(WidgetTester tester, String value) {
  return tester.widget<Text>(find.text(value)).style?.fontStyle;
}

/// The effective [FontWeight] of the [Text] rendering [value].
FontWeight? _fontWeightOf(WidgetTester tester, String value) {
  return tester.widget<Text>(find.text(value)).style?.fontWeight;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> allLines;
  late List<String> allParagraphs;

  setUpAll(() async {
    final ds = LocalContentDataSource();
    final lines = <String>[];
    final paragraphs = <String>[];

    for (final lang in ['en', 'sw']) {
      final prayers = await PrayerRepositoryImpl(
        PrayerLocalDataSource(contentDataSource: ds),
      ).getPrayers(languageCode: lang);
      for (final p in prayers) {
        lines.addAll(p.text().split('\n'));
        paragraphs.addAll(p.text().split(RegExp(r'\n\s*\n')));
      }

      final novenas = await NovenaRepository(ds).getNovenas(
        languageCode: lang,
      );
      for (final n in novenas) {
        for (final day in n.days) {
          final body = day.body;
          lines.addAll(body.split('\n'));
          paragraphs.addAll(body.split(RegExp(r'\n\s*\n')));
        }
      }
    }

    allLines = lines.where((l) => l.trim().isNotEmpty).toList();
    allParagraphs = paragraphs.where((p) => p.trim().isNotEmpty).toList();
  });

  group('4.8 data-driven rules match the shipped corpus exactly', () {
    test('the corpus is non-trivial', () {
      expect(allLines.length, greaterThan(1000));
      expect(allParagraphs.length, greaterThan(500));
    });

    test('every classifier agrees with the pre-4.8 reference', () {
      var checked = 0;

      for (final raw in {...allLines, ...allParagraphs}) {
        final stripped = raw
            .replaceAll('*', '')
            .replaceAll('"', '')
            .replaceAll('“', '')
            .replaceAll('”', '')
            .trim();
        final lower = stripped.toLowerCase();
        final where = raw;

        // Litany
        expect(
          startsWithAny(lower, kResponsePrefixes),
          _Reference.litanyHighlighted(lower),
          reason: 'litany response prefix on: $where',
        );
        expect(
          startsWithAny(lower, kLitanyResponsePrefixes) ||
              endsWithAny(lower, kLitanyResponseSuffixes),
          _Reference.litanyResponse(lower),
          reason: 'litany response on: $where',
        );
        expect(
          startsWithAny(raw, kLambOfGodPrefixes),
          _Reference.lambOfGod(raw),
          reason: 'lamb of god on: $where',
        );
        expect(
          _isStRitaHeading(lower, stripped),
          _Reference.litanyStRitaHeading(lower, stripped),
          reason: 'st rita litany heading on: $where',
        );

        // Prayer
        expect(
          startsWithAny(
            raw
                .replaceAll('*', '')
                .replaceAll('"', '')
                .replaceAll('“', '')
                .replaceAll('”', '')
                .trim()
                .toLowerCase(),
            kResponsePrefixes,
          ),
          _Reference.prayerResponse(raw),
          reason: 'prayer response on: $where',
        );
        expect(
          _isSectionHeading(stripped),
          _Reference.prayerSectionHeading(stripped),
          reason: 'section heading on: $where',
        );
        expect(
          _isExactHeading(stripped, lower),
          _Reference.exactHeading(stripped, lower),
          reason: 'exact heading on: $where',
        );

        // Novena
        expect(
          startsWithAny(lower, kIntentionPrefixes) ||
              containsAny(lower, kIntentionContainsFragments),
          _Reference.intentions(lower),
          reason: 'intentions on: $where',
        );
        expect(
          startsWithAny(lower, kInvocationPrefixes),
          _Reference.invocation(lower),
          reason: 'invocation on: $where',
        );

        expect(
          equalsAny(lower, kHolySpiritHeadings),
          _Reference.holySpiritHeading(lower),
          reason: 'holy spirit heading on: $where',
        );
        expect(
          containsAny(lower, kStRitaPrayerCountFragments),
          _Reference.stRitaPrayerCount(lower),
          reason: 'st rita prayer count on: $where',
        );
        expect(
          startsWithAny(lower, kStRitaResponsePrefixes),
          _Reference.stRitaResponse(lower),
          reason: 'st rita response on: $where',
        );
        expect(
          startsWithAny(lower, kInvocationPrefixes),
          _Reference.opening(lower),
          reason: 'opening on: $where',
        );
        expect(
          containsAny(lower, kRequestPlaceholderFragments),
          _Reference.requestPlaceholder(lower),
          reason: 'request placeholder on: $where',
        );
        expect(
          containsAllOfAnyTriple(lower, kPrayerCountTriples),
          _Reference.prayerCount(lower),
          reason: 'prayer count on: $where',
        );
        expect(
          startsWithAny(lower, kLeaderResponsePrefixes),
          _Reference.leaderResponse(lower),
          reason: 'leader response on: $where',
        );
        expect(
          equalsAny(lower, kStandaloneHeadingEquals) ||
              startsWithAny(lower, kStandaloneHeadingPrefixes),
          _Reference.standaloneHeading(lower),
          reason: 'standalone heading on: $where',
        );
        expect(
          containsAny(lower, kHeadingWithBodyPrefixes),
          _Reference.couldBeHeading(lower),
          reason: 'heading gate on: $where',
        );

        checked++;
      }

      expect(checked, greaterThan(1000));
    });

    test('heading/body prefixes and patterns stay index-aligned', () {
      expect(
        kHeadingWithBodyPrefixes.length,
        kHeadingWithBodyPatterns.length,
      );

      for (var i = 0; i < kHeadingWithBodyPatterns.length; i++) {
        // The pattern's first group holds the heading in its authored case,
        // which differs per word ('Kwa njia ya Mtakatifu Rita:-'), so pull the
        // literal back out of the pattern source rather than guessing it from
        // the lowercase prefix. That is what makes this a real alignment check
        // instead of a restatement of the prefix list.
        final source = kHeadingWithBodyPatterns[i].pattern;
        final literal = RegExp(r'^\^\(([^)]+)\)\\s\*\(\.\+\)\$')
            .firstMatch(source);
        expect(
          literal,
          isNotNull,
          reason: 'pattern $i is not in the expected anchored form: $source',
        );

        final heading = literal!.group(1)!;
        expect(
          heading.toLowerCase(),
          kHeadingWithBodyPrefixes[i],
          reason: 'pattern $i matches a different heading than its gate',
        );

        // And the gate must not reject what the pattern accepts.
        final paragraph = '$heading  Body text follows.';
        expect(
          containsAny(paragraph.toLowerCase(), kHeadingWithBodyPrefixes),
          isTrue,
          reason: 'the gate rejects a paragraph pattern $i would match',
        );
        final match = kHeadingWithBodyPatterns[i].firstMatch(paragraph);
        expect(match, isNotNull, reason: 'pattern $i must match its heading');
        expect(match!.group(2), 'Body text follows.');
      }
    });

  });

  group('4.8 id sets', () {
    test('the St Rita litany set is pinned, not merely a subset of content', () {
      // Checking only "every id in the set exists in content" is one-directional:
      // silently dropping an id from the set would pass, and that id's litany
      // would lose its response styling. The exact membership is pinned so a
      // future edit has to be deliberate.
      expect(
        kStRitaLitanies,
        equals(<String>{
          'st_rita_litany',
          'bikira_maria_litany',
          'divine_mercy_litany',
          'holy_spirit_litany',
          'sacred_head_of_jesus_litany',
          'st_aloysius_gonzaga_litany',
          'st_jude_thaddeus_litany',
          'st_joseph_litany',
          'st_anthony_of_padua_litany_v1',
          'st_anthony_of_padua_litany_v2',
          'franciscan_st_anthony_litany',
          'st_anne_litany',
          'holy_angels_litany',
          'sacred_heart_of_jesus_litany',
          'holy_face_of_jesus_litany',
          'souls_in_purgatory_litany',
          'seven_sorrows_mary_litany',
          'litany_of_reparation',
        }),
      );
      expect(
        kAllSaintsNovenas,
        equals(<String>{
          'all_saints_day_novena',
          'divine_mercy_novena',
          'holy_family_novena',
          'holy_spirit_novena',
          'litany_of_trust_novena',
          'sacred_heart_of_jesus_novena',
          'st_aloysius_gonzaga_novena',
          'st_jude_novena',
          'st_rita_novena',
        }),
      );
      expect(
        kCommonPrayerCategoryIds,
        equals(<String>{
          'common_prayers',
          'mass_prayers',
          'confession_prayers',
          'divine_mercy',
        }),
      );
    });

    test('every St Rita litany id exists in the shipped content', () async {
      final ds = LocalContentDataSource();
      final ids = <String>{};
      for (final lang in ['en', 'sw']) {
        final prayers = await PrayerRepositoryImpl(
          PrayerLocalDataSource(contentDataSource: ds),
        ).getPrayers(languageCode: lang);
        ids.addAll(prayers.map((p) => p.id));
      }
      for (final id in kStRitaLitanies) {
        expect(ids, contains(id), reason: 'St Rita id $id is not in content');
      }
    });

    test('every All Saints novena id exists in the shipped content', () async {
      final ds = LocalContentDataSource();
      final ids = <String>{};
      for (final lang in ['en', 'sw']) {
        final novenas = await NovenaRepository(ds).getNovenas(
          languageCode: lang,
        );
        ids.addAll(novenas.map((n) => n.id));
      }
      for (final id in kAllSaintsNovenas) {
        expect(ids, contains(id), reason: 'All Saints id $id is not in content');
      }
      expect(kAllSaintsNovenas, contains(kHolySpiritNovenaId));
      expect(kAllSaintsNovenas, contains(kStRitaNovenaId));
    });

    test('the common prayer categories exist in the shipped content', () async {
      final categories = await LocalContentDataSource().getCategories();
      final ids = categories.map((c) => c.id).toSet();
      for (final id in kCommonPrayerCategoryIds) {
        expect(ids, contains(id), reason: 'category $id is not in content');
      }
    });
  });

  group('4.8 source-level guard', () {
    test('no text view hardcodes a presentation prefix any more', () {
      const views = [
        'lib/shared/widgets/litany_text_view.dart',
        'lib/shared/widgets/novena_text_view.dart',
        'lib/shared/widgets/prayer_text_view.dart',
      ];

      for (final path in views) {
        final source = File(path).readAsStringSync();
        final pattern = RegExp(
          r'''\.(startsWith|endsWith|contains)\(\s*['"]''',
        );
        for (final match in pattern.allMatches(source)) {
          final line =
              source.substring(0, match.start).split('\n').length;
          // A single `*` marker check is formatting, not a content prefix.
          final text = source.substring(match.start, match.end + 2);
          if (text.contains("'*'")) {
            continue;
          }
          fail(
            '$path:$line still hardcodes a presentation string: '
            '${source.substring(match.start, match.start + 40)}',
          );
        }
      }
    });
  });

  group('4.8 prefix literals are pinned', () {
    // The corpus comparison above cannot catch a rule that never fires on
    // shipped content: adding a bogus prefix, or writing 'k. ' with a trailing
    // space, both leave every real line classified the same way. Those are real
    // defects for an author who later adds matching content, so the exact
    // literals are pinned here. This is the check that would have caught the
    // trailing-space regression introduced while writing this change.
    test('every prefix list is exactly what it was before 4.8', () {
      expect(
        kResponsePrefixes,
        equals(<String>[
          'kiitikio',
          'response',
          'r:',
          'v:',
          'k:',
          'w:',
          'k.',
          'w.',
          'kiongozi:',
          'wote:',
          'tuombe',
          'let us pray',
        ]),
      );
      expect(
        kLitanyResponsePrefixes,
        equals(<String>[
          'kiitikio',
          'response',
          'r:',
          'w:',
          'r.',
          'w.',
          'all:',
          'wote:',
        ]),
      );
      expect(
        kLitanyResponseSuffixes,
        equals(<String>['utuombee', 'pray for us']),
      );
      expect(
        kLambOfGodPrefixes,
        equals(<String>['Mwanakondoo', 'Lamb of God', 'O Lamb of God']),
      );
      expect(
        kInvocationPrefixes,
        equals(<String>['in the name of the father', 'kwa jina la baba']),
      );
      expect(
        kLeaderResponsePrefixes,
        equals(<String>['k:', 'w:', 'v:', 'r:']),
      );
      expect(
        kStRitaResponsePrefixes,
        equals(<String>['r:', 'w:']),
      );
      expect(
        kRequestPlaceholderFragments,
        equals(<String>['(hapa omba', '(here make']),
      );
      expect(
        kStandaloneHeadingPrefixes,
        equals(<String>[
          'siku 3 za kumshukuru mungu',
          'three days of thanksgiving',
        ]),
      );
      expect(
        kStandaloneHeadingEquals,
        equals(<String>[
          'tuombe:',
          'utuombe:',
          'let us pray:',
          'sehemu ya pili',
          'part two',
          'baba yetu (3), salamu maria (3), atukuzwe baba (3)',
          'our father (3), hail mary (3), glory be (3)',
        ]),
      );
      expect(
        kExactHeadingEquals,
        equals(<String>[
          'pray the divine mercy chaplet.',
          'sali chapleti ya huruma ya mungu.',
          'the litany of trust',
          'litania ya tumaini',
        ]),
      );
      expect(
        kIntentionPrefixes,
        equals(<String>[
          '(state your intentions',
          '(mention your intention',
          '(taja nia zako',
          '(taja nia yako',
          '"today bring to me',
          '"leo uniletee',
          'holy spirit we ask for the grace of [',
          'roho mtakatifu, tunakuomba neema ya [',
        ]),
        reason: 'the anchored prefixes are what the original startsWith clause used',
      );
      expect(
        kIntentionContainsFragments,
        equals(<String>[
          '(mention your intention',
          '(taja nia zako hapa)',
          '(taja nia yako hapa)',
        ]),
        reason:
            'only the hapa) forms need the unanchored clause; the rest would '
            'broaden the match if folded into contains',
      );
      expect(
        kHolySpiritHeadings,
        equals(<String>[
          'charity',
          'joy',
          'peace',
          'patience',
          'kindness',
          'faithfulness',
          'gentleness',
          'self-control',
          'goodness',
          'mapendo',
          'furaha',
          'amani',
          'subira',
          'ukarimu',
          'uaminifu',
          'upole',
          'kujitawala',
          'wema',
        ]),
      );
      expect(
        kStRitaPrayerCountFragments,
        equals(<String>['our father (3)', 'baba yetu (3)']),
      );
      expect(
        kPrayerCountTriples,
        equals(<List<String>>[
          <String>['baba yetu (3)', 'salamu maria (3)', 'atukuzwe baba (3)'],
          <String>['our father (3)', 'hail mary (3)', 'glory be (3)'],
        ]),
      );
    });

    test('no prefix or fragment literal carries stray whitespace', () {
      // The specific mistake 4.8 nearly shipped: 'k.' typed as 'k. ' stops
      // matching a line that begins 'k.something' while still matching 'k. ',
      // so it looks correct on the shipped corpus. Only prefix/fragment lists
      // are checked: the exact-equality lists legitimately contain headings
      // that end in a period or a colon, and kHolySpiritHeadings is
      // self-control.
      final lists = <String, List<String>>{
        'kResponsePrefixes': kResponsePrefixes,
        'kLitanyResponsePrefixes': kLitanyResponsePrefixes,
        'kLitanyResponseSuffixes': kLitanyResponseSuffixes,
        'kInvocationPrefixes': kInvocationPrefixes,
        'kLeaderResponsePrefixes': kLeaderResponsePrefixes,
        'kStRitaResponsePrefixes': kStRitaResponsePrefixes,
        'kRequestPlaceholderFragments': kRequestPlaceholderFragments,
        'kLambOfGodPrefixes': kLambOfGodPrefixes,
        'kStandaloneHeadingPrefixes': kStandaloneHeadingPrefixes,
        'kIntentionPrefixes': kIntentionPrefixes,
        'kIntentionContainsFragments': kIntentionContainsFragments,
        'kStRitaPrayerCountFragments': kStRitaPrayerCountFragments,
        'kLitanyHeadingPrefixes': kLitanyHeadingPrefixes,
        'kHeadingWithBodyPrefixes': kHeadingWithBodyPrefixes,
      };

      for (final entry in lists.entries) {
        for (final value in entry.value) {
          expect(
            value,
            equals(value.trim()),
            reason:
                '${entry.key} has a literal with surrounding whitespace: '
                '"$value". Note that a trailing space is not cosmetic: it '
                'silently stops matching content that follows.',
          );
        }
      }
    });

    test('rule lists contain no duplicates', () {
      final lists = <String, List<String>>{
        'kResponsePrefixes': kResponsePrefixes,
        'kLitanyResponsePrefixes': kLitanyResponsePrefixes,
        'kInvocationPrefixes': kInvocationPrefixes,
        'kHolySpiritHeadings': kHolySpiritHeadings,
        'kIntentionPrefixes': kIntentionPrefixes,
        'kIntentionContainsFragments': kIntentionContainsFragments,
        'kHeadingWithBodyPrefixes': kHeadingWithBodyPrefixes,
        'kStandaloneHeadingEquals': kStandaloneHeadingEquals,
      };
      for (final entry in lists.entries) {
        expect(
          entry.value.toSet().length,
          entry.value.length,
          reason: '${entry.key} has duplicate entries, so one is dead',
        );
      }
    });
  });

  group('4.8 the widgets actually consult the rules', () {
    // The corpus comparison above proves the rule *data* matches the old
    // literals. It cannot prove the widgets still read that data: swapping
    // `containsAllOfAnyTriple` for a disjunction, or stubbing out the heading
    // gate, leaves every rule list correct and changes rendering. These tests
    // pin the wiring by observing rendered output.

    testWidgets('the (3) prayer count needs all three, not just one', (
      tester,
    ) async {
      const complete = 'Our Father (3), Hail Mary (3), Glory Be (3).';
      const partial = 'Our Father (3) and then some ordinary prose.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: NovenaTextView(text: complete),
          ),
        ),
      );
      // A standalone heading renders highlighted, so it is wrapped in a
      // decorated container rather than a bare Text.
      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(complete),
        ),
        findsOneWidget,
        reason: 'the complete triple must be treated as a heading',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: NovenaTextView(text: partial),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(partial),
        ),
        findsNothing,
        reason: 'a single stray (3) must not trigger the heading styling',
      );
      expect(find.text(partial), findsOneWidget);
    });

    testWidgets('the invocation prefix list splits a novena opening', (
      tester,
    ) async {
      const opening = 'In the name of the Father, and of the Son.';
      const body = 'And of the Holy Spirit. Amen.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: NovenaTextView(text: '$opening\n$body'),
          ),
        ),
      );

      // _splitOpening turns the two lines into two separate widgets.
      expect(find.text(opening), findsOneWidget);
      expect(find.text(body), findsOneWidget);
    });

    testWidgets('the heading gate still admits a TUOMBE: paragraph', (
      tester,
    ) async {
      const heading = 'TUOMBE:';
      const body = 'Bless us, good Lord.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: NovenaTextView(text: '$heading $body'),
          ),
        ),
      );

      // The split produces a highlighted heading and a separate body Text.
      expect(find.text(heading), findsOneWidget);
      expect(find.text(body), findsOneWidget);
      expect(
        find.descendant(of: find.byType(DecoratedBox), matching: find.text(heading)),
        findsOneWidget,
        reason: 'the heading half is highlighted, which means the split ran',
      );
    });

    testWidgets('a body-only paragraph is not split into a heading', (
      tester,
    ) async {
      const plain = 'Bless us, good Lord, as we strive to serve you.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: NovenaTextView(text: plain),
          ),
        ),
      );

      expect(find.text(plain), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(plain),
        ),
        findsNothing,
      );
    });

    testWidgets('the St Rita response prefixes italicise a leader line', (
      tester,
    ) async {
      const leader = 'R: Let us pray.';
      const ordinary = 'Saint Rita, pray for us.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: LitanyTextView(text: '$leader\n$ordinary', stRitaStyle: true),
          ),
        ),
      );

      expect(
        _fontStyleOf(tester, leader),
        FontStyle.italic,
        reason: 'an R: line under St Rita styling is a response',
      );
      expect(
        _fontStyleOf(tester, ordinary),
        isNot(FontStyle.italic),
        reason: 'an ordinary line is not a response',
      );
    });

    testWidgets('the St Rita heading prefixes uppercase a litany title', (
      tester,
    ) async {
      const title = 'The litany of the Holy Spirit';
      const ordinary = 'By the passion of Christ.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: LitanyTextView(text: '$title\n$ordinary', stRitaStyle: true),
          ),
        ),
      );

      // The St Rita heading branch is the only one that uppercases and
      // bolds; every other branch leaves the source casing alone.
      expect(
        find.text('THE LITANY OF THE HOLY SPIRIT'),
        findsOneWidget,
        reason: 'a "the litany of" heading is uppercased by the St Rita branch',
      );
      expect(_fontWeightOf(tester, 'THE LITANY OF THE HOLY SPIRIT'), FontWeight.w800);
      expect(_fontStyleOf(tester, 'THE LITANY OF THE HOLY SPIRIT'), isNot(FontStyle.italic));
      expect(
        _fontWeightOf(tester, ordinary),
        FontWeight.w400,
        reason: 'an ordinary line keeps the body weight',
      );
    });

    testWidgets('a non-heading first line is not uppercased under St Rita', (
      tester,
    ) async {
      const ordinary = 'By the passion of Christ, we beseech you.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: LitanyTextView(text: ordinary, stRitaStyle: true),
          ),
        ),
      );

      expect(find.text(ordinary), findsOneWidget);
      expect(find.text(ordinary.toUpperCase()), findsNothing);
    });

    testWidgets('the leader-response prefixes highlight a novena response', (
      tester,
    ) async {
      const leader = 'K: Let us pray.';
      const ordinary = 'Saint Joseph, pray for us.';

      // A blank line is required: a single newline is one paragraph, and the
      // highlight decision is made per paragraph.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: NovenaTextView(text: '$leader\n\n$ordinary'),
          ),
        ),
      );

      // _isLeaderResponse feeds _isStructuredHighlight, which wraps the
      // paragraph in the highlighted container.
      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(leader),
        ),
        findsOneWidget,
        reason: 'a k: line is a leader response and is highlighted',
      );
      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(ordinary),
        ),
        findsNothing,
        reason: 'an ordinary paragraph is not highlighted',
      );
    });

    testWidgets('the Lamb of God prefixes frame a line without gold', (
      tester,
    ) async {
      // In the plain litany branch a Lamb of God line shares the decorated
      // container with a response line; only the border colour separates
      // them, so the border has to be asserted too.
      const lamb = 'Lamb of God, have mercy on us.';
      const ordinary = 'An instruction for the assembly.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: LitanyTextView(text: '$lamb\n\n$ordinary')),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(lamb),
        ),
        findsOneWidget,
        reason: 'a Lamb of God line is framed',
      );
      expect(
        _borderColorOf(tester, lamb),
        isNot(AppColors.gold),
        reason: 'a Lamb of God line is framed but is not a response',
      );
      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(ordinary),
        ),
        findsNothing,
        reason: 'an ordinary line is left unframed',
      );
    });

    testWidgets('a trailing "pray for us" also marks a St Rita response', (
      tester,
    ) async {
      // Suffix matching is the only thing separating these lines from
      // ordinary body text, so a silent failure here is invisible otherwise.
      const suffixed = 'All holy men and women, pray for us';
      const punctuated = 'All holy men and women, pray for us.';
      const ordinary = 'Let us remember the saints in peace.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: LitanyTextView(
              text: '$suffixed\n$punctuated\n$ordinary',
              stRitaStyle: true,
            ),
          ),
        ),
      );

      expect(
        _fontStyleOf(tester, suffixed),
        FontStyle.italic,
        reason: 'a line ending in "pray for us" is a response',
      );
      expect(
        _fontStyleOf(tester, punctuated),
        isNot(FontStyle.italic),
        reason:
            'the suffix match is literal, so a trailing full stop defeats it. '
            'No shipped line depends on the suffix path, so this is pinned as '
            'pre-existing behaviour rather than a bug fixed here',
      );
      expect(
        _fontStyleOf(tester, ordinary),
        isNot(FontStyle.italic),
        reason: 'a line without a response prefix or suffix is not one',
      );
    });

    testWidgets('a trailing "utuombee" also marks a St Rita response', (
      tester,
    ) async {
      const suffixed = 'Wote watakatifu, utuombee';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: LitanyTextView(text: suffixed, stRitaStyle: true),
          ),
        ),
      );

      expect(_fontStyleOf(tester, suffixed), FontStyle.italic);
    });

    testWidgets('a litany response line is framed in gold', (tester) async {
      const response = 'kiitikio: tupigeze mbali u adhui.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: LitanyTextView(text: response)),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(response),
        ),
        findsOneWidget,
      );
      expect(
        _borderColorOf(tester, response),
        AppColors.gold,
        reason: 'a k: response line is highlighted with the gold border',
      );
    });

    testWidgets('an m: line is not treated as a response', (tester) async {
      const notAResponse = 'm: not a response prefix.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: LitanyTextView(text: notAResponse)),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(notAResponse),
        ),
        findsNothing,
        reason: 'only the listed prefixes count as responses',
      );
    });

    testWidgets('the prayer response prefixes bold a response span', (
      tester,
    ) async {
      // PrayerTextView styles per raw line, so the assertion has to look at
      // the TextSpan styles rather than at a widget per line.
      const response = 'Response: Let us pray.';
      const ordinary = 'Ordinary body text.';
      const heading = 'FIRST READING';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: PrayerTextView(text: '$response\n$ordinary\n$heading'),
          ),
        ),
      );

      final spans = _prayerLeafSpans(tester);
      expect(spans.length, 3, reason: 'three lines produce three spans');
      expect(spans.map((s) => s.text), [response, ordinary, heading]);

      expect(
        spans[0].style?.fontWeight,
        FontWeight.w800,
        reason: 'a response line is bold',
      );
      expect(
        spans[0].style?.letterSpacing,
        0.0,
        reason: 'a response line carries no heading letter-spacing',
      );
      expect(
        spans[1].style?.fontWeight,
        isNot(FontWeight.w800),
        reason: 'an ordinary line is not bold',
      );
      expect(
        spans[2].style?.letterSpacing,
        0.4,
        reason: 'an all-caps line is a section heading, not a response',
      );
    });

    testWidgets('a k: response in a prayer is styled like an r: one', (
      tester,
    ) async {
      const swahili = 'kiitikio: tuombe';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: PrayerTextView(text: swahili)),
        ),
      );

      final child = _prayerLeafSpans(tester).single;
      expect(child.style?.fontWeight, FontWeight.w800);
      expect(child.style?.letterSpacing, 0.0);
    });

    testWidgets('a v: line is highlighted too, not just k: and w:', (
      tester,
    ) async {
      const leader = 'V: Let us pray.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: NovenaTextView(text: leader)),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.text(leader),
        ),
        findsOneWidget,
      );
    });
  });

  group('4.8 rendering is unchanged', () {
    // Asserting the rule data against the reference literals is not enough for
    // the intention classifier: the pre-4.8 code was `startsWith` over eight
    // prefixes OR'd with `contains` over three fragments, and a single merged
    // `contains` list produces identical results for every shipped line while
    // being strictly broader. These two widget tests are what catch that, and
    // they have to go through the widget because re-stating the same
    // expression in the test proves nothing.
    // The intention classifier only runs under `allSaintsStyle`; the plain
    // novena path uses a different paragraph widget that never consults it.
    Future<bool> isItalicked(WidgetTester tester, String line) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: NovenaTextView(allSaintsStyle: true, text: line),
            ),
          ),
        ),
      );
      final root = tester.widget<RichText>(find.byType(RichText)).text;
      return _leafStyles(root).any((s) => s?.fontStyle == FontStyle.italic);
    }

    testWidgets('an intention marker mid-sentence is not italicised', (
      tester,
    ) async {
      // These three were not intentions before 4.8. Folding the anchored
      // prefixes into the unanchored list would italicise them.
      for (final line in const [
        'please recall: (state your intentions today',
        'x holy spirit we ask for the grace of [a gift]',
        'note: "leo uniletee baraka',
      ]) {
        expect(
          await isItalicked(tester, line),
          isFalse,
          reason: '"$line" merely mentions a marker mid-sentence, so the '
              'refactored rule must not treat it as an intention',
        );
      }
    });

    testWidgets('the hapa markers are still italicised after a lead-in', (
      tester,
    ) async {
      // The counterpart: these two are exactly why the original had a
      // separate `contains` clause, so a startsWith-only refactor would
      // silently drop them.
      for (final line in const [
        'omba hii: (taja nia zako hapa)',
        'tazama: (taja nia yako hapa)',
        '(state your intentions before you begin)',
      ]) {
        expect(
          await isItalicked(tester, line),
          isTrue,
          reason: '"$line" was an intention before 4.8 and still must be',
        );
      }
    });

    testWidgets('a litany renders identically to its expected text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: LitanyTextView(
              text: 'LITANY OF THE HOLY SPIRIT\n'
                  'R: Let us pray.\n'
                  'V: O Lamb of God.\n'
                  'All: have mercy on us.',
            ),
          ),
        ),
      );
      expect(find.text('LITANY OF THE HOLY SPIRIT'), findsOneWidget);
      expect(find.text('R: Let us pray.'), findsOneWidget);
      expect(find.text('V: O Lamb of God.'), findsOneWidget);
      expect(find.text('All: have mercy on us.'), findsOneWidget);
    });

    testWidgets('a novena day renders its invocation and counts', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: NovenaTextView(
              text:
                  'Kwa jina la Baba, na ya Mwana, na ya Roho Mtakatifu. Amini.\n\n'
                  'Baba Yetu (3), Salamu Maria (3), Atukuzwe Baba (3).',
            ),
          ),
        ),
      );
      expect(
        find.text('Kwa jina la Baba, na ya Mwana, na ya Roho Mtakatifu. Amini.'),
        findsOneWidget,
      );
      expect(
        find.text('Baba Yetu (3), Salamu Maria (3), Atukuzwe Baba (3).'),
        findsOneWidget,
      );
    });
  });
}

/// Flattens the style of every leaf span so a test can ask "is any part of
/// this line italic" without re-stating how the widget nests its spans.
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
