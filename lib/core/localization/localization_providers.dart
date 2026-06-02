import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../constants/storage_keys.dart';
import 'supported_languages.dart';

final selectedLanguageProvider =
    AsyncNotifierProvider<SelectedLanguageNotifier, String?>(
      SelectedLanguageNotifier.new,
    );

final activeLanguageProvider = Provider<String>((ref) {
  return ref.watch(selectedLanguageProvider).asData?.value ??
      AppConstants.defaultLanguageCode;
});

class SelectedLanguageNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(StorageKeys.selectedLanguage);

    if (languageCode == null || !SupportedLanguages.contains(languageCode)) {
      return null;
    }

    return languageCode;
  }

  Future<void> selectLanguage(String languageCode) async {
    if (!SupportedLanguages.contains(languageCode)) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(StorageKeys.selectedLanguage, languageCode);
    state = AsyncData(languageCode);
  }

  Future<void> clearLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(StorageKeys.selectedLanguage);
    state = const AsyncData(null);
  }
}
