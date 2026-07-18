import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'routes/app_router.dart';

class SalaKatolikiApp extends ConsumerWidget {
  const SalaKatolikiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        final isLightTheme = Theme.of(context).brightness == Brightness.light;
        final appContent = MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );

        if (!isLightTheme) {
          return appContent;
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.systemOverlayStyleFor(
            Theme.of(context).brightness,
          ),
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
                  child: const IgnorePointer(
                    child: ColoredBox(color: AppColors.lightStatusBarCream),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
