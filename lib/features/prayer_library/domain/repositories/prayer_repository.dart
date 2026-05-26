import '../entities/prayer_entity.dart';

abstract interface class PrayerRepository {
  Future<List<PrayerEntity>> getPrayers();

  Future<PrayerEntity?> getPrayerById(String id);
}
