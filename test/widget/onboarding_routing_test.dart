import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salakatoliki/app.dart';
import 'package:salakatoliki/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('deep link resumes after onboarding language selection', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          appInitialLocationProvider.overrideWithValue('/prayers/our_father'),
        ],
        child: const SalaKatolikiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Prayer Language'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(FilledButton),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(FilledButton));

    await _pumpUntilFound(tester, find.text('Our Father'));
    expect(
      find.textContaining('Our Father, who art in heaven'),
      findsOneWidget,
    );
    expect(find.text('Source'), findsOneWidget);
  });

  testWidgets('stored language starts without onboarding flicker', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

    await tester.pumpWidget(
      ProviderScope(key: UniqueKey(), child: const SalaKatolikiApp()),
    );
    await tester.pump();

    expect(find.text('Choose Your Prayer Language'), findsNothing);

    await _pumpUntilFound(tester, find.text('Today'));
    expect(find.text('Choose Your Prayer Language'), findsNothing);
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
