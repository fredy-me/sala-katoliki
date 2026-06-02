import '../datasources/local_content_datasource.dart';
import '../models/novena_model.dart';

class NovenaRepository {
  const NovenaRepository(this._contentDataSource);

  final LocalContentDataSource _contentDataSource;

  Future<List<NovenaModel>> getNovenas({String languageCode = 'sw'}) {
    return _contentDataSource.getNovenas(languageCode: languageCode);
  }
}
