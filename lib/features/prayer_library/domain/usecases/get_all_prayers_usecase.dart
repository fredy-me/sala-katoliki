import '../entities/prayer_entity.dart';
import '../repositories/prayer_repository.dart';

class GetAllPrayersUseCase {
  const GetAllPrayersUseCase(this._repository);

  final PrayerRepository _repository;

  Future<List<PrayerEntity>> call() {
    return _repository.getPrayers();
  }
}
