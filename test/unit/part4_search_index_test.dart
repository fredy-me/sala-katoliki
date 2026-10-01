import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/localization/localization_providers.dart';
import 'package:salakatoliki/core/theme/app_theme.dart';
import 'package:salakatoliki/data/datasources/local_content_datasource.dart';
import 'package:salakatoliki/data/datasources/prayer_local_datasource.dart';
import 'package:salakatoliki/data/repositories/prayer_repository_impl.dart';
import 'package:salakatoliki/features/prayers/domain/entities/prayer_entity.dart';
import 'package:salakatoliki/features/prayers/presentation/screens/prayer_library_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_asset_bundle.dart';

/// A reference implementation of the pre-4.7 scoring, kept verbatim so the
/// optimized version can be checked against it. If these two ever disagree, the
/// search results changed, which 4.7 explicitly forbids.
int referenceScore(PrayerEntity p, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return 1;
  }

  final titleLower = p.title().toLowerCase();
  final categoryLower = p.categoryLabel().toLowerCase();
  final bodyLower = p.text().toLowerCase();

  if (titleLower == normalized) return 100;
  if (titleLower.startsWith(normalized)) return 90;
  if (titleLower.contains(normalized)) return 80;

  for (final tag in p.tags) {
    final tagLower = tag.toLowerCase();
    if (tagLower == normalized) return 70;
    if (tagLower.startsWith(normalized)) return 60;
    if (tagLower.contains(normalized)) return 50;
  }

  if (categoryLower == normalized) return 45;
  if (categoryLower.contains(normalized)) return 40;

  if (normalized.length >= 3 && bodyLower.contains(normalized)) {
    return 30;
  }

  return 0;
}

bool referenceMatches(PrayerEntity p, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return true;
  }
  return p.title().toLowerCase().contains(normalized) ||
      p.categoryLabel().toLowerCase().contains(normalized) ||
      p.text().toLowerCase().contains(normalized) ||
      p.tags.any((tag) => tag.toLowerCase().contains(normalized));
}

