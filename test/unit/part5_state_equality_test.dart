import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/data/models/rosary_model.dart';
import 'package:salakatoliki/features/novenas/domain/novena_state.dart';
import 'package:salakatoliki/features/prayers/domain/entities/prayer_entity.dart';
import 'package:salakatoliki/features/rosary/domain/rosary_state.dart';
import 'package:salakatoliki/features/settings/presentation/providers/settings_providers.dart';
import 'package:salakatoliki/features/today/presentation/providers/today_providers.dart';

/// 5.6. The risk in adding value equality is not a wrong `==`, it is a `==`
/// that is too coarse: a state object that is mutated in place and re-assigned
/// would now compare equal to itself and silently suppress the rebuild. These
/// tests therefore check both directions — that identical values compare equal,
/// and that any single differing field still compares unequal.
void main() {
  group('UserSettings', () {
    UserSettings make({
      ThemeMode mode = ThemeMode.system,
      double scale = 1,
      bool enabled = false,
      String time = '06:00',
      bool denied = false,
    }) {
      return UserSettings(
        themeMode: mode,
        fontScale: scale,
        reminderEnabled: enabled,
        reminderTime: time,
        permissionDenied: denied,
      );
    }

    test('two identical instances are equal', () {
      expect(make(), make());
      expect(make().hashCode, make().hashCode);
    });

    test('every single field distinguishes', () {
      final base = make();
      expect(base == make(mode: ThemeMode.dark), isFalse);
      expect(base == make(scale: 1.5), isFalse);
      expect(base == make(enabled: true), isFalse);
      expect(base == make(time: '07:00'), isFalse);
      expect(base == make(denied: true), isFalse);
    });

    test('copyWith with an unchanged field still equals the original', () {
      // This is the whole point: the notifier rebuilds the object on every
      // write, and an unchanged write must not look like a change.
      final base = make();
      expect(base.copyWith(), base);
      expect(base.copyWith(themeMode: ThemeMode.system), base);
      expect(base.copyWith(themeMode: ThemeMode.light), isNot(base));
    });
  });

  group('TodayLocalState', () {
    TodayLocalState make({
      String? id = 'st_rita_novena',
      Set<int> days = const {1, 2},
      bool enabled = true,
      String? time = '06:00',
    }) {
      return TodayLocalState(
        activeNovenaId: id,
        completedNovenaDays: days,
        reminderEnabled: enabled,
        reminderTime: time,
      );
    }

    test('set order does not affect equality', () {
      expect(make(days: {1, 2}), make(days: {2, 1}));
      expect(make(days: {1, 2}).hashCode, make(days: {2, 1}).hashCode);
    });

    test('a different day set is a different state', () {
      expect(make(days: {1, 2}) == make(days: {1}), isFalse);
      expect(make(days: {1, 2}) == make(days: {1, 2, 3}), isFalse);
    });

    test('every other field distinguishes', () {
      final base = make();
      expect(base == make(id: null), isFalse);
      expect(base == make(id: 'divine_mercy_novena'), isFalse);
      expect(base == make(enabled: false), isFalse);
      expect(base == make(time: '07:00'), isFalse);
    });
  });

  group('NovenaProgress', () {
    NovenaProgress make({
      String? active = 'st_rita_novena',
      Map<String, Set<int>>? byId,
    }) {
      return NovenaProgress(
        activeNovenaId: active,
        completedDaysByNovenaId: byId ?? {'st_rita_novena': {1, 2}},
      );
    }

    test('identical values are equal', () {
      expect(make(), make());
      expect(make().hashCode, make().hashCode);
    });

    test('inner set order does not matter, contents do', () {
      expect(make(byId: {'a': {1, 2}}), make(byId: {'a': {2, 1}}));
      expect(make(byId: {'a': {1, 2}}) == make(byId: {'a': {1}}), isFalse);
    });

    test('outer map order does not matter, keys do', () {
      expect(
        make(byId: {'a': {1}, 'b': {2}}),
        make(byId: {'b': {2}, 'a': {1}}),
      );
      expect(
        make(byId: {'a': {1}}) == make(byId: {'a': {1}, 'b': {2}}),
        isFalse,
      );
      expect(make(byId: {'a': {1}}) == make(byId: {'c': {1}}), isFalse);
    });

    test('the active id distinguishes', () {
      expect(
        make(active: 'a') == make(active: 'b', byId: {'a': {1, 2}}),
        isFalse,
      );
      expect(make(active: null) == make(), isFalse);
    });

    test('a copied-and-restored progress equals the original', () {
      // The notifier mutates a deep copy, so writing the same days back must
      // land on an equal state rather than a different one.
      final base = make();
      final copy = <String, Set<int>>{
        for (final e in base.completedDaysByNovenaId.entries)
          e.key: {...e.value},
      };
      final same = NovenaProgress(
        activeNovenaId: base.activeNovenaId,
        completedDaysByNovenaId: copy,
      );
      expect(same, base);
      expect(same.hashCode, base.hashCode);
    });
  });

  group('RosarySession and RosaryProgress', () {
    final mystery = RosaryMysteryModel(
      id: 'joyful',
      language: 'en',
      title: 'Joyful',
      description: '',
      days: const ['1'],
      mysteries: const [],
    );
    final prayer = PrayerEntity(
      id: 'hail_mary',
      type: 'prayer',
      categoryId: 'marian',
      language: 'en',
      localizedTitle: 'Hail Mary',
      body: '',
      categoryTitles: const {},
    );

    RosaryStep step(int index) {
      return RosaryStep(
        index: index,
        prayer: prayer,
        decadeIndex: 0,
        beadNumber: 1,
        beadTotal: 1,
      );
    }

    RosarySession session(int index, {RosaryMysteryModel? m}) {
      return RosarySession(
        mystery: m ?? mystery,
        steps: [step(0), step(1)],
        stepIndex: index,
      );
    }

    test('the same session value is equal', () {
      expect(session(1), session(1));
      expect(session(1).hashCode, session(1).hashCode);
    });

    test('the step index distinguishes', () {
      expect(session(0) == session(1), isFalse);
    });

    test('a different mystery distinguishes', () {
      final other = RosaryMysteryModel(
        id: 'sorrowful',
        language: 'en',
        title: 'Sorrowful',
        description: '',
        days: const ['1'],
        mysteries: const [],
      );
      expect(session(0) == session(0, m: other), isFalse);
    });

    test('RosaryProgress compares by value', () {
      expect(
        const RosaryProgress(mysteryId: 'joyful', stepIndex: 2),
        const RosaryProgress(mysteryId: 'joyful', stepIndex: 2),
      );
      expect(
        const RosaryProgress(mysteryId: 'joyful', stepIndex: 2) ==
            const RosaryProgress(mysteryId: 'joyful', stepIndex: 3),
        isFalse,
      );
      expect(
        const RosaryProgress(mysteryId: 'joyful', stepIndex: 2) ==
            const RosaryProgress(mysteryId: 'sorrowful', stepIndex: 2),
        isFalse,
      );
    });
  });

  group('rootSettingsProvider (5.5)', () {
    // `userSettingsProvider` is an AsyncNotifier, so the record only reflects
    // the real settings once the notifier has produced its first value.
    // Reading it synchronously would always see the loading state.
    Future<RootSettings> readWith(UserSettings settings) async {
      final container = ProviderContainer(
        overrides: [userSettingsProvider.overrideWith(() => _Fixed(settings))],
      );
      addTearDown(container.dispose);
      await container.read(userSettingsProvider.future);
      return container.read(rootSettingsProvider);
    }

    test('falls back to the defaults before settings resolve', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(rootSettingsProvider),
        (themeMode: ThemeMode.system, fontScale: 1.0),
      );
    });

    test('carries exactly the two fields the root renders', () async {
      expect(
        await readWith(
          const UserSettings(
            themeMode: ThemeMode.dark,
            fontScale: 1.5,
            reminderEnabled: false,
            reminderTime: '06:00',
            permissionDenied: false,
          ),
        ),
        (themeMode: ThemeMode.dark, fontScale: 1.5),
      );
    });

    test('a reminder-only change produces an identical root value', () async {
      // The whole point of 5.5: these two settings differ only in fields the
      // app root never renders, so the record must compare equal and the
      // router must not rebuild.
      final before = await readWith(
        const UserSettings(
          themeMode: ThemeMode.system,
          fontScale: 1,
          reminderEnabled: false,
          reminderTime: '06:00',
          permissionDenied: false,
        ),
      );
      final after = await readWith(
        const UserSettings(
          themeMode: ThemeMode.system,
          fontScale: 1,
          reminderEnabled: true,
          reminderTime: '07:30',
          permissionDenied: true,
        ),
      );
      expect(after, before);
    });

    test('a theme or scale change does alter the root value', () async {
      final base = await readWith(
        const UserSettings(
          themeMode: ThemeMode.system,
          fontScale: 1,
          reminderEnabled: false,
          reminderTime: '06:00',
          permissionDenied: false,
        ),
      );
      expect(
        await readWith(
          const UserSettings(
            themeMode: ThemeMode.dark,
            fontScale: 1,
            reminderEnabled: false,
            reminderTime: '06:00',
            permissionDenied: false,
          ),
        ),
        isNot(base),
      );
      expect(
        await readWith(
          const UserSettings(
            themeMode: ThemeMode.system,
            fontScale: 1.5,
            reminderEnabled: false,
            reminderTime: '06:00',
            permissionDenied: false,
          ),
        ),
        isNot(base),
      );
    });
  });
}

/// A notifier that yields a settings object chosen by the test, so the
/// provider can be read without any storage behind it.
class _Fixed extends UserSettingsNotifier {
  _Fixed(this.value);

  final UserSettings value;

  @override
  Future<UserSettings> build() async => value;
}
