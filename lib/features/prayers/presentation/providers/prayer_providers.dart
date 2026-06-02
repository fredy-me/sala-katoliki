import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/datasources/prayer_local_datasource.dart';
import '../../../../data/repositories/prayer_repository.dart';
import '../../../../data/repositories/prayer_repository_impl.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../domain/usecases/get_all_prayers_usecase.dart';
import '../../domain/usecases/get_prayer_by_id_usecase.dart';

final prayerLocalDataSourceProvider = Provider<PrayerLocalDataSource>((ref) {
  return PrayerLocalDataSource();
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

final prayerByIdProvider = FutureProvider.family<PrayerEntity?, String>((
  ref,
  id,
) {
  return ref.watch(getPrayerByIdUseCaseProvider).call(id);
});

final favoritePrayerIdsProvider =
    NotifierProvider<FavoritePrayerIdsNotifier, Set<String>>(
      FavoritePrayerIdsNotifier.new,
    );

class FavoritePrayerIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {'hail-mary'};
  }

  void toggle(String prayerId) {
    if (state.contains(prayerId)) {
      state = Set<String>.from(state)..remove(prayerId);
      return;
    }

    state = {...state, prayerId};
  }
}
