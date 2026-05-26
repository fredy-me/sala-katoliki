import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/prayer_local_datasource.dart';
import '../../data/repositories/prayer_repository_impl.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../../domain/usecases/get_all_prayers_usecase.dart';
import '../../domain/usecases/get_prayer_by_id_usecase.dart';

final prayerLocalDataSourceProvider = Provider<PrayerLocalDataSource>((ref) {
  return const PrayerLocalDataSource();
});

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepositoryImpl(ref.watch(prayerLocalDataSourceProvider));
});

final getAllPrayersUseCaseProvider = Provider<GetAllPrayersUseCase>((ref) {
  return GetAllPrayersUseCase(ref.watch(prayerRepositoryProvider));
});

final getPrayerByIdUseCaseProvider = Provider<GetPrayerByIdUseCase>((ref) {
  return GetPrayerByIdUseCase(ref.watch(prayerRepositoryProvider));
});

final prayersProvider = FutureProvider<List<PrayerEntity>>((ref) {
  return ref.watch(getAllPrayersUseCaseProvider).call();
});

final prayerByIdProvider =
    FutureProvider.family<PrayerEntity?, String>((ref, id) {
  return ref.watch(getPrayerByIdUseCaseProvider).call(id);
});

final favoritePrayerIdsProvider = StateProvider<Set<String>>((ref) {
  return {'hail-mary'};
});
