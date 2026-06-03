import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:salakatoliki/app.dart';
import 'package:salakatoliki/core/localization/localization_providers.dart';
import 'package:salakatoliki/data/models/novena_model.dart';
import 'package:salakatoliki/data/models/rosary_model.dart';
import 'package:salakatoliki/features/library/presentation/screens/favorites_screen.dart';
import 'package:salakatoliki/features/library/presentation/screens/library_screen.dart';
import 'package:salakatoliki/features/novenas/presentation/providers/novena_providers.dart';
import 'package:salakatoliki/features/novenas/presentation/screens/novena_day_screen.dart';
import 'package:salakatoliki/features/novenas/presentation/screens/novena_detail_screen.dart';
import 'package:salakatoliki/features/novenas/presentation/screens/novenas_screen.dart';
import 'package:salakatoliki/features/prayers/domain/entities/prayer_entity.dart';
import 'package:salakatoliki/features/prayers/presentation/screens/prayer_detail_screen.dart';
import 'package:salakatoliki/features/prayers/presentation/providers/prayer_providers.dart';
import 'package:salakatoliki/features/rosary/presentation/screens/mystery_selection_screen.dart';
import 'package:salakatoliki/features/rosary/presentation/screens/rosary_screen.dart';
import 'package:salakatoliki/features/rosary/presentation/screens/rosary_step_screen.dart';
import 'package:salakatoliki/features/rosary/presentation/providers/rosary_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows Sala Katoliki language selection', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));

    await tester.pumpAndSettle();

    expect(find.text('Choose Your Prayer Language'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.text('Kiswahili'), findsOneWidget);
  });

  testWidgets('opens offline prayer library and detail', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalaKatolikiApp()));

    await tester.pumpAndSettle();
    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Endelea'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pray'));
    await tester.pumpAndSettle();

    expect(find.text('Tafuta sala...'), findsOneWidget);
    expect(find.text('Sala za Kawaida'), findsOneWidget);

    await tester.tap(find.text('Sala za Kawaida').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Baba Yetu').first);
    await tester.pumpAndSettle();

    expect(find.text('SALA ZA KAWAIDA'), findsOneWidget);
    expect(find.textContaining('Baba yetu uliye mbinguni'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
  });

  testWidgets('persists favorite prayers and shows favorites screen', (
    tester,
  ) async {
    final container = ProviderContainer();
    expect(await container.read(favoritePrayerIdsProvider.future), isEmpty);
    await container
        .read(favoritePrayerIdsProvider.notifier)
        .toggle('our_father');

    var preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList('favorite_prayer_ids'),
      contains('our_father'),
    );
    container.dispose();

    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeLanguageProvider.overrideWithValue('en'),
          prayersProvider.overrideWith(
            (ref) async => const [
              PrayerEntity(
                id: 'our_father',
                type: 'prayer',
                categoryId: 'common_prayers',
                language: 'en',
                localizedTitle: 'Our Father',
                body: 'Our Father, who art in heaven.',
                categoryTitles: {'en': 'Common Prayers'},
                tags: ['daily'],
                source: 'Traditional Catholic Prayer',
              ),
            ],
          ),
          favoritePrayerIdsProvider.overrideWith(_FavoritesTestNotifier.new),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/library',
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) =>
                    const Scaffold(body: LibraryScreen()),
              ),
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
              GoRoute(
                path: '/prayers/:prayerId',
                builder: (context, state) => PrayerDetailScreen(
                  prayerId: state.pathParameters['prayerId']!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('Favorites'));

    expect(find.text('Our Father'), findsOneWidget);
    expect(find.text('missing_prayer'), findsNothing);
    expect(find.text('1 saved prayers'), findsOneWidget);

    await tester.ensureVisible(find.text('Favorites').last);
    await tester.tap(find.text('Favorites').last);
    await _pumpUntilFound(tester, find.byTooltip('Remove favorite'));
    await tester.tap(find.byTooltip('Remove favorite').first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('starts rosary and persists guided step progress', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeLanguageProvider.overrideWithValue('en'),
          rosaryMysteriesProvider.overrideWith(
            (ref) async => const [_testMystery],
          ),
          suggestedRosaryMysteryProvider.overrideWith(
            (ref) async => _testMystery,
          ),
          activeRosarySessionProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/rosary',
            routes: [
              GoRoute(
                path: '/rosary',
                builder: (context, state) =>
                    const Scaffold(body: RosaryScreen()),
              ),
              GoRoute(
                path: '/rosary/select',
                builder: (context, state) => const MysterySelectionScreen(),
              ),
              GoRoute(
                path: '/rosary/step/:mysteryId',
                builder: (context, state) => RosaryStepScreen(
                  mysteryId: state.pathParameters['mysteryId']!,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await _pumpUntilFound(tester, find.text('Holy Rosary'));
    expect(find.text("Today's Mystery"), findsOneWidget);

    final container = ProviderContainer();
    await container
        .read(rosaryProgressProvider.notifier)
        .start('joyful_mysteries');
    await container
        .read(rosaryProgressProvider.notifier)
        .save(mysteryId: 'joyful_mysteries', stepIndex: 1);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('rosary_step_index'), 1);
    expect(preferences.getString('rosary_mystery_id'), 'joyful_mysteries');

    await container
        .read(rosaryProgressProvider.notifier)
        .start('joyful_mysteries');
    expect(preferences.getInt('rosary_step_index'), 0);
    container.dispose();
  });

  testWidgets('shows active novena and marks current day complete', (
    tester,
  ) async {
    final container = ProviderContainer();
    await container
        .read(novenaProgressProvider.notifier)
        .start('divine_mercy_novena');
    await container
        .read(novenaProgressProvider.notifier)
        .completeDay('divine_mercy_novena', 1);
    await container
        .read(novenaProgressProvider.notifier)
        .completeDay('divine_mercy_novena', 12);

    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('active_novena_id'), 'divine_mercy_novena');
    expect(preferences.getStringList('completed_novena_days'), ['1']);
    container.dispose();

    SharedPreferences.setMockInitialValues({
      'selected_language': 'en',
      'active_novena_id': 'divine_mercy_novena',
      'completed_novena_days': ['1', '99', 'bad'],
    });
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeLanguageProvider.overrideWithValue('en'),
          novenasProvider.overrideWith((ref) async => const [_testNovena]),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/novenas',
            routes: [
              GoRoute(
                path: '/novenas',
                builder: (context, state) =>
                    const Scaffold(body: NovenasScreen()),
              ),
              GoRoute(
                path: '/novenas/:novenaId',
                builder: (context, state) => NovenaDetailScreen(
                  novenaId: state.pathParameters['novenaId']!,
                ),
              ),
              GoRoute(
                path: '/novenas/:novenaId/day/:day',
                builder: (context, state) => NovenaDayScreen(
                  novenaId: state.pathParameters['novenaId']!,
                  day: int.tryParse(state.pathParameters['day'] ?? '') ?? -1,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await _pumpUntilFound(tester, find.text('Active Novena'));
    expect(find.text('Divine Mercy Novena'), findsWidgets);
    expect(find.text('Day 2 of 9'), findsOneWidget);

    await tester.tap(find.text('Continue').first);
    await _pumpUntilFound(tester, find.text('Day 2'));
    await tester.tap(find.text('Mark Complete'));
    await _pumpUntilFound(tester, find.text('Day 3 of 9'));

    preferences = await SharedPreferences.getInstance();
    expect(preferences.getStringList('completed_novena_days'), ['1', '2']);
  });
}

const _testMystery = RosaryMysteryModel(
  id: 'joyful_mysteries',
  language: 'en',
  title: 'Joyful Mysteries',
  description: "The joyful events of Christ's early life.",
  days: ['monday', 'saturday'],
  mysteries: [
    'The Annunciation',
    'The Visitation',
    'The Nativity',
    'The Presentation',
    'The Finding in the Temple',
  ],
);

const _testNovena = NovenaModel(
  id: 'divine_mercy_novena',
  language: 'en',
  title: 'Divine Mercy Novena',
  description: 'A nine-day Catholic devotion to Divine Mercy.',
  source: 'Traditional Catholic devotion',
  days: [
    NovenaDayModel(day: 1, title: 'Day 1', body: 'Day one prayer.'),
    NovenaDayModel(day: 2, title: 'Day 2', body: 'Day two prayer.'),
    NovenaDayModel(day: 3, title: 'Day 3', body: 'Day three prayer.'),
    NovenaDayModel(day: 4, title: 'Day 4', body: 'Day four prayer.'),
    NovenaDayModel(day: 5, title: 'Day 5', body: 'Day five prayer.'),
    NovenaDayModel(day: 6, title: 'Day 6', body: 'Day six prayer.'),
    NovenaDayModel(day: 7, title: 'Day 7', body: 'Day seven prayer.'),
    NovenaDayModel(day: 8, title: 'Day 8', body: 'Day eight prayer.'),
    NovenaDayModel(day: 9, title: 'Day 9', body: 'Day nine prayer.'),
  ],
);

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

class _FavoritesTestNotifier extends FavoritePrayerIdsNotifier {
  @override
  Future<Set<String>> build() async {
    return {'our_father', 'missing_prayer'};
  }

  @override
  Future<void> toggle(String prayerId) async {
    final current = state.asData?.value ?? await future;
    final updated = Set<String>.from(current);
    if (updated.contains(prayerId)) {
      updated.remove(prayerId);
    } else {
      updated.add(prayerId);
    }
    state = AsyncData(updated);
  }

  @override
  Future<void> remove(String prayerId) async {
    final current = state.asData?.value ?? await future;
    state = AsyncData(Set<String>.from(current)..remove(prayerId));
  }
}
