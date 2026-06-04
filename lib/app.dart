import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        return _AppBackGuard(
          router: router,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _AppBackGuard extends StatefulWidget {
  const _AppBackGuard({required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  State<_AppBackGuard> createState() => _AppBackGuardState();
}

class _AppBackGuardState extends State<_AppBackGuard> {
  static const _homePath = '/today';
  static const _exitWindow = Duration(seconds: 2);

  DateTime? _lastExitRequestAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        _handleBack();
      },
      child: widget.child,
    );
  }

  void _handleBack() {
    if (widget.router.canPop()) {
      widget.router.pop();
      return;
    }

    final path = widget.router.routerDelegate.currentConfiguration.uri.path;
    if (path != _homePath) {
      widget.router.go(_homePath);
      return;
    }

    final now = DateTime.now();
    final shouldExit =
        _lastExitRequestAt != null &&
        now.difference(_lastExitRequestAt!) <= _exitWindow;

    if (shouldExit) {
      SystemNavigator.pop();
      return;
    }

    _lastExitRequestAt = now;
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Press back again to close Sala Katoliki.')),
    );
  }
}
