import '../../features/prayers/domain/entities/prayer_entity.dart';

abstract interface class PrayerRepository {
  Future<List<PrayerEntity>> getPrayers({String languageCode = 'sw'});

  Future<PrayerEntity?> getPrayerById(String id, {String languageCode = 'sw'});
}
