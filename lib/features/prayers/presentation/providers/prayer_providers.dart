import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/datasources/prayer_local_datasource.dart';
import '../../../../data/datasources/local_content_datasource.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/prayer_repository.dart';
import '../../../../data/repositories/prayer_repository_impl.dart';
import '../../../../core/localization/localization_providers.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../domain/usecases/get_all_prayers_usecase.dart';
import '../../domain/usecases/get_prayer_by_id_usecase.dart';

final localContentDataSourceProvider = Provider<LocalContentDataSource>((ref) {
  return LocalContentDataSource();
});

final prayerLocalDataSourceProvider = Provider<PrayerLocalDataSource>((ref) {
  return PrayerLocalDataSource(
    contentDataSource: ref.watch(localContentDataSourceProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(localContentDataSourceProvider));
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories();
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
  final languageCode = ref.watch(activeLanguageProvider);
  return ref
      .watch(getAllPrayersUseCaseProvider)
      .call(languageCode: languageCode);
});

final prayerByIdProvider = FutureProvider.family<PrayerEntity?, String>((
  ref,
  id,
) {
  final languageCode = ref.watch(activeLanguageProvider);
  return ref
      .watch(getPrayerByIdUseCaseProvider)
      .call(id, languageCode: languageCode);
});

final favoritePrayerIdsProvider =
    AsyncNotifierProvider<FavoritePrayerIdsNotifier, Set<String>>(
      FavoritePrayerIdsNotifier.new,
    );

final recentPrayerIdsProvider =
    AsyncNotifierProvider<RecentPrayerIdsNotifier, List<String>>(
      RecentPrayerIdsNotifier.new,
    );

class FavoritePrayerIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences
            .getStringList(StorageKeys.favoritePrayerIds)
            ?.where((id) => id.trim().isNotEmpty)
            .toSet() ??
        <String>{};
  }

  Future<void> toggle(String prayerId) async {
    final current = state.asData?.value ?? await future;
    final updated = Set<String>.from(current);

    if (updated.contains(prayerId)) {
      updated.remove(prayerId);
    } else {
      updated.add(prayerId);
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      StorageKeys.favoritePrayerIds,
      updated.toList()..sort(),
    );
    state = AsyncData(updated);
  }

  Future<void> remove(String prayerId) async {
    final current = state.asData?.value ?? await future;
    if (!current.contains(prayerId)) {
      return;
    }

    final updated = Set<String>.from(current)..remove(prayerId);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      StorageKeys.favoritePrayerIds,
      updated.toList()..sort(),
    );
    state = AsyncData(updated);
  }
}

class RecentPrayerIdsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(StorageKeys.recentPrayerIds) ?? const [];
  }

  Future<void> record(String prayerId) async {
    final current = state.asData?.value ?? const <String>[];
    final updated = [
      prayerId,
      ...current.where((id) => id != prayerId),
    ].take(10).toList(growable: false);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(StorageKeys.recentPrayerIds, updated);
    state = AsyncData(updated);
  }
}
