class UserPreferencesModel {
  const UserPreferencesModel({
    required this.selectedLanguage,
    this.fontSize = 1,
    this.themeMode = 'system',
    this.reminderEnabled = false,
    this.reminderTime,
  });

  final String selectedLanguage;
  final double fontSize;
  final String themeMode;
  final bool reminderEnabled;
  final String? reminderTime;
}
