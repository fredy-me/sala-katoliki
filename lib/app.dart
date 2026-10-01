import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'core/localization/localization_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/prayers/domain/entities/prayer_entity.dart';
import 'features/prayers/presentation/providers/prayer_providers.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'routes/app_router.dart';
import 'shared/services/deep_link_providers.dart';
import 'shared/services/deep_link_service.dart';
import 'shared/services/home_widget_providers.dart';
import 'shared/services/home_widget_service.dart';

class SalaKatolikiApp extends ConsumerStatefulWidget {
  const SalaKatolikiApp({super.key});

  @override
  ConsumerState<SalaKatolikiApp> createState() => _SalaKatolikiAppState();
}

class _SalaKatolikiAppState extends ConsumerState<SalaKatolikiApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _widgetClickSub;
  StreamSubscription<Uri>? _appLinkSub;
  String? _pendingAppLink;

  @override
  void initState() {
    super.initState();
    _listenForWidgetLaunches();
    _listenForAppLinks();
    _applyWidgetLaunch();
  }

  /// 5.1: applies a cold launch from the home-screen widget.
  ///
  /// This used to be the router's `initialLocation`, which meant `main()` had
  /// to await the platform channel before it could call `runApp`. Resolving it
  /// here instead lets the first frame render immediately, and the link is
  /// navigated to the moment it is known.
  ///
  /// The guard on `ref.mounted` matters here: this future can resolve after
  /// the app has been torn down, and touching `ref` then would throw. The
  /// route is applied through the same `_navigateToDeepLink` path as a warm
  /// widget tap and an app link, so the redirect and onboarding handling are
  /// identical in all three cases.
  void _applyWidgetLaunch() {
    ref
        .read(homeWidgetLaunchProvider)
        .then((uri) {
          if (!mounted || uri == null) {
            return;
          }
          // Navigated directly, not through the deep-link resolver. The widget
          // URI is a real in-app route, not a site slug: the old code used it
          // as the router's `initialLocation` verbatim, and a warm
          // `widgetClicked` tap calls `go()` on it in the same way. Only
          // external app links go through the slug resolver.
          ref.read(appRouterProvider).go(uri.toString());
        })
        .catchError((Object error, StackTrace stackTrace) {
          // Widget support is unavailable (for example, in tests). The app
          // simply starts at its normal location.
        });
  }

  void _listenForWidgetLaunches() {
    _widgetClickSub = HomeWidget.widgetClicked.listen(
      (uri) {
        if (uri == null) {
          return;
        }
        ref.read(appRouterProvider).go(uri.toString());
      },
      onError: (Object error, StackTrace stackTrace) {
        // Widget communication is unavailable (for example, in tests).
      },
    );
    // 5.2: the post-frame `ref.read(prayersProvider)` preload is gone. It
    // parsed all 36 prayers to warm a cache that the Today screen — the first
    // thing rendered — watches on its very next build anyway, so it did not
    // avoid the load, it only started it a frame earlier and duplicated the
    // read. Anything that needs the prayers watches the provider and triggers
    // the load itself, so removing this changes no observable behaviour.
  }

  void _listenForAppLinks() {
    _appLinkSub = _appLinks.uriLinkStream.listen(
      _onAppLink,
      onError: (Object error, StackTrace stackTrace) {
        // Link delivery is unavailable (for example, in tests).
      },
    );
  }

  void _onAppLink(Uri uri) {
    final raw = uri.toString();
    final context = ref.read(deepLinkContextProvider).value;
    if (context == null) {
      _pendingAppLink = raw;
      ref.read(deepLinkContextProvider);
      return;
    }
    _navigateToDeepLink(raw, context);
  }

  void _navigateToDeepLink(String raw, DeepLinkService context) {
    final route = context.resolve(raw);
    if (route == null) {
      return;
    }
    ref.read(appRouterProvider).go(route);
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    _appLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(prayersProvider, (previous, next) {
      final prayers = next.value;
      if (prayers == null || prayers.isEmpty) {
        return;
      }
      final dailyPrayer = dailyPrayerFor(prayers);
      if (dailyPrayer == null) {
        return;
      }
      unawaited(
        HomeWidgetService.updateTodayPrayer(
          prayer: dailyPrayer,
          languageCode: ref.read(activeLanguageProvider),
        ),
      );
    });

    ref.listen(deepLinkContextProvider, (previous, next) {
      if (next is AsyncData<DeepLinkService> && _pendingAppLink != null) {
        _navigateToDeepLink(_pendingAppLink!, next.value);
        _pendingAppLink = null;
      }
    });

    final router = ref.watch(appRouterProvider);
    // 5.5: the two fields the root actually renders. Watching the full
    // settings object meant a reminder toggle rebuilt the whole router.
    final settings = ref.watch(rootSettingsProvider);

    return MaterialApp.router(
      title: 'Sala Katoliki',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: router,
      builder: (context, child) {
        final scale = settings.fontScale;
        final mediaQuery = MediaQuery.of(context);
        final brightness = Theme.of(context).brightness;
        final statusBarColor = AppTheme.statusBarColorFor(brightness);
        final appContent = MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.systemOverlayStyleFor(brightness),
          child: Stack(
            fit: StackFit.expand,
            children: [
              appContent,
              if (mediaQuery.padding.top > 0)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: mediaQuery.padding.top,
                  child: IgnorePointer(
                    child: ColoredBox(color: statusBarColor),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
