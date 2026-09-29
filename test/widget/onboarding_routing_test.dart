import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salakatoliki/app.dart';
import 'package:salakatoliki/routes/app_router.dart';
import 'package:salakatoliki/shared/widgets/prayer_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_asset_bundle.dart';

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
          localContentDataSourceProvider.overrideWithValue(
            testContentDataSource(),
          ),
        ],
        child: const SalaKatolikiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Prayer Language'), findsOneWidget);
    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);

    await _pumpUntilFound(tester, find.text('Our Father'));
    expect(
      find.textContaining('Our Father, who art in heaven'),
      findsOneWidget,
    );
    expect(
      find.text('COMMON PRAYERS'),
      findsOneWidget,
      reason: 'the deep link must resolve real bundled content, not an '
          'error or missing-prayer state',
    );
    expect(
      find.byType(PrayerTextView),
      findsOneWidget,
      reason: 'the prayer must render through the unboxed reading view',
    );
  });

  testWidgets('stored language starts without onboarding flicker', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          localContentDataSourceProvider.overrideWithValue(
            testContentDataSource(),
          ),
        ],
        child: const SalaKatolikiApp(),
      ),
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
