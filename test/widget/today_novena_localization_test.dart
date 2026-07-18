import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/localization/localization_providers.dart';
import 'package:salakatoliki/data/models/novena_model.dart';
import 'package:salakatoliki/features/novenas/domain/novena_state.dart';
import 'package:salakatoliki/features/novenas/presentation/providers/novena_providers.dart';
import 'package:salakatoliki/features/today/presentation/providers/today_providers.dart';
import 'package:salakatoliki/features/today/presentation/screens/today_screen.dart';

void main() {
  testWidgets('shows localized Kiswahili titles for active novenas', (
    tester,
  ) async {
    await _expectActiveNovenaTitle(
      tester,
      novenaId: 'st_rita_novena',
      expectedTitle: 'Novena ya Mt. Rita wa Kashia',
      untranslatedTitle: 'St Rita Novena',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await _expectActiveNovenaTitle(
      tester,
      novenaId: 'st_jude_novena',
      expectedTitle: 'Novena ya Mtakatifu Yuda',
      untranslatedTitle: 'St Jude Novena',
    );
  });
}

Future<void> _expectActiveNovenaTitle(
  WidgetTester tester, {
  required String novenaId,
  required String expectedTitle,
  required String untranslatedTitle,
}) async {
  final progress = NovenaProgress(
    activeNovenaId: novenaId,
    completedDaysByNovenaId: {
      novenaId: {1},
    },
  );

  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        activeLanguageProvider.overrideWithValue('sw'),
        todayLocalStateProvider.overrideWith(
          (ref) async => TodayLocalState(
            activeNovenaId: novenaId,
            completedNovenaDays: const {1},
            reminderEnabled: false,
            reminderTime: null,
          ),
        ),
        activeNovenaSessionProvider.overrideWith(
          (ref) async => NovenaSession(
            novena: NovenaModel(
              id: novenaId,
              language: 'sw',
              title: expectedTitle,
              description: '',
              days: const [],
            ),
            progress: progress,
          ),
        ),
      ],
      child: const MaterialApp(home: TodayScreen()),
    ),
  );

  await _pumpUntilFound(tester, find.text(expectedTitle));

  expect(find.text(expectedTitle), findsOneWidget);
  expect(find.text(untranslatedTitle), findsNothing);
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
