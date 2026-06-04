import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content validation script passes for bundled MVP content', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_content.dart',
    ]);

    expect(result.exitCode, 0, reason: '${result.stderr}\n${result.stdout}');
    expect(result.stdout.toString(), contains('Content validation passed.'));
  });
}
