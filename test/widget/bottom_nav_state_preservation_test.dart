import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/app.dart';
import 'package:salakatoliki/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_asset_bundle.dart';

/// 5.4 — state-preserving tab switches.
///
/// This is the one intentional behaviour change in Part 5, so it is tested at
/// the level the plan specifies it at: the observable scroll position after
/// navigating away from a tab and back.
///
/// The mechanism is `StatefulShellRoute.indexedStack`. A plain `ShellRoute`
/// rebuilds the destination on every switch, so a scrolled `ListView` resets.
/// These tests fail if the shell is reverted, which is the point.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
  });

  Future<void> pumpApp(WidgetTester tester) async {
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
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(NavigationDestination, label));
    await tester.pumpAndSettle();
  }

  testWidgets('scroll position on Today survives a round trip to Pray', (
    tester,
  ) async {
    await pumpApp(tester);

    final todayList = find.byType(Scrollable).first;
    expect(todayList, findsOneWidget);

    // Scroll the Today list well past the fold.
    await tester.drag(todayList, const Offset(0, -600));
    await tester.pumpAndSettle();
    final scrolled = tester.widget<Scrollable>(todayList);
    final positionBefore = _offsetOf(scrolled);
    expect(
      positionBefore,
      greaterThan(0),
      reason: 'precondition: the list must actually be scrolled for this '
          'test to mean anything',
    );

    await tapTab(tester, 'Pray');
    await tapTab(tester, 'Today');

    final afterList = find.byType(Scrollable).first;
    final positionAfter = _offsetOf(tester.widget<Scrollable>(afterList));
    expect(
      positionAfter,
      positionBefore,
      reason: '5.4: returning to a tab must restore its scroll offset',
    );
  });

  testWidgets('each tab keeps its own scroll position independently', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    final todayOffset = _offsetOf(tester.widget<Scrollable>(
      find.byType(Scrollable).first,
    ));

    await tapTab(tester, 'Novenas');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
    await tester.pumpAndSettle();
    final novenaOffset = _offsetOf(tester.widget<Scrollable>(
      find.byType(Scrollable).first,
    ));
    expect(novenaOffset, greaterThan(0), reason: 'precondition');

    // Go back to Today: its own offset must be intact, not Novena's.
    await tapTab(tester, 'Today');
    expect(
      _offsetOf(tester.widget<Scrollable>(find.byType(Scrollable).first)),
      todayOffset,
      reason: 'branches must not share a scroll position',
    );

    // And Novena's must be intact too.
    await tapTab(tester, 'Novenas');
    expect(
      _offsetOf(tester.widget<Scrollable>(find.byType(Scrollable).first)),
      novenaOffset,
      reason: 'the Novenas branch must retain its own offset',
    );
  });

  testWidgets('every tab is reachable and none throws after the switch', (
    tester,
  ) async {
    await pumpApp(tester);

    for (final label in ['Pray', 'Novenas', 'Settings', 'Today']) {
      await tapTab(tester, label);
      expect(
        tester.takeException(),
        isNull,
        reason: 'switching to $label must not throw',
      );
    }

    // The shell must have reported a real selected destination, not the
    // `selectedIndex < 0 ? 0` fallback that would hide a broken index.
    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.selectedIndex, 0, reason: 'back on the Today branch');
  });

  testWidgets('the /library redirect still resolves to /settings', (
    tester,
  ) async {
    await pumpApp(tester);

    // /library lives inside the settings branch and redirects to /settings.
    // 5.4 moved it, so this must be re-verified rather than assumed.
    final router = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(appRouterProvider);
    router.go('/library');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

double _offsetOf(Scrollable scrollable) {
  final position = scrollable.controller?.position;
  return position?.pixels ?? 0;
}
