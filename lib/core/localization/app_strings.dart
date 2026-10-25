part 'app_strings.g.dart';

/// The single synchronous message API for screens, reminders, and widgets.
/// Catalogs are validated and compiled by tool/generate_localizations.dart.
class AppStrings with _AppMessages {
  const AppStrings(this.languageCode);

  final String languageCode;
  static final _instances = <String, AppStrings>{
    for (final locale in _catalogMessages.keys) locale: AppStrings(locale),
  };
  static final _placeholder = RegExp(r'\{([a-zA-Z][a-zA-Z0-9]*)\}');

  static Iterable<String> get availableLanguages => _catalogMessages.keys;

  static AppStrings of(String languageCode) =>
      _instances[languageCode] ?? _instances['en']!;

  @override
  String _message(String key, Map<String, Object> parameters) {
    final catalog = _catalogMessages[languageCode] ?? _catalogMessages['en']!;
    final value = catalog[key] ?? _catalogMessages['en']![key]!;
    final String template;
    if (value is String) {
      template = value;
    } else {
      final variants = value as Map<String, dynamic>;
      if (variants.containsKey('plural')) {
        final count = parameters[variants['plural']];
        template = variants[count == 1 ? 'one' : 'other'] as String;
      } else {
        final cases = variants['cases'] as Map<String, dynamic>;
        template =
            (cases[parameters[variants['select']]] ?? cases['other']) as String;
      }
    }
    // Substitute once: an argument containing another placeholder stays literal.
    return template.replaceAllMapped(
      _placeholder,
      (match) => parameters[match.group(1)]!.toString(),
    );
  }
}
