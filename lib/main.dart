import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'app.dart';
import 'shared/services/home_widget_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 5.1: both of these are platform-channel round trips, and awaiting them
  // before runApp held the first frame behind the slower of the two. They are
  // independent of each other and neither has to complete before the first
  // frame can be built, so both are started here and `runApp` is called
  // immediately. The two futures are deliberately not awaited: the system UI
  // mode has no result the app needs, and the home-widget launch URI is
  // applied by navigation once it arrives, below.
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  final widgetLaunch = HomeWidget.initiallyLaunchedFromHomeWidget();

  runApp(
    ProviderScope(
      overrides: [
        homeWidgetLaunchProvider.overrideWithValue(widgetLaunch),
      ],
      child: const SalaKatolikiApp(),
    ),
  );

  // If the app was cold-launched from the home-screen widget, the deep link
  // has to be applied after the first frame rather than as the router's
  // initial location. `_applyWidgetLaunch` in app.dart does that, reusing the
  // same pending-link path that a warm `widgetClicked` already takes, so the
  // redirect and onboarding handling are identical in both cases.
}
