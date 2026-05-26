import '../../domain/entities/prayer_entity.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_local_datasource.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  const PrayerRepositoryImpl(this._localDataSource);

  final PrayerLocalDataSource _localDataSource;

  @override
  Future<List<PrayerEntity>> getPrayers() {
    return _localDataSource.getPrayers();
  }

  @override
  Future<PrayerEntity?> getPrayerById(String id) async {
    final prayers = await getPrayers();

    for (final prayer in prayers) {
      if (prayer.id == id) {
        return prayer;
      }
    }

    return null;
  }
}
