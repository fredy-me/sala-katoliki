import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/core/constants/app_constants.dart';
import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:salakatoliki/core/localization/supported_languages.dart';

import '../../tool/generate_localizations.dart' as generator;
import '../helpers/legacy_localized_strings.dart';

void main() {
  for (final languageCode in ['en', 'sw', 'unknown']) {
    test('central catalog preserves every legacy message in $languageCode', () {
      final strings = AppStrings(languageCode);
      final actual = <String, String>{
        'rosaryTitle_0': strings.rosaryTitle,
        'rosarySubtitle_0': strings.rosarySubtitle,
        'rosaryLoading_0': strings.rosaryLoading,
        'rosaryTodayMystery_0': strings.rosaryTodayMystery,
        'rosaryStart_0': strings.rosaryStart,
        'rosaryChoose_0': strings.rosaryChoose,
        'rosarySavedProgress_0': strings.rosarySavedProgress,
        'rosaryContinueLabel_0': strings.rosaryContinueLabel,
        'rosaryRestart_0': strings.rosaryRestart,
        'rosaryAllMysteries_0': strings.rosaryAllMysteries,
        'rosarySuggestedToday_0': strings.rosarySuggestedToday,
        'rosaryStepLabel_0': strings.rosaryStepLabel(0, 0),
        'rosaryStepLabel_1': strings.rosaryStepLabel(1, 1),
        'rosaryStepLabel_2': strings.rosaryStepLabel(2, 2),
        'rosaryStepLabel_3': strings.rosaryStepLabel(9, 9),
        'rosaryStepLabel_4': strings.rosaryStepLabel(12, 12),
        'rosaryStepLabel_5': strings.rosaryStepLabel(100, 100),
        'rosaryRetry_0': strings.rosaryRetry,
        'rosaryLoadErrorTitle_0': strings.rosaryLoadErrorTitle,
        'rosaryLoadErrorMessage_0': strings.rosaryLoadErrorMessage,
        'rosaryEmptyTitle_0': strings.rosaryEmptyTitle,
        'rosaryEmptyMessage_0': strings.rosaryEmptyMessage,
        'rosaryStepLoading_0': strings.rosaryStepLoading,
        'rosaryStepBack_0': strings.rosaryStepBack,
        'rosaryStepRestart_0': strings.rosaryStepRestart,
        'rosaryStepPrevious_0': strings.rosaryStepPrevious,
        'rosaryStepPause_0': strings.rosaryStepPause,
        'rosaryStepNext_0': strings.rosaryStepNext,
        'rosaryStepFinish_0': strings.rosaryStepFinish,
        'rosaryStepLitany_0': strings.rosaryStepLitany,
        'rosaryStepClosing_0': strings.rosaryStepClosing,
        'rosaryStepErrorTitle_0': strings.rosaryStepErrorTitle,
        'rosaryStepErrorMessage_0': strings.rosaryStepErrorMessage,
        'rosaryStepMissingTitle_0': strings.rosaryStepMissingTitle,
        'rosaryStepMissingMessage_0': strings.rosaryStepMissingMessage,
        'rosaryStepStepLabel_0': strings.rosaryStepStepLabel(0, 0),
        'rosaryStepStepLabel_1': strings.rosaryStepStepLabel(1, 1),
        'rosaryStepStepLabel_2': strings.rosaryStepStepLabel(2, 2),
        'rosaryStepStepLabel_3': strings.rosaryStepStepLabel(9, 9),
        'rosaryStepStepLabel_4': strings.rosaryStepStepLabel(12, 12),
        'rosaryStepStepLabel_5': strings.rosaryStepStepLabel(100, 100),
        'mysterySelectionTitle_0': strings.mysterySelectionTitle,
        'mysterySelectionLoading_0': strings.mysterySelectionLoading,
        'mysterySelectionSuggested_0': strings.mysterySelectionSuggested,
        'mysterySelectionBack_0': strings.mysterySelectionBack,
        'mysterySelectionErrorTitle_0': strings.mysterySelectionErrorTitle,
        'mysterySelectionErrorMessage_0': strings.mysterySelectionErrorMessage,
        'thanksgivingLoading_0': strings.thanksgivingLoading,
        'thanksgivingBack_0': strings.thanksgivingBack,
        'thanksgivingErrorTitle_0': strings.thanksgivingErrorTitle,
        'thanksgivingErrorMessage_0': strings.thanksgivingErrorMessage,
        'thanksgivingMissingTitle_0': strings.thanksgivingMissingTitle,
        'thanksgivingMissingMessage_0': strings.thanksgivingMissingMessage,
        'novenaDetailLoading_0': strings.novenaDetailLoading,
        'novenaDetailBack_0': strings.novenaDetailBack,
        'novenaDetailProgress_0': strings.novenaDetailProgress,
        'novenaDetailNotStarted_0': strings.novenaDetailNotStarted,
        'novenaDetailStartPrompt_0': strings.novenaDetailStartPrompt,
        'novenaDetailStart_0': strings.novenaDetailStart,
        'novenaDetailContinueDay_0': strings.novenaDetailContinueDay(0),
        'novenaDetailContinueDay_1': strings.novenaDetailContinueDay(1),
        'novenaDetailContinueDay_2': strings.novenaDetailContinueDay(2),
        'novenaDetailContinueDay_3': strings.novenaDetailContinueDay(9),
        'novenaDetailContinueDay_4': strings.novenaDetailContinueDay(12),
        'novenaDetailContinueDay_5': strings.novenaDetailContinueDay(100),
        'novenaDetailRestart_0': strings.novenaDetailRestart,
        'novenaDetailAfterNovena_0': strings.novenaDetailAfterNovena,
        'novenaDetailDayProgress_0': strings.novenaDetailDayProgress(0, 0),
        'novenaDetailDayProgress_1': strings.novenaDetailDayProgress(1, 1),
        'novenaDetailDayProgress_2': strings.novenaDetailDayProgress(2, 2),
        'novenaDetailDayProgress_3': strings.novenaDetailDayProgress(9, 9),
        'novenaDetailDayProgress_4': strings.novenaDetailDayProgress(12, 12),
        'novenaDetailDayProgress_5': strings.novenaDetailDayProgress(100, 100),
        'novenaDetailErrorTitle_0': strings.novenaDetailErrorTitle,
        'novenaDetailErrorMessage_0': strings.novenaDetailErrorMessage,
        'novenaDetailMissingTitle_0': strings.novenaDetailMissingTitle,
        'novenaDetailMissingMessage_0': strings.novenaDetailMissingMessage,
        'novenaDetailStatusCompleted_0': strings.novenaDetailStatusCompleted,
        'novenaDetailStatusCurrent_0': strings.novenaDetailStatusCurrent,
        'novenaDetailStatusOpen_0': strings.novenaDetailStatusOpen,
        'novenaDetailStatusLocked_0': strings.novenaDetailStatusLocked,
        'novenaDetailStatusNotStarted_0': strings.novenaDetailStatusNotStarted,
        'novenaDayLoading_0': strings.novenaDayLoading,
        'novenaDayBack_0': strings.novenaDayBack,
        'novenaDayCompleteDay_0': strings.novenaDayCompleteDay(0),
        'novenaDayCompleteDay_1': strings.novenaDayCompleteDay(1),
        'novenaDayCompleteDay_2': strings.novenaDayCompleteDay(2),
        'novenaDayCompleteDay_3': strings.novenaDayCompleteDay(9),
        'novenaDayCompleteDay_4': strings.novenaDayCompleteDay(12),
        'novenaDayCompleteDay_5': strings.novenaDayCompleteDay(100),
        'novenaDayCompleted_0': strings.novenaDayCompleted,
        'novenaDayDayLabel_0': strings.novenaDayDayLabel(0),
        'novenaDayDayLabel_1': strings.novenaDayDayLabel(1),
        'novenaDayDayLabel_2': strings.novenaDayDayLabel(2),
        'novenaDayDayLabel_3': strings.novenaDayDayLabel(9),
        'novenaDayDayLabel_4': strings.novenaDayDayLabel(12),
        'novenaDayDayLabel_5': strings.novenaDayDayLabel(100),
        'novenaDayDayProgress_0': strings.novenaDayDayProgress(0, 0),
        'novenaDayDayProgress_1': strings.novenaDayDayProgress(1, 1),
        'novenaDayDayProgress_2': strings.novenaDayDayProgress(2, 2),
        'novenaDayDayProgress_3': strings.novenaDayDayProgress(9, 9),
        'novenaDayDayProgress_4': strings.novenaDayDayProgress(12, 12),
        'novenaDayDayProgress_5': strings.novenaDayDayProgress(100, 100),
        'novenaDayChangeLanguage_0': strings.novenaDayChangeLanguage,
        'novenaDayShare_0': strings.novenaDayShare,
        'novenaDayRemoveFavorite_0': strings.novenaDayRemoveFavorite,
        'novenaDaySaveFavorite_0': strings.novenaDaySaveFavorite,
        'novenaDaySource_0': strings.novenaDaySource,
        'novenaDayShareFailed_0': strings.novenaDayShareFailed,
        'novenaDayErrorTitle_0': strings.novenaDayErrorTitle,
        'novenaDayErrorMessage_0': strings.novenaDayErrorMessage,
        'novenaDayMissingTitle_0': strings.novenaDayMissingTitle,
        'novenaDayMissingMessage_0': strings.novenaDayMissingMessage,
        'novenaDayLanguageChanged_0': strings.novenaDayLanguageChanged("en"),
        'novenaDayLanguageChanged_1': strings.novenaDayLanguageChanged("sw"),
        'novenaDayLanguageChanged_2': strings.novenaDayLanguageChanged("fr"),
        'novenasTitle_0': strings.novenasTitle,
        'novenasSubtitle_0': strings.novenasSubtitle,
        'novenasLoading_0': strings.novenasLoading,
        'novenasActiveNovena_0': strings.novenasActiveNovena,
        'novenasBrowse_0': strings.novenasBrowse,
        'novenasContinueLabel_0': strings.novenasContinueLabel,
        'novenasView_0': strings.novenasView,
        'novenasInProgress_0': strings.novenasInProgress,
        'novenasRetry_0': strings.novenasRetry,
        'novenasDayProgress_0': strings.novenasDayProgress(0, 0),
        'novenasDayProgress_1': strings.novenasDayProgress(1, 1),
        'novenasDayProgress_2': strings.novenasDayProgress(2, 2),
        'novenasDayProgress_3': strings.novenasDayProgress(9, 9),
        'novenasDayProgress_4': strings.novenasDayProgress(12, 12),
        'novenasDayProgress_5': strings.novenasDayProgress(100, 100),
        'novenasErrorTitle_0': strings.novenasErrorTitle,
        'novenasErrorMessage_0': strings.novenasErrorMessage,
        'novenasEmptyTitle_0': strings.novenasEmptyTitle,
        'novenasEmptyMessage_0': strings.novenasEmptyMessage,
        'closingPrayerLoading_0': strings.closingPrayerLoading,
        'closingPrayerBack_0': strings.closingPrayerBack,
        'closingPrayerErrorTitle_0': strings.closingPrayerErrorTitle,
        'closingPrayerErrorMessage_0': strings.closingPrayerErrorMessage,
        'closingPrayerMissingTitle_0': strings.closingPrayerMissingTitle,
        'closingPrayerMissingMessage_0': strings.closingPrayerMissingMessage,
        'favoritesTitle_0': strings.favoritesTitle,
        'favoritesSubtitle_0': strings.favoritesSubtitle(0),
        'favoritesSubtitle_1': strings.favoritesSubtitle(1),
        'favoritesSubtitle_2': strings.favoritesSubtitle(2),
        'favoritesSubtitle_3': strings.favoritesSubtitle(9),
        'favoritesSubtitle_4': strings.favoritesSubtitle(12),
        'favoritesSubtitle_5': strings.favoritesSubtitle(100),
        'favoritesLoading_0': strings.favoritesLoading,
        'favoritesSearchHint_0': strings.favoritesSearchHint,
        'favoritesEmptyTitle_0': strings.favoritesEmptyTitle,
        'favoritesEmptyMessage_0': strings.favoritesEmptyMessage,
        'favoritesNoSearchResults_0': strings.favoritesNoSearchResults,
        'favoritesLoadErrorTitle_0': strings.favoritesLoadErrorTitle,
        'favoritesLoadErrorMessage_0': strings.favoritesLoadErrorMessage,
        'favoritesBack_0': strings.favoritesBack,
        'prayerLibraryTitle_0': strings.prayerLibraryTitle,
        'prayerLibrarySubtitle_0': strings.prayerLibrarySubtitle,
        'prayerLibraryLoading_0': strings.prayerLibraryLoading,
        'prayerLibrarySearchHint_0': strings.prayerLibrarySearchHint,
        'prayerLibraryCorePrayers_0': strings.prayerLibraryCorePrayers,
        'prayerLibraryMarianAndRosary_0': strings.prayerLibraryMarianAndRosary,
        'prayerLibraryDevotions_0': strings.prayerLibraryDevotions,
        'prayerLibraryRosaryAndMysteries_0':
            strings.prayerLibraryRosaryAndMysteries,
        'prayerLibraryRosaryAndMysteriesDescription_0':
            strings.prayerLibraryRosaryAndMysteriesDescription,
        'prayerLibraryDivineMercyRosary_0':
            strings.prayerLibraryDivineMercyRosary,
        'prayerLibraryDivineMercyRosaryDescription_0':
            strings.prayerLibraryDivineMercyRosaryDescription,
        'prayerLibraryComingSoon_0': strings.prayerLibraryComingSoon,
        'prayerLibraryNoSearchResults_0': strings.prayerLibraryNoSearchResults,
        'prayerLibraryLoadErrorTitle_0': strings.prayerLibraryLoadErrorTitle,
        'prayerLibraryLoadErrorMessage_0':
            strings.prayerLibraryLoadErrorMessage,
        'prayerLibraryCategoriesErrorTitle_0':
            strings.prayerLibraryCategoriesErrorTitle,
        'prayerLibraryCategoriesErrorMessage_0':
            strings.prayerLibraryCategoriesErrorMessage,
        'prayerLibraryRetry_0': strings.prayerLibraryRetry,
        'prayerLibraryCountLabel_0': strings.prayerLibraryCountLabel(0),
        'prayerLibraryCountLabel_1': strings.prayerLibraryCountLabel(1),
        'prayerLibraryCountLabel_2': strings.prayerLibraryCountLabel(2),
        'prayerLibraryCountLabel_3': strings.prayerLibraryCountLabel(9),
        'prayerLibraryCountLabel_4': strings.prayerLibraryCountLabel(12),
        'prayerLibraryCountLabel_5': strings.prayerLibraryCountLabel(100),
        'prayerDetailLoading_0': strings.prayerDetailLoading,
        'prayerDetailNotFoundTitle_0': strings.prayerDetailNotFoundTitle,
        'prayerDetailLoadErrorMessage_0': strings.prayerDetailLoadErrorMessage,
        'prayerDetailMissingMessage_0': strings.prayerDetailMissingMessage,
        'prayerDetailBack_0': strings.prayerDetailBack,
        'prayerDetailChangeLanguage_0': strings.prayerDetailChangeLanguage,
        'prayerDetailShare_0': strings.prayerDetailShare,
        'prayerDetailRemoveFavorite_0': strings.prayerDetailRemoveFavorite,
        'prayerDetailSaveFavorite_0': strings.prayerDetailSaveFavorite,
        'prayerDetailSource_0': strings.prayerDetailSource,
        'prayerDetailDefaultSource_0': strings.prayerDetailDefaultSource,
        'prayerDetailShareFailed_0': strings.prayerDetailShareFailed,
        'prayerDetailLanguageChanged_0': strings.prayerDetailLanguageChanged(
          "en",
        ),
        'prayerDetailLanguageChanged_1': strings.prayerDetailLanguageChanged(
          "sw",
        ),
        'prayerDetailLanguageChanged_2': strings.prayerDetailLanguageChanged(
          "fr",
        ),
        'settingsTitle_0': strings.settingsTitle,
        'settingsLoading_0': strings.settingsLoading,
        'settingsLoadError_0': strings.settingsLoadError,
        'settingsPreferences_0': strings.settingsPreferences,
        'settingsSupportInfo_0': strings.settingsSupportInfo,
        'settingsLanguage_0': strings.settingsLanguage,
        'settingsLanguageSubtitle_0': strings.settingsLanguageSubtitle,
        'settingsReminders_0': strings.settingsReminders,
        'settingsDailyReminder_0': strings.settingsDailyReminder,
        'settingsReminderSubtitle_0': strings.settingsReminderSubtitle,
        'settingsReminderEnabled_0': strings.settingsReminderEnabled("08:30"),
        'settingsReminderEnabled_1': strings.settingsReminderEnabled("08:30"),
        'settingsReminderEnabled_2': strings.settingsReminderEnabled("08:30"),
        'settingsReminderEnabled_3': strings.settingsReminderEnabled("08:30"),
        'settingsReminderEnabled_4': strings.settingsReminderEnabled("08:30"),
        'settingsReminderEnabled_5': strings.settingsReminderEnabled("08:30"),
        'settingsReminderDisabled_0': strings.settingsReminderDisabled,
        'settingsChangeTime_0': strings.settingsChangeTime,
        'settingsPermissionDenied_0': strings.settingsPermissionDenied,
        'settingsFontSize_0': strings.settingsFontSize,
        'settingsFontSizeSubtitle_0': strings.settingsFontSizeSubtitle,
        'settingsSmall_0': strings.settingsSmall,
        'settingsMedium_0': strings.settingsMedium,
        'settingsLarge_0': strings.settingsLarge,
        'settingsTheme_0': strings.settingsTheme,
        'settingsThemeSubtitle_0': strings.settingsThemeSubtitle,
        'settingsSystem_0': strings.settingsSystem,
        'settingsLight_0': strings.settingsLight,
        'settingsDark_0': strings.settingsDark,
        'settingsInformation_0': strings.settingsInformation,
        'settingsAbout_0': strings.settingsAbout,
        'settingsAboutSubtitle_0': strings.settingsAboutSubtitle,
        'settingsPrivacyTitle_0': strings.settingsPrivacyTitle,
        'settingsPrivacySubtitle_0': strings.settingsPrivacySubtitle,
        'aboutTitle_0': strings.aboutTitle,
        'aboutBack_0': strings.aboutBack,
        'aboutVersion_0': strings.aboutVersion(AppConstants.appVersion),
        'aboutIntroduction_0': strings.aboutIntroduction,
        'aboutAboutTitle_0': strings.aboutAboutTitle,
        'aboutAboutBody_0': strings.aboutAboutBody,
        'aboutAboutDetailsTitle_0': strings.aboutAboutDetailsTitle,
        'aboutAboutDetailsBody_0': strings.aboutAboutDetailsBody,
        'aboutDeveloperTitle_0': strings.aboutDeveloperTitle,
        'aboutDeveloperBody_0': strings.aboutDeveloperBody,
        'aboutContentSourcesTitle_0': strings.aboutContentSourcesTitle,
        'aboutContentSourcesBody_0': strings.aboutContentSourcesBody,
        'aboutContentSourcesDetailsBody_0':
            strings.aboutContentSourcesDetailsBody,
        'aboutDisclaimerTitle_0': strings.aboutDisclaimerTitle,
        'aboutDisclaimerBody_0': strings.aboutDisclaimerBody,
        'aboutContact_0': strings.aboutContact,
        'aboutContactTitle_0': strings.aboutContactTitle,
        'aboutContactBody_0': strings.aboutContactBody,
        'aboutRateAppLabel_0': strings.aboutRateAppLabel,
        'aboutEmailLabel_0': strings.aboutEmailLabel,
        'aboutCopyright_0': strings.aboutCopyright,
        'aboutContactOpenError_0': strings.aboutContactOpenError,
        'aboutPlayStoreOpenError_0': strings.aboutPlayStoreOpenError,
        'reminderNotificationTitle_0': strings.reminderNotificationTitle,
        'reminderNotificationBody_0': strings.reminderNotificationBody,
        'todayLoading_0': strings.todayLoading,
        'todayEyebrow_0': strings.todayEyebrow,
        'todayTodaysPrayer_0': strings.todayTodaysPrayer,
        'todayNoDailyPrayerTitle_0': strings.todayNoDailyPrayerTitle,
        'todayNoDailyPrayerBody_0': strings.todayNoDailyPrayerBody,
        'todayPrayNow_0': strings.todayPrayNow,
        'todayQuickActions_0': strings.todayQuickActions,
        'todayContinueNovena_0': strings.todayContinueNovena,
        'todayActiveNovenaUnavailable_0': strings.todayActiveNovenaUnavailable,
        'todayContinueAction_0': strings.todayContinueAction,
        'todayNovenas_0': strings.todayNovenas,
        'todayNoActiveNovena_0': strings.todayNoActiveNovena,
        'todayBrowse_0': strings.todayBrowse,
        'todayDayProgress_0': strings.todayDayProgress(0, 0),
        'todayDayProgress_1': strings.todayDayProgress(1, 1),
        'todayDayProgress_2': strings.todayDayProgress(2, 2),
        'todayDayProgress_3': strings.todayDayProgress(9, 9),
        'todayDayProgress_4': strings.todayDayProgress(12, 12),
        'todayDayProgress_5': strings.todayDayProgress(100, 100),
        'todayRosaryToday_0': strings.todayRosaryToday,
        'todaySuggestedMystery_0': strings.todaySuggestedMystery,
        'todayTodayDay_0': strings.todayTodayDay,
        'todayStartRosary_0': strings.todayStartRosary,
        'todayCommonPrayers_0': strings.todayCommonPrayers,
        'todayRecentlyOpened_0': strings.todayRecentlyOpened,
        'todayFavorites_0': strings.todayFavorites,
        'todayReminderEnabled_0': strings.todayReminderEnabled("08:30"),
        'todayReminderEnabled_1': strings.todayReminderEnabled("08:30"),
        'todayReminderEnabled_2': strings.todayReminderEnabled("08:30"),
        'todayReminderEnabled_3': strings.todayReminderEnabled("08:30"),
        'todayReminderEnabled_4': strings.todayReminderEnabled("08:30"),
        'todayReminderEnabled_5': strings.todayReminderEnabled("08:30"),
        'todayReminderDisabled_0': strings.todayReminderDisabled,
        'todayAvailableOffline_0': strings.todayAvailableOffline,
        'todayEdit_0': strings.todayEdit,
        'legalLinksNote_0': strings.legalLinksNote,
        'legalLinksPrivacyPolicy_0': strings.legalLinksPrivacyPolicy,
        'legalLinksTermsOfService_0': strings.legalLinksTermsOfService,
        'legalLinksContentDisclaimer_0': strings.legalLinksContentDisclaimer,
        'bottomNavToday_0': strings.bottomNavToday,
        'bottomNavPray_0': strings.bottomNavPray,
        'bottomNavNovenas_0': strings.bottomNavNovenas,
        'bottomNavSettings_0': strings.bottomNavSettings,
        'bottomNavExitPrompt_0': strings.bottomNavExitPrompt,
        'settingsTextSizeSmall': strings.settingsSmall,
        'settingsTextSizeMedium': strings.settingsMedium,
        'settingsTextSizeLarge': strings.settingsLarge,
      };
      expect(actual, legacyLocalizedMessages(languageCode));
    });
  }

  test(
    'screens and services do not reintroduce private translation classes',
    () {
      final duplicate = RegExp(r'class _[A-Za-z0-9]+Strings\b|bool get _sw');
      for (final file in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        if (file.path.endsWith('.dart')) {
          expect(
            duplicate.hasMatch(file.readAsStringSync()),
            isFalse,
            reason: file.path,
          );
        }
      }
    },
  );

  test('catalog coverage, fallback, and argument substitution', () {
    expect(
      AppStrings.availableLanguages.toSet(),
      SupportedLanguages.all.map((language) => language.code).toSet(),
    );
    expect(
      identical(AppStrings.of('unsupported'), AppStrings.of('en')),
      isTrue,
    );
    expect(identical(AppStrings.of('sw'), AppStrings.of('sw')), isTrue);
    expect(
      const AppStrings('en').settingsReminderEnabled('{count}'),
      'Set for {count}',
    );
    expect(
      const AppStrings('en').prayerListSearchHint('A \$ B'),
      'Search in A \$ B...',
    );
    expect(const AppStrings('sw').onboardingContinueLabel, 'Endelea');
    expect(const AppStrings('en').homeWidgetLabel, "TODAY'S PRAYER");
    expect(const AppStrings('sw').homeWidgetLabel, 'SALA YA LEO');
  });

  test('committed localization output matches validated source catalogs', () {
    final generated = generator.generateLocalizations(
      Directory(generator.catalogDirectory),
    );
    expect(File(generator.generatedPath).readAsStringSync(), generated);
  });

  group('localization authoring', () {
    late Directory fixture;
    setUp(() {
      fixture = Directory.systemTemp.createTempSync('sala-locales-');
      for (final file in Directory(
        generator.catalogDirectory,
      ).listSync().whereType<File>()) {
        file.copySync('${fixture.path}/${file.uri.pathSegments.last}');
      }
    });
    tearDown(() => fixture.deleteSync(recursive: true));
    Map<String, dynamic> read(String language) =>
        jsonDecode(File('${fixture.path}/$language.json').readAsStringSync())
            as Map<String, dynamic>;
    void write(String language, Map<String, dynamic> value) => File(
      '${fixture.path}/$language.json',
    ).writeAsStringSync(jsonEncode(value));

    test(
      'a third catalog generates the same API without new screen classes',
      () {
        final catalog = read('en');
        catalog['locale'] = 'fr';
        (catalog['messages'] as Map)['today.eyebrow'] = 'PAIX AVEC VOUS';
        write('fr', catalog);
        final arabicProbe = read('en');
        arabicProbe['locale'] = 'ar';
        ((arabicProbe['messages'] as Map)['novenaDay.dayProgress']
            as Map)['parameters'] = {
          'totalDays': 'int',
          'day': 'int',
        };
        write('ar', arabicProbe);
        final result = generator.generateLocalizations(fixture);
        expect(result, contains('"fr"'));
        expect(result, contains('PAIX AVEC VOUS'));
        expect(
          result,
          contains('novenaDayDayProgress(int day, int totalDays)'),
        );
        expect(RegExp(r'mixin _AppMessages').allMatches(result).length, 1);
      },
    );

    test('missing translation keys fail instead of silently falling back', () {
      final catalog = read('sw');
      (catalog['messages'] as Map).remove('today.loading');
      write('sw', catalog);
      expect(
        () => generator.generateLocalizations(fixture),
        throwsFormatException,
      );
    });

    test('wrong placeholders, parameter types, and selectors fail', () {
      for (final value in [
        {
          'text': 'Day {unknown}',
          'parameters': {'day': 'int'},
        },
        {
          'text': 'Day {day}',
          'parameters': {'day': 'String'},
        },
        {
          'select': 'day',
          'cases': {'en': 'Day'},
          'parameters': {'day': 'int'},
        },
      ]) {
        final catalog = read('sw');
        (catalog['messages'] as Map)['novenaDay.dayLabel'] = value;
        write('sw', catalog);
        expect(
          () => generator.generateLocalizations(fixture),
          throwsFormatException,
        );
      }
    });
  });
}
