import '../entities/prayer_entity.dart';
import '../../../../data/repositories/prayer_repository.dart';

class GetAllPrayersUseCase {
  const GetAllPrayersUseCase(this._repository);

  final PrayerRepository _repository;

  Future<List<PrayerEntity>> call({String languageCode = 'sw'}) {
    return _repository.getPrayers(languageCode: languageCode);
  }
}
