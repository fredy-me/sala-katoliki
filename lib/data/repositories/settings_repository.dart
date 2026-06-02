import '../models/user_preferences_model.dart';

class SettingsRepository {
  const SettingsRepository();

  Future<UserPreferencesModel> getDefaults() async {
    return const UserPreferencesModel(selectedLanguage: 'sw');
  }
}
