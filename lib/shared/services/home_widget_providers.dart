import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

/// The home-screen-widget URI this launch started from, if any.
///
/// 5.1: `main()` no longer awaits `initiallyLaunchedFromHomeWidget` before
/// calling `runApp`, because that platform-channel round trip was holding the
/// first frame behind it. The future is injected here instead and resolved
/// after the first frame, so the deep link is applied by navigation.
///
/// This is the same information the old code passed as
/// `appInitialLocationProvider`. That provider is still used — it is what the
/// router's `initialLocation` reads — but it now always starts at `/startup`
/// and the widget link is applied on top, which routes through the identical
/// redirect and onboarding logic.
final homeWidgetLaunchProvider = Provider<Future<Uri?>>((ref) {
  return HomeWidget.initiallyLaunchedFromHomeWidget();
});
