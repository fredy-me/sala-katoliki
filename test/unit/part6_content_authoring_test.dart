import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final validator = File('tools/validate_content.dart').absolute.path;
  final generator = File('tool/generate_content_manifest.dart').absolute.path;
  late Directory fixture;

  setUp(() {
    fixture = Directory.systemTemp.createTempSync('sala-content-');
    for (final entry in Directory(
      'assets/content',
    ).listSync(recursive: true).whereType<File>()) {
      final target = File('${fixture.path}/${entry.path}');
      target.parent.createSync(recursive: true);
      entry.copySync(target.path);
    }
  });
  tearDown(() => fixture.deleteSync(recursive: true));

  Future<ProcessResult> run(String script, [List<String> args = const []]) =>
      Process.run('dart', [script, ...args], workingDirectory: fixture.path);

  Map<String, dynamic> read(String path) =>
      jsonDecode(File('${fixture.path}/$path').readAsStringSync())
          as Map<String, dynamic>;
  void write(String path, Object value) =>
      File('${fixture.path}/$path').writeAsStringSync(jsonEncode(value));
  const manifestPath = 'assets/content/metadata/content_manifest.json';
  const novenaPath = 'assets/content/novenas/en/st_rita_novena.json';

  test(
    'generator check preserves committed manifest bytes and order',
    () async {
      final file = File('${fixture.path}/$manifestPath');
      final before = file.readAsStringSync();
      final result = await run(generator, ['--check']);
      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect(file.readAsStringSync(), before);
    },
  );

  test(
    'two new prayer files become visible with one generator command',
    () async {
      for (final language in ['en', 'sw']) {
        write('assets/content/prayers/$language/authoring_probe.json', [
          {
            'id': 'authoring_probe',
            'type': 'prayer',
            'style': 'standard',
            'category': 'common_prayers',
            'language': language,
            'title': 'Authoring probe',
            'body': '[[plain]]Test fixture only.[[/plain]]',
          },
        ]);
      }
      var result = await run(validator);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('invisible to the app'));
      result = await run(generator);
      expect(result.exitCode, 0, reason: '${result.stderr}');
      result = await run(validator);
      expect(result.exitCode, 0, reason: '${result.stderr}');
      final first = File('${fixture.path}/$manifestPath').readAsStringSync();
      await run(generator);
      expect(File('${fixture.path}/$manifestPath').readAsStringSync(), first);
    },
  );

  test('missing or invalid presentation styles fail validation', () async {
    final novena = read(novenaPath);
    novena.remove('style');
    write(novenaPath, novena);
    var result = await run(validator);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('must declare a valid style'));
    novena['style'] = 'misspelled';
    write(novenaPath, novena);
    result = await run(validator);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('must declare a valid style'));
  });

  test('validator rejects malformed and unsupported reading markers', () async {
    final novena = read(novenaPath);
    final day = (novena['days'] as List).first as Map;
    for (final body in [
      '[[heading]]Missing close',
      '[[group]]Undeclared child[[/group]]',
      '[[panel_gold]]Wrong renderer[[/panel_gold]]',
    ]) {
      day['body'] = body;
      write(novenaPath, novena);
      final result = await run(validator);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('body:'));
    }
  });

  test('duplicate and nonexistent manifest paths fail validation', () async {
    final manifest = read(manifestPath);
    final paths = (manifest['prayers'] as Map)['en'] as List;
    paths.add(paths.first);
    paths.add('assets/content/prayers/en/absent.json');
    write(manifestPath, manifest);
    final result = await run(validator);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('duplicate or non-string paths'));
    expect(result.stderr, contains('does not exist'));
  });

  test('undeclared language mismatch fails validation', () async {
    final path = 'assets/content/prayers/en/common_prayers.json';
    final prayers =
        jsonDecode(File('${fixture.path}/$path').readAsStringSync()) as List;
    (prayers.first as Map)['id'] = 'undeclared_translation';
    write(path, prayers);
    final result = await run(validator);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('id exists in en but not sw'));
  });

  test('invalid aliases cannot hide missing translations', () async {
    write('assets/content/metadata/id_aliases.json', {
      'prayer_id_aliases': {'absent_sw': 'divine_mercy_eternal_father'},
    });
    final result = await run(validator);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('does not match any sw prayer id'));
  });

  test('empty days, incorrect declared count and ordering fail', () async {
    final original = read(novenaPath);
    final days = original['days'] as List;
    final first = days.removeAt(0);
    days.add(first);
    original['day_count'] = 9;
    write(novenaPath, original);
    var result = await run(validator);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('day_count must match'));
    expect(result.stderr, contains('days must be ordered'));
    original['days'] = [];
    write(novenaPath, original);
    result = await run(validator);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('must have at least one day'));
  });

  test('different language day counts fail validation', () async {
    final novena = read(novenaPath);
    (novena['days'] as List).removeLast();
    write(novenaPath, novena);
    final result = await run(validator);
    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('different day count'));
  });
}
