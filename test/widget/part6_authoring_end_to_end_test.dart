import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/app.dart';
import 'package:salakatoliki/data/datasources/local_content_datasource.dart';
import 'package:salakatoliki/features/prayers/presentation/providers/prayer_providers.dart';
import 'package:salakatoliki/routes/app_router.dart';
import 'package:salakatoliki/shared/services/deep_link_service.dart';
import 'package:salakatoliki/shared/widgets/app_card.dart';
import 'package:salakatoliki/shared/widgets/prayer_text_view.dart';
import 'package:salakatoliki/shared/widgets/novena_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixtureBundle extends CachingAssetBundle {
  _FixtureBundle(Directory root)
    : files = {
        for (final file in Directory(
          '${root.path}/assets/content',
        ).listSync(recursive: true).whereType<File>())
          file.path.substring(root.path.length + 1): file.readAsStringSync(),
      };
  final Map<String, String> files;

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      SynchronousFuture(files[key]!);

  @override
  Future<ByteData> load(String key) => SynchronousFuture(
    ByteData.sublistView(Uint8List.fromList(utf8.encode(files[key]!))),
  );
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    for (final channel in [
      'home_widget',
      'home_widget/updates',
      'com.llfbandit.app_links/events',
      'com.llfbandit.app_links/messages',
    ]) {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (_) async => null,
      );
    }
  });
  final generator = File('tool/generate_content_manifest.dart').absolute.path;
  final validator = File('tools/validate_content.dart').absolute.path;
  for (final language in ['en', 'sw']) {
    testWidgets(
      'new $language prayer and variable-length novena load and route without Dart edits',
      (tester) async {
        SharedPreferences.setMockInitialValues({'selected_language': language});
        final fixture = Directory.systemTemp.createTempSync(
          'sala-authoring-e2e-',
        );
        addTearDown(() => fixture.deleteSync(recursive: true));
        addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
        late LocalContentDataSource source;
        late DeepLinkService links;
        await tester.runAsync(() async {
          for (final file in Directory(
            'assets/content',
          ).listSync(recursive: true).whereType<File>()) {
            final target = File('${fixture.path}/${file.path}');
            target.parent.createSync(recursive: true);
            file.copySync(target.path);
          }
          for (final locale in ['en', 'sw']) {
            File(
              '${fixture.path}/assets/content/prayers/$locale/authoring_probe.json',
            ).writeAsStringSync(
              jsonEncode([
                {
                  'id': 'authoring_probe',
                  'type': 'prayer',
                  'style': 'standard',
                  'category': 'common_prayers',
                  'language': locale,
                  'title': 'New prayer $locale',
                  'body':
                      '[[heading]]Authored heading $locale[[/heading]]\n\n[[plain]]Authored prayer $locale.[[/plain]]',
                },
              ]),
            );
            File(
              '${fixture.path}/assets/content/novenas/$locale/authoring_probe_novena.json',
            ).writeAsStringSync(
              jsonEncode({
                'id': 'authoring_probe_novena',
                'language': locale,
                'title': 'New novena $locale',
                'description': 'Temporary authoring fixture.',
                'style': 'all_saints',
                'day_count': 2,
                'days': [
                  for (var day = 1; day <= 2; day++)
                    {
                      'day': day,
                      'title': 'Authored day $day',
                      'body':
                          '[[heading]]Authored novena $locale[[/heading]]\n\n[[plain]]Authored day $day $locale.[[/plain]]',
                    },
                ],
              }),
            );
          }
          // One command registers both bilingual additions; validation follows.
          final generated = await Process.run('dart', [
            generator,
          ], workingDirectory: fixture.path);
          expect(generated.exitCode, 0, reason: '${generated.stderr}');
          final validated = await Process.run('dart', [
            validator,
          ], workingDirectory: fixture.path);
          expect(validated.exitCode, 0, reason: '${validated.stderr}');
          source = LocalContentDataSource(bundle: _FixtureBundle(fixture));
          final prayers = await source.getPrayers(languageCode: language);
          final novenas = await source.getNovenas(languageCode: language);
          final prayer = prayers.singleWhere(
            (item) => item.id == 'authoring_probe',
          );
          expect(prayer.matches('Authored prayer'), isTrue);
          expect(prayer.body, isNot(contains('[[')));
          expect(
            novenas
                .singleWhere((item) => item.id == 'authoring_probe_novena')
                .dayCount,
            2,
          );
          links = DeepLinkService(
            prayerIndex: prayers,
            activePrayers: prayers,
            novenas: novenas,
            mysteries: const [],
          );
        });
        // Cached futures created in runAsync belong to the real async zone.
        // Widget providers must start a fresh synchronous bundle chain here.
        source = LocalContentDataSource(bundle: _FixtureBundle(fixture));
        final prayerRoute = links.resolve(
          'https://busaradigital.com/salakatoliki/prayers/authoring_probe',
        );
        expect(prayerRoute, '/prayers/authoring_probe');
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appInitialLocationProvider.overrideWithValue(prayerRoute!),
              localContentDataSourceProvider.overrideWithValue(source),
            ],
            child: const SalaKatolikiApp(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('New prayer $language'), findsOneWidget);
        expect(
          find.textContaining('Authored prayer $language.'),
          findsOneWidget,
        );
        expect(find.byType(PrayerTextView), findsOneWidget);
        expect(
          find.ancestor(
            of: find.byType(PrayerTextView),
            matching: find.byType(AppCard),
          ),
          findsNothing,
        );
        final container = ProviderScope.containerOf(
          tester.element(find.byType(SalaKatolikiApp)),
        );
        final dayRoute = links.resolve(
          'https://busaradigital.com/salakatoliki/novenas/authoring_probe_novena/day/2',
        );
        expect(dayRoute, '/novenas/authoring_probe_novena/day/2');
        container.read(appRouterProvider).go(dayRoute!);
        await tester.pumpAndSettle();
        expect(find.text('Authored day 2 $language.'), findsOneWidget);
        expect(
          find.text('AUTHORED NOVENA ${language.toUpperCase()}'),
          findsOneWidget,
        );
        expect(find.byType(NovenaTextView), findsOneWidget);
        expect(
          find.ancestor(
            of: find.byType(NovenaTextView),
            matching: find.byType(AppCard),
          ),
          findsNothing,
        );
        expect(find.textContaining('[[', findRichText: true), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
