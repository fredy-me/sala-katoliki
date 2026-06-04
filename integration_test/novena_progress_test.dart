import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:salakatoliki/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('novena progress can start and complete day one offline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});

    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));
    await _pumpUntilFound(tester, find.text('Novenas'));

    await tester.tap(find.text('Novenas').last);
    await _pumpUntilFound(tester, find.text('Divine Mercy Novena'));
    await tester.tap(find.text('Divine Mercy Novena').first);
    await _pumpUntilFound(tester, find.text('Start Novena'));
    await tester.tap(find.text('Start Novena'));
    await _pumpUntilFound(tester, find.text('Mark Complete'));
    await tester.tap(find.text('Mark Complete'));
    await _pumpUntilFound(tester, find.text('Day 2 of 9'));

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('active_novena_id'), 'divine_mercy_novena');
    expect(preferences.getStringList('completed_novena_days'), ['1']);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 100,
}) async {
  for (var index = 0; index < maxPumps; index += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Expected requested widget to appear.');
}
