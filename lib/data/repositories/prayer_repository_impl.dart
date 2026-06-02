import '../datasources/prayer_local_datasource.dart';
import '../../features/prayers/domain/entities/prayer_entity.dart';
import 'prayer_repository.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  const PrayerRepositoryImpl(this._localDataSource);

  final PrayerLocalDataSource _localDataSource;

  @override
  Future<List<PrayerEntity>> getPrayers({String languageCode = 'sw'}) {
    return _localDataSource.getPrayers(languageCode: languageCode);
  }

  @override
  Future<PrayerEntity?> getPrayerById(
    String id, {
    String languageCode = 'sw',
  }) async {
    final prayers = await getPrayers(languageCode: languageCode);

    for (final prayer in prayers) {
      if (prayer.id == id) {
        return prayer;
      }
    }

    return null;
  }
}
