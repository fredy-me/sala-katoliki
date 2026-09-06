import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/data/models/novena_model.dart';
import 'package:salakatoliki/data/models/rosary_model.dart';
import 'package:salakatoliki/features/prayers/domain/entities/prayer_entity.dart';
import 'package:salakatoliki/shared/services/deep_link_service.dart';

void main() {
  group('DeepLinkService.slugify', () {
    test('matches the APP_INDEXES.md slug style', () {
      expect(DeepLinkService.slugify('Baba Yetu'), 'baba-yetu');
      expect(DeepLinkService.slugify('Atukuzwe Baba'), 'atukuzwe-baba');
      expect(
        DeepLinkService.slugify('Litania ya Mtakatifu Antoni wa Padua, Toleo la 1'),
        'litania-ya-mtakatifu-antoni-wa-padua-toleo-la-1',
      );
      expect(
        DeepLinkService.slugify('Novena ya Mt. Rita wa Kashia'),
        'novena-ya-mt-rita-wa-kashia',
      );
      expect(DeepLinkService.slugify('Salamu Malkia'), 'salamu-malkia');
    });
  });

  group('DeepLinkService.resolve with English active language', () {
    late DeepLinkService service;

    setUp(() {
      service = DeepLinkService(
        prayerIndex: _swPrayers,
        activePrayers: _enPrayers,
        novenas: _novenas,
        mysteries: _mysteries,
      );
    });

    test('rejects empty, malformed, and foreign-host links', () {
      expect(service.resolve(''), isNull);
      expect(service.resolve('   '), isNull);
      expect(service.resolve('not-a-url'), isNull);
      expect(
        service.resolve(
          'https://evil.com/salakatoliki/prayers/common/baba-yetu',
        ),
        isNull,
      );
    });

    test('home', () {
      expect(service.resolve('https://busaradigital.com/salakatoliki/'), '/today');
      expect(service.resolve('https://busaradigital.com/salakatoliki'), '/today');
    });

    test('prayer slug links from APP_INDEXES.md', () {
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/common/baba-yetu',
        ),
        '/prayers/our_father',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/marian/salamu-maria',
        ),
        '/prayers/hail_mary',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/litanies/litania-ya-mtakatifu-rita',
        ),
        '/prayers/st_rita_litany',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/mass/kanuni-ya-imani',
        ),
        '/prayers/apostles_creed',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/divine-mercy/kwa-ajili-ya-mateso-makali',
        ),
        '/prayers/divine_mercy_small_bead_prayer',
      );
    });

    test('category index links', () {
      expect(
        service.resolve('https://busaradigital.com/salakatoliki/prayers/litanies'),
        '/prayers/category/litanies',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/divine-mercy',
        ),
        '/prayers/category/divine_mercy',
      );
    });

    test('divine mercy EN/SW mismatch resolves to the EN id', () {
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/divine-mercy/baba-wa-milele',
        ),
        '/prayers/divine_mercy_eternal_father',
      );
    });

    test('novena detail, day, closing, and thanksgiving slug links', () {
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mt-rita-wa-kashia',
        ),
        '/novenas/st_rita_novena',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mt-rita-wa-kashia/day/12',
        ),
        '/novenas/st_rita_novena/day/12',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-huruma-ya-mungu/closing-prayer',
        ),
        '/novenas/divine_mercy_novena/closing-prayer',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-huruma-ya-mungu/thanksgiving',
        ),
        '/novenas/divine_mercy_novena/thanksgiving',
      );
    });

    test('respects the St. Rita 12-day exception', () {
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mt-rita-wa-kashia/day/12',
        ),
        '/novenas/st_rita_novena/day/12',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-mt-rita-wa-kashia/day/13',
        ),
        isNull,
      );
    });

    test('rejects out-of-range novena day and unknown slugs', () {
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/novena/novena-ya-huruma-ya-mungu/day/10',
        ),
        isNull,
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/common/hakuna-sala',
        ),
        isNull,
      );
    });

    test('rosary slug links', () {
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/rosary/matendo-ya-furaha',
        ),
        '/rosary/step/joyful_mysteries',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/rosary/rozari-ya-huruma-ya-mungu',
        ),
        '/rosary/step/divine_mercy_rosary',
      );
      expect(
        service.resolve('https://busaradigital.com/salakatoliki/prayers/rosary'),
        '/rosary',
      );
    });

    test('direct raw-id links still work', () {
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/novenas/st_rita_novena/day/3',
        ),
        '/novenas/st_rita_novena/day/3',
      );
      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/category/litanies',
        ),
        '/prayers/category/litanies',
      );
    });
  });

  group('DeepLinkService.resolve with Swahili active language', () {
    test('divine mercy slug resolves to the sw id', () {
      final service = DeepLinkService(
        prayerIndex: _swPrayers,
        activePrayers: _swPrayers,
        novenas: _novenas,
        mysteries: _mysteries,
      );

      expect(
        service.resolve(
          'https://busaradigital.com/salakatoliki/prayers/divine-mercy/baba-wa-milele',
        ),
        '/prayers/divine_mercy_prayer',
      );
    });
  });
}

