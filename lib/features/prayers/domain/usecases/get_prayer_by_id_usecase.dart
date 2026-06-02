import '../entities/prayer_entity.dart';
import '../../../../data/repositories/prayer_repository.dart';

class GetPrayerByIdUseCase {
  const GetPrayerByIdUseCase(this._repository);

  final PrayerRepository _repository;

  Future<PrayerEntity?> call(String id) {
    return _repository.getPrayerById(id);
  }
}
