import '../datasources/prayer_local_datasource.dart';
import '../../features/prayers/domain/entities/prayer_entity.dart';
import 'prayer_repository.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  PrayerRepositoryImpl(this._localDataSource);

  final PrayerLocalDataSource _localDataSource;
  final Map<String, Future<Map<String, PrayerEntity>>> _prayerIndexes = {};

  @override
  Future<List<PrayerEntity>> getPrayers({String languageCode = 'sw'}) {
    return _localDataSource.getPrayers(languageCode: languageCode);
  }

  @override
  Future<PrayerEntity?> getPrayerById(
    String id, {
    String languageCode = 'sw',
  }) async {
    final index = await prayerIndex(languageCode: languageCode);
    return index[id];
  }

  /// Maps every prayer id to its entity, decoding the corpus once per language.
  ///
  /// The caller used to reload and re-parse the whole corpus on every single
  /// prayer open, just to find one entry by id.
  Future<Map<String, PrayerEntity>> prayerIndex({
    String languageCode = 'sw',
  }) async {
    return _prayerIndexes[languageCode] ??= _buildPrayerIndex(languageCode);
  }

  Future<Map<String, PrayerEntity>> _buildPrayerIndex(String languageCode) async {
    final prayers = await getPrayers(languageCode: languageCode);
    return {for (final prayer in prayers) prayer.id: prayer};
  }
}
