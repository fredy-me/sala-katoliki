import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'app.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final widgetUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
  runApp(
    ProviderScope(
      overrides: [
        if (widgetUri != null)
          appInitialLocationProvider.overrideWithValue(widgetUri.toString()),
      ],
      child: const SalaKatolikiApp(),
    ),
  );
}
