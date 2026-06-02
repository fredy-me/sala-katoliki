class SupportedLanguage {
  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  final String code;
  final String name;
  final String nativeName;
}

abstract final class SupportedLanguages {
  static const english = SupportedLanguage(
    code: 'en',
    name: 'English',
    nativeName: 'English',
  );

  static const kiswahili = SupportedLanguage(
    code: 'sw',
    name: 'Kiswahili',
    nativeName: 'Lugha ya Kiswahili',
  );

  static const all = [english, kiswahili];

  static bool contains(String code) {
    return all.any((language) => language.code == code);
  }
}
