import 'dart:convert';
import 'dart:io';

const catalogDirectory = 'lib/core/localization/catalogs';
const generatedPath = 'lib/core/localization/app_strings.g.dart';
final _keyPattern = RegExp(r'^[a-z][a-zA-Z0-9]*\.[a-z][a-zA-Z0-9]*$');
final _parameterPattern = RegExp(r'^[a-z][a-zA-Z0-9]*$');
final _placeholderPattern = RegExp(r'\{([a-zA-Z][a-zA-Z0-9]*)\}');

void main(List<String> args) {
  try {
    final generated = generateLocalizations(Directory(catalogDirectory));
    final output = File(generatedPath);
    if (args.contains('--check')) {
      if (!output.existsSync() || output.readAsStringSync() != generated) {
        throw const FormatException(
          'Generated localizations are stale. Run: dart run tool/generate_localizations.dart',
        );
      }
      stdout.writeln('Localization catalogs and generated messages match.');
    } else {
      output.writeAsStringSync(generated);
      stdout.writeln('Generated $generatedPath.');
    }
  } on FormatException catch (error) {
    stderr.writeln('Localization validation failed: ${error.message}');
    exitCode = 1;
  }
}

/// Shared by the command and tests; never loads Flutter or adds startup I/O.
String generateLocalizations(Directory directory) {
  final files =
      directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final catalogs = <String, Map<String, dynamic>>{};
  for (final file in files) {
    final decoded = jsonDecode(file.readAsStringSync());
    final locale = file.uri.pathSegments.last.replaceFirst(
      RegExp(r'\.json$'),
      '',
    );
    if (decoded is! Map<String, dynamic> ||
        decoded['locale'] != locale ||
        !RegExp(r'^[a-z]{2}(?:_[A-Z]{2})?$').hasMatch(locale)) {
      throw FormatException('Invalid locale/catalog in ${file.path}');
    }
    final messages = decoded['messages'];
    if (messages is! Map<String, dynamic> || messages.isEmpty) {
      throw FormatException('$locale must contain messages');
    }
    catalogs[locale] = messages;
  }
  final english = catalogs['en'];
  if (english == null) {
    throw const FormatException('English fallback catalog is required');
  }
  final keys = english.keys.toList()..sort();
  final schemas = <String, Map<String, String>>{};
  final normalized = <String, Map<String, Object?>>{};
  final locales = catalogs.keys.where((locale) => locale != 'en').toList()
    ..sort();
  locales.insert(0, 'en');
  for (final locale in locales) {
    final messages = catalogs[locale]!;
    if (messages.length != keys.length ||
        !messages.keys.toSet().containsAll(keys)) {
      throw FormatException('$locale message keys differ from English');
    }
    final output = <String, Object?>{};
    for (final key in keys) {
      if (!_keyPattern.hasMatch(key)) {
        throw FormatException('Invalid message key: $key');
      }
      final value = messages[key];
      final parameters = <String, String>{};
      final texts = <String>[];
      String? selector;
      if (value is String) {
        texts.add(value);
        output[key] = value;
      } else if (value is Map<String, dynamic>) {
        final rawParameters = value['parameters'];
        if (rawParameters is! Map<String, dynamic>) {
          throw FormatException('$locale:$key requires parameter types');
        }
        for (final entry in rawParameters.entries) {
          if (!_parameterPattern.hasMatch(entry.key) ||
              !const {'String', 'int'}.contains(entry.value)) {
            throw FormatException(
              '$locale:$key invalid parameter ${entry.key}',
            );
          }
          parameters[entry.key] = entry.value as String;
        }
        if (value['text'] is String &&
            value.keys.toSet().difference({'text', 'parameters'}).isEmpty) {
          texts.add(value['text'] as String);
          output[key] = value['text'];
        } else if (value['plural'] is String &&
            value['one'] is String &&
            value['other'] is String &&
            value.keys.toSet().difference({
              'plural',
              'one',
              'other',
              'parameters',
            }).isEmpty) {
          selector = value['plural'] as String;
          if (parameters[selector] != 'int') {
            throw FormatException('$locale:$key plural parameter must be int');
          }
          texts.addAll([value['one'] as String, value['other'] as String]);
          output[key] = {
            'plural': selector,
            'one': value['one'],
            'other': value['other'],
          };
        } else if (value['select'] is String &&
            value['cases'] is Map<String, dynamic> &&
            value.keys.toSet().difference({
              'select',
              'cases',
              'parameters',
            }).isEmpty) {
          selector = value['select'] as String;
          final cases = value['cases'] as Map<String, dynamic>;
          if (parameters[selector] != 'String' ||
              cases['other'] is! String ||
              cases.values.any((value) => value is! String)) {
            throw FormatException(
              '$locale:$key requires String selector and other case',
            );
          }
          texts.addAll(cases.values.cast<String>());
          output[key] = {'select': selector, 'cases': cases};
        } else {
          throw FormatException('$locale:$key invalid message definition');
        }
      } else {
        throw FormatException(
          '$locale:$key must be a string or message definition',
        );
      }
      final referenced = <String>{?selector};
      for (final text in texts) {
        if (text.isEmpty) throw FormatException('$locale:$key has empty text');
        referenced.addAll(
          _placeholderPattern.allMatches(text).map((match) => match.group(1)!),
        );
        if (text
            .replaceAll(_placeholderPattern, '')
            .contains(RegExp(r'[{}]'))) {
          throw FormatException('$locale:$key has malformed placeholders');
        }
      }
      if (referenced.length != parameters.length ||
          !referenced.containsAll(parameters.keys)) {
        throw FormatException(
          '$locale:$key placeholders do not match parameter types',
        );
      }
      final reference = schemas[key];
      if (reference == null) {
        schemas[key] = parameters;
      } else if (reference.length != parameters.length ||
          reference.entries.any(
            (entry) => parameters[entry.key] != entry.value,
          )) {
        throw FormatException('$locale:$key parameter types differ');
      }
      // Message shape is shared so translated getters retain one typed API.
      final base = english[key];
      if ((base is String) != (value is String) ||
          (base is Map &&
              value is Map &&
              (base['plural'] != value['plural'] ||
                  base['select'] != value['select']))) {
        throw FormatException('$locale:$key message selector differs');
      }
    }
    normalized[locale] = output;
  }
  String literal(Object? value) => jsonEncode(value).replaceAll(r'$', r'\$');
  String apiName(String key) => key.replaceFirstMapped(
    RegExp(r'\.([a-z])'),
    (match) => match.group(1)!.toUpperCase(),
  );
  final result = StringBuffer(
    '// GENERATED by tool/generate_localizations.dart. Do not edit.\npart of \'app_strings.dart\';\n\n',
  );
  result.writeln(
    'const _catalogMessages = <String, Map<String, dynamic>>${literal(normalized)};',
  );
  result.writeln(
    '\nmixin _AppMessages {\n  String _message(String key, Map<String, Object> parameters);',
  );
  final apiNames = <String>{};
  for (final key in keys) {
    final params = schemas[key]!;
    final method = apiName(key);
    if (!apiNames.add(method)) {
      throw FormatException('Duplicate generated message API: $method');
    }
    if (params.isEmpty) {
      result.writeln("  String get $method => _message('$key', const {});");
    } else {
      final args = params.entries
          .map((entry) => '${entry.value} ${entry.key}')
          .join(', ');
      final values = params.keys.map((name) => "'$name': $name").join(', ');
      result.writeln("  String $method($args) => _message('$key', {$values});");
    }
  }
  result.writeln('}');
  return result.toString();
}
