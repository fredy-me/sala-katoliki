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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(prayersProvider);
    });
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
    final settings = ref.watch(userSettingsProvider).asData?.value;

    return MaterialApp.router(
      title: 'Sala Katoliki',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings?.themeMode ?? ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        final scale = settings?.fontScale ?? 1;
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