final _enPrayers = [
  _prayer(
    id: 'our_father',
    categoryId: 'common_prayers',
    title: 'Our Father',
  ),
  _prayer(
    id: 'hail_mary',
    categoryId: 'marian_prayers',
    title: 'Hail Mary',
  ),
  _prayer(
    id: 'st_rita_litany',
    categoryId: 'litanies',
    title: 'Litany of St. Rita',
  ),
  _prayer(
    id: 'apostles_creed',
    categoryId: 'mass_prayers',
    title: 'The Apostles\' Creed',
  ),
  _prayer(
    id: 'divine_mercy_eternal_father',
    categoryId: 'divine_mercy',
    title: 'Eternal Father',
  ),
];

final _swPrayers = [
  _prayer(
    id: 'our_father',
    categoryId: 'common_prayers',
    title: 'Baba Yetu',
  ),
  _prayer(
    id: 'hail_mary',
    categoryId: 'marian_prayers',
    title: 'Salamu Maria',
  ),
  _prayer(
    id: 'st_rita_litany',
    categoryId: 'litanies',
    title: 'Litania ya Mtakatifu Rita',
  ),
  _prayer(
    id: 'apostles_creed',
    categoryId: 'mass_prayers',
    title: 'Kanuni ya Imani',
  ),
  _prayer(
    id: 'divine_mercy_prayer',
    categoryId: 'divine_mercy',
    title: 'Baba wa Milele',
  ),
  _prayer(
    id: 'divine_mercy_small_bead_prayer',
    categoryId: 'divine_mercy',
    title: 'Kwa Ajili ya Mateso Makali',
  ),
];

final _novenas = [
  _novena('st_rita_novena', 'Novena ya Mt. Rita wa Kashia', 12),
  _novena('divine_mercy_novena', 'Novena ya Huruma ya Mungu', 9),
];

final _mysteries = [
  _mystery('divine_mercy_rosary', 'Rozari ya Huruma ya Mungu'),
  _mystery('joyful_mysteries', 'Matendo ya Furaha'),
];

PrayerEntity _prayer({
  required String id,
  required String categoryId,
  required String title,
}) {
  return PrayerEntity(
    id: id,
    type: 'prayer',
    categoryId: categoryId,
    language: 'sw',
    localizedTitle: title,
    body: '...',
    categoryTitles: const {'en': 'x', 'sw': 'y'},
  );
}

NovenaModel _novena(String id, String title, int dayCount) {
  return NovenaModel(
    id: id,
    language: 'sw',
    title: title,
    description: 'description',
    days: [
      for (var day = 1; day <= dayCount; day += 1)
        NovenaDayModel(day: day, title: 'Day $day', body: 'Body'),
    ],
    closingPrayer: NovenaClosingPrayerModel(
      title: 'Closing',
      description: 'Closing',
      body: 'Body',
    ),
    thanksgivingSection: NovenaThanksgivingSectionModel(
      afterDay: dayCount,
      title: 'Thanksgiving',
      description: 'Thanksgiving',
      body: 'Body',
    ),
  );
}

RosaryMysteryModel _mystery(String id, String title) {
  return RosaryMysteryModel(
    id: id,
    language: 'sw',
    title: title,
    description: 'description',
    days: const [],
    mysteries: const ['First Mystery'],
  );
}