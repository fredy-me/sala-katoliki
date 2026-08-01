import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/features/prayers/domain/entities/prayer_entity.dart';

void main() {
  group('dailyPrayerFor', () {
    const prayers = [
      PrayerEntity(
        id: 'our_father',
        type: 'prayer',
        categoryId: 'common_prayers',
        language: 'en',
        localizedTitle: 'Our Father',
        body: 'Our Father, who art in heaven.',
        categoryTitles: {'en': 'Common Prayers'},
      ),
      PrayerEntity(
        id: 'glory_be',
        type: 'prayer',
        categoryId: 'common_prayers',
        language: 'en',
        localizedTitle: 'Glory Be',
        body: 'Glory be to the Father.',
        categoryTitles: {'en': 'Common Prayers'},
      ),
    ];

    test('returns null for an empty list', () {
      expect(dailyPrayerFor(const []), isNull);
    });

    test('rotates deterministically by day of month', () {
      final expected = prayers[DateTime.now().day % prayers.length];
      expect(dailyPrayerFor(prayers), same(expected));
      expect(dailyPrayerFor(prayers), same(expected));
    });

    test('returns a member of the given list', () {
      final selected = dailyPrayerFor(prayers);
      expect(prayers, contains(selected));
    });
  });
}