List<String> orderedIds(List<PrayerEntity> prayers, String query) {
  final scored = prayers
      .map((p) => (prayer: p, score: p.score(query)))
      .where((r) => r.score > 0)
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  return scored.map((r) => r.prayer.id).toList();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('4.7 search index preserves results exactly', () {
    late List<PrayerEntity> prayers;

    setUpAll(() async {
      prayers = await PrayerRepositoryImpl(
        PrayerLocalDataSource(contentDataSource: LocalContentDataSource()),
      ).getPrayers(languageCode: 'en');
      expect(prayers, isNotEmpty, reason: 'the corpus must load for the test');
    });

    const queries = <String>[
      '',
      '   ',
      'a',
      'ab',
      'our',
      'father',
      'our father',
      'OUR FATHER',
      '  Our Father  ',
      'baba yetu',
      'baba',
      'kiitikio',
      'response',
      'litany',
      'marian',
      'hymn',
      'grace',
      'morning',
      'evening',
      'xyzzy-no-such-prayer',
      'jesus',
      'mary',
      'saint',
      'st.',
      'st rita',
      'rita',
      'charity',
      'peace',
      'trust',
      'a+',
      'k.',
      'v:',
    ];

    test('score() matches the reference for every query, every prayer', () {
      for (final query in queries) {
        for (final prayer in prayers) {
          expect(
            prayer.score(query),
            referenceScore(prayer, query),
            reason: 'score mismatch for "$query" on ${prayer.id}',
          );
        }
      }
    });

    test('matches() matches the reference for every query, every prayer', () {
      for (final query in queries) {
        for (final prayer in prayers) {
          expect(
            prayer.matches(query),
            referenceMatches(prayer, query),
            reason: 'matches mismatch for "$query" on ${prayer.id}',
          );
        }
      }
    });

    test('result order is identical to the reference ordering', () {
      for (final query in queries) {
        final ranked =
            prayers
                .map((p) => (prayer: p, score: referenceScore(p, query)))
                .where((r) => r.score > 0)
                .toList()
              ..sort((a, b) => b.score.compareTo(a.score));
        final expected = ranked.map((r) => r.prayer.id).toList();
        expect(
          orderedIds(prayers, query),
          expected,
          reason: 'result order changed for "$query"',
        );
      }
    });

    // The reference comparison above proves the index did not change
    // `score`, but both sides of it use the same sort, so it cannot catch a
    // change to the ordering itself. These goldens pin the literal ID order
    // that shipped before 4.7. The ties are real (many litanies match
    // "litany" equally), so this also documents that equal scores fall back
    // to the corpus order.
    const goldens = <String, List<String>>{
      'our father': [
        'our_father',
        'morning_prayer',
        'commandments_of_god',
        'evening_prayer',
        'holy_angels_litany',
        'souls_in_purgatory_litany',
      ],
      'st rita': ['st_rita_litany'],
      'litany': [
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
        'st_anne_litany',
        'holy_angels_litany',
        'sacred_heart_of_jesus_litany',
        'holy_face_of_jesus_litany',
        'souls_in_purgatory_litany',
        'seven_sorrows_mary_litany',
        'litany_of_reparation',
        'franciscan_st_anthony_litany',
      ],
      'jesus': [
        'sacred_head_of_jesus_litany',
        'sacred_heart_of_jesus_litany',
        'holy_face_of_jesus_litany',
        'divine_mercy_litany',
        'prayer_to_st_joseph',
        'hail_holy_queen',
        'morning_prayer',
        'evening_prayer',
        'prayer_to_st_joseph_pilgrim_church',
        'act_of_entrustment_to_st_joseph',
        'hail_mary',
        'st_rita_litany',
        'holy_spirit_litany',
        'st_aloysius_gonzaga_litany',
        'st_jude_thaddeus_litany',
        'franciscan_st_anthony_litany',
        'st_anne_litany',
        'holy_angels_litany',
        'souls_in_purgatory_litany',
        'litany_of_reparation',
        'apostles_creed',
        'divine_mercy_eternal_father',
        'divine_mercy_small_bead_prayer',
      ],
    };

    for (final entry in goldens.entries) {
      test('the ordered IDs for "${entry.key}" are unchanged', () {
        expect(
          orderedIds(prayers, entry.key),
          entry.value,
          reason:
              'the result order for "${entry.key}" changed; the index is '
              'supposed to be a pure performance change',
        );
      });
    }

    for (final query in const ['a+', 'k.', 'baba', 'xyzzy-no-such-prayer']) {
      test('"$query" still returns nothing rather than everything', () {
        expect(
          orderedIds(prayers, query),
          isEmpty,
          reason: 'punctuation and unknown terms must not match',
        );
      });
    }

    test('scoring is stable across repeated calls (the memo is reused)', () {
      for (final prayer in prayers) {
        final first = prayer.score('father');
        final second = prayer.score('father');
        final third = prayer.score('mary');
        expect(second, first);
        expect(third, prayer.score('mary'));
      }
    });

    test('per-language indexes do not leak into each other', () {
      final entity = prayers.first;
      final enScore = entity.score('father', 'en');
      final enAgain = entity.score('father', 'en');
      entity.score('baba', 'sw');
      expect(entity.score('father', 'en'), enScore);
      expect(entity.score('father', 'en'), enAgain);
    });
  });

  group('4.7 debounce', () {
    // The library screen is a bare scroll view; the app supplies the Scaffold.
    Future<void> pumpLibrary(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeLanguageProvider.overrideWithValue('sw'),
            localContentDataSourceProvider.overrideWithValue(
              testContentDataSource(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: PrayerLibraryScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('results are not recomputed until typing settles', (
      tester,
    ) async {
      await pumpLibrary(tester);
      expect(find.text('SALA MUHIMU'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'baba yetu');
      await tester.pump();

      expect(
        find.text('baba yetu'),
        findsOneWidget,
        reason: 'the field itself must stay responsive immediately',
      );
      expect(
        find.text('SALA MUHIMU'),
        findsOneWidget,
        reason: 'the category grid must still be showing inside the window',
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.text('SALA MUHIMU'),
        findsOneWidget,
        reason: 'still inside the 250 ms debounce window',
      );

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(
        find.text('SALA MUHIMU'),
        findsNothing,
        reason: 'the grid is replaced once the debounce elapses',
      );
      expect(find.text('Baba Yetu'), findsWidgets);
    });

    testWidgets('clearing the query restores the category grid', (
      tester,
    ) async {
      await pumpLibrary(tester);
      expect(find.text('SALA MUHIMU'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'baba');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Baba Yetu'), findsWidgets);

      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('SALA MUHIMU'), findsOneWidget);
    });

    testWidgets('a pending timer is cancelled on dispose, not fired', (
      tester,
    ) async {
      await pumpLibrary(tester);
      await tester.enterText(find.byType(TextField).first, 'baba');
      await tester.pump();
      // Replace the tree before the debounce elapses; a surviving timer would
      // call setState on a disposed State.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  });
}
