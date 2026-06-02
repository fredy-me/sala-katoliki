import '../datasources/local_content_datasource.dart';
import '../models/rosary_model.dart';

class RosaryRepository {
  const RosaryRepository(this._contentDataSource);

  final LocalContentDataSource _contentDataSource;

  Future<List<RosaryPrayerModel>> getRosaryPrayers({
    String languageCode = 'sw',
  }) {
    return _contentDataSource.getRosaryPrayers(languageCode: languageCode);
  }

  Future<List<RosaryMysteryModel>> getRosaryMysteries({
    String languageCode = 'sw',
  }) {
    return _contentDataSource.getRosaryMysteries(languageCode: languageCode);
  }
}
