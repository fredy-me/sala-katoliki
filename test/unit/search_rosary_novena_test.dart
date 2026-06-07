import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salakatoliki/data/models/novena_model.dart';
import 'package:salakatoliki/data/models/rosary_model.dart';
import 'package:salakatoliki/features/novenas/domain/novena_state.dart';
import 'package:salakatoliki/features/prayers/domain/entities/prayer_entity.dart';
import 'package:salakatoliki/features/prayers/presentation/providers/prayer_providers.dart';
import 'package:salakatoliki/features/rosary/presentation/providers/rosary_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('offline prayer search matches title, body, tags, and category', () {
    const prayer = PrayerEntity(
      id: 'hail_mary',
      type: 'prayer',
      categoryId: 'marian_prayers',
      language: 'en',
      localizedTitle: 'Hail Mary',
      body: 'Full of grace',
      categoryTitles: {'en': 'Marian Prayers'},
      tags: ['rosary', 'mary'],
    );

    expect(prayer.matches('hail'), isTrue);
    expect(prayer.matches('grace'), isTrue);
    expect(prayer.matches('rosary'), isTrue);
    expect(prayer.matches('marian'), isTrue);
    expect(prayer.matches('unknown'), isFalse);
  });

  test(
    'rosary step provider expands repeat counts into guided steps',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        overrides: [
          rosaryMysteriesProvider.overrideWith(
            (ref) async => const [
              RosaryMysteryModel(
                id: 'joyful_mysteries',
                language: 'en',
                title: 'Joyful Mysteries',
                description: 'Joyful events',
                days: ['monday'],
                mysteries: [
                  'Annunciation',
                  'Visitation',
                  'Nativity',
                  'Presentation',
                  'Finding in the Temple',
                ],
                virtues: [
                  'Humility',
                  'Love of neighbor',
                  'Poverty of spirit',
                  'Purity',
                  'Obedience',
                ],
              ),
            ],
          ),
          rosaryPrayerSequenceProvider.overrideWith(
            (ref) async => const [
              RosaryPrayerModel(
                id: 'apostles_creed',
                prayerId: 'apostles_creed',
                repeatCount: 1,
              ),
              RosaryPrayerModel(
                id: 'our_father',
                prayerId: 'our_father',
                repeatCount: 1,
              ),
              RosaryPrayerModel(
                id: 'hail_mary',
                prayerId: 'hail_mary',
                repeatCount: 10,
              ),
              RosaryPrayerModel(
                id: 'glory_be',
                prayerId: 'glory_be',
                repeatCount: 1,
              ),
              RosaryPrayerModel(
                id: 'bikira_maria_litany',
                prayerId: 'bikira_maria_litany',
                repeatCount: 1,
              ),
            ],
          ),
          prayersProvider.overrideWith(
            (ref) async => const [
              PrayerEntity(
                id: 'apostles_creed',
                type: 'prayer',
                categoryId: 'mass_prayers',
                language: 'en',
                localizedTitle: "The Apostles' Creed",
                body: 'I believe in God.',
                categoryTitles: {'en': 'Mass Prayers'},
              ),
              PrayerEntity(
                id: 'hail_mary',
                type: 'prayer',
                categoryId: 'marian_prayers',
                language: 'en',
                localizedTitle: 'Hail Mary',
                body: 'Hail Mary.',
                categoryTitles: {'en': 'Marian Prayers'},
              ),
              PrayerEntity(
                id: 'our_father',
                type: 'prayer',
                categoryId: 'common_prayers',
                language: 'en',
                localizedTitle: 'Our Father',
                body: 'Our Father.',
                categoryTitles: {'en': 'Common Prayers'},
              ),
              PrayerEntity(
                id: 'glory_be',
                type: 'prayer',
                categoryId: 'common_prayers',
                language: 'en',
                localizedTitle: 'Glory Be',
                body: 'Glory be.',
                categoryTitles: {'en': 'Common Prayers'},
              ),
              PrayerEntity(
                id: 'bikira_maria_litany',
                type: 'prayer',
                categoryId: 'litanies',
                language: 'en',
                localizedTitle: 'Litany of Mary',
                body: 'Holy Mary, pray for us.',
                categoryTitles: {'en': 'Litanies'},
              ),
            ],
          ),
        ],
      );

      final steps = await container.read(
        rosaryStepsProvider('joyful_mysteries').future,
      );

      expect(steps, hasLength(67));
      expect(steps.first.isIntro, isTrue);
      expect(steps[6].mysteryTitle, 'Annunciation');
      expect(steps[6].mysteryVirtue, 'Humility');
      expect(steps.last.prayer.id, 'bikira_maria_litany');
      container.dispose();
    },
  );

  test(
    'novena session exposes completed, current, open, and locked states',
    () {
      final progress = NovenaProgress(
        activeNovenaId: 'divine_mercy_novena',
        completedDays: {1, 2},
      );
      final session = NovenaSession(novena: _testNovena, progress: progress);

      expect(session.statusForDay(1), NovenaDayStatus.completed);
      expect(session.statusForDay(3), NovenaDayStatus.current);
      expect(session.statusForDay(2), NovenaDayStatus.completed);
      expect(session.statusForDay(4), NovenaDayStatus.locked);
      expect(session.canOpenDay(3), isTrue);
      expect(session.canOpenDay(4), isFalse);
    },
  );
}

const _testNovena = NovenaModel(
  id: 'divine_mercy_novena',
  language: 'en',
  title: 'Divine Mercy Novena',
  description: 'A nine-day devotion',
  days: [
    NovenaDayModel(day: 1, title: 'Day 1', body: 'Day one'),
    NovenaDayModel(day: 2, title: 'Day 2', body: 'Day two'),
    NovenaDayModel(day: 3, title: 'Day 3', body: 'Day three'),
    NovenaDayModel(day: 4, title: 'Day 4', body: 'Day four'),
    NovenaDayModel(day: 5, title: 'Day 5', body: 'Day five'),
    NovenaDayModel(day: 6, title: 'Day 6', body: 'Day six'),
    NovenaDayModel(day: 7, title: 'Day 7', body: 'Day seven'),
    NovenaDayModel(day: 8, title: 'Day 8', body: 'Day eight'),
    NovenaDayModel(day: 9, title: 'Day 9', body: 'Day nine'),
  ],
);
