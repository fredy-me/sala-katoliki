import '../models/prayer_model.dart';
import 'local_content_datasource.dart';

class PrayerLocalDataSource {
  PrayerLocalDataSource({LocalContentDataSource? contentDataSource})
    : _contentDataSource = contentDataSource ?? LocalContentDataSource();

  final LocalContentDataSource _contentDataSource;

  Future<List<PrayerModel>> getPrayers({String languageCode = 'sw'}) {
    return _contentDataSource.getPrayers(languageCode: languageCode);
  }
}
