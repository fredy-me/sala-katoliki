import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:salakatoliki/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline prayer flow opens category, list, and detail', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'sw'});

    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));
    await _pumpUntilFound(tester, find.text('Pray'));

    await tester.tap(find.text('Pray'));
    await _pumpUntilFound(tester, find.text('Sala za Kawaida'));
    await tester.tap(find.text('Sala za Kawaida').first);
    await _pumpUntilFound(tester, find.text('Baba Yetu'));
    await tester.tap(find.text('Baba Yetu').first);
    await _pumpUntilFound(
      tester,
      find.textContaining('Baba yetu uliye mbinguni'),
    );

    expect(find.text('SALA ZA KAWAIDA'), findsOneWidget);
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
