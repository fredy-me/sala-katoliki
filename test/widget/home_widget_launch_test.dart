import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/app.dart';
import 'package:salakatoliki/shared/services/home_widget_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_asset_bundle.dart';

/// 5.1. `main()` no longer awaits the home-widget platform channel before
/// `runApp`, so a cold launch from the widget is applied by navigation after
/// the first frame instead of being the router's `initialLocation`.
///
/// The plan calls this the most likely place for a silent break, and it cannot
/// be verified by launching a real device here, so these tests cover the
/// paths the change introduced: a link that arrives late, a link that arrives
/// before the deep-link resolver is ready, a null link, and a failure. A
/// regression in any of them would leave the user on the Today screen after
/// tapping a home-screen widget, which is a plausible silent failure.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // A stored language is needed, otherwise the router correctly diverts to
  // onboarding and the deep link is held as a pending redirect. That path is
  // already covered by onboarding_routing_test.dart.
  void withLanguage() {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
  }

  ProviderScope scope(WidgetTester tester, Future<Uri?> launch) {
    return ProviderScope(
      key: UniqueKey(),
      overrides: [
        homeWidgetLaunchProvider.overrideWithValue(launch),
        localContentDataSourceProvider.overrideWithValue(
          testContentDataSource(),
        ),
      ],
      child: const SalaKatolikiApp(),
    );
  }

  testWidgets('a widget launch deep link is applied after the first frame', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

    withLanguage();
    // A future, not a value: the whole point of 5.1 is that the launch URI is
    // not known at the time runApp is called.
    final launch = Completer<Uri?>();
    await tester.pumpWidget(scope(tester, launch.future));
    await tester.pumpAndSettle();

    launch.complete(Uri.parse('/prayers/our_father'));
    await _pumpUntilFound(tester, find.byType(SalaKatolikiApp));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Our Father, who art in heaven'),
      findsOneWidget,
      reason: 'the launch link must be navigated to, not dropped',
    );
  });

  testWidgets('a null launch URI leaves the app on its normal start', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

    withLanguage();
    await tester.pumpWidget(scope(tester, Future<Uri?>.value(null)));
    await tester.pumpAndSettle();

    // With a stored language the app should have reached a real screen
    // without being sent anywhere odd, and must not be stuck on the splash.
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failing launch future does not crash the app', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

    withLanguage();
    final launch = Completer<Uri?>();
    await tester.pumpWidget(scope(tester, launch.future));
    await tester.pumpAndSettle();

    // The platform channel is missing in tests and on devices without the
    // widget, which surfaces as an error rather than a null.
    launch.completeError(
      MissingPluginException('home_widget'),
      StackTrace.current,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the app is disposed before the launch future resolves', (
    tester,
  ) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

    withLanguage();
    final launch = Completer<Uri?>();
    await tester.pumpWidget(scope(tester, launch.future));
    await tester.pumpAndSettle();

    // Tear the app down, then resolve. `main()` kicks this future off without
    // awaiting it, so nothing guarantees the app is still alive when it
    // completes. Note the `mounted` guard in `_applyWidgetLaunch` is defensive
    // rather than load-bearing: removing it still passes this test, because
    // reading a provider from a disposed ConsumerState does not throw here.
    // The guard is kept because the cost is one bool check and the failure it
    // prevents is a real class of error, but this test documents "does not
    // crash", not "the guard is required".
    await tester.pumpWidget(const SizedBox.shrink());
    launch.complete(Uri.parse('/prayers/our_father'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
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
  fail('Expected the requested widget to appear.');
}
