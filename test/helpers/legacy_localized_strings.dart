// Frozen pre-consolidation strings, used only to verify unchanged translations.
import 'package:salakatoliki/core/constants/app_constants.dart';
import 'package:salakatoliki/features/novenas/domain/novena_state.dart';

enum _TextSizeValue { small, medium, large }

class _RosaryStrings {
  const _RosaryStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Rozari ya Bikira Maria' : 'Rosary of Mary';
  String get subtitle => _sw
      ? 'Fuata matendo, fadhila, na sala kwa mpangilio.'
      : 'Follow the mysteries, virtues, and prayers in order.';
  String get loading => _sw ? 'Inapakia rozari...' : 'Loading Rosary...';
  String get todayMystery => _sw ? 'Fumbo la Leo' : "Today's Mystery";
  String get start => _sw ? 'Anza' : 'Start';
  String get choose => _sw ? 'Chagua' : 'Choose';
  String get savedProgress =>
      _sw ? 'Maendeleo Yaliyohifadhiwa' : 'Saved Progress';
  String get continueLabel => _sw ? 'Endelea' : 'Continue';
  String get restart => _sw ? 'Anza Upya' : 'Restart';
  String get allMysteries => _sw ? 'Mafumbo Yote' : 'All Mysteries';
  String get suggestedToday => _sw ? 'Limependekezwa leo' : 'Suggested today';
  String stepLabel(int current, int total) =>
      _sw ? 'Hatua $current kati ya $total' : 'Step $current of $total';
  String get retry => _sw ? 'Jaribu tena' : 'Retry';
  String get loadErrorTitle =>
      _sw ? 'Rozari haijapakia' : 'Rosary did not load';
  String get loadErrorMessage => _sw
      ? 'Kuna tatizo kusoma maudhui ya rozari ya ndani.'
      : 'There was a problem reading local Rosary content.';
  String get emptyTitle =>
      _sw ? 'Hakuna maudhui ya rozari' : 'No Rosary content';
  String get emptyMessage => _sw
      ? 'Mafumbo ya rozari hayajapatikana kwenye maudhui ya ndani.'
      : 'Rosary mysteries were not found in local content.';
}

class _RosaryStepStrings {
  const _RosaryStepStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia hatua...' : 'Loading step...';
  String get back => _sw ? 'Rudi' : 'Back';
  String get restart => _sw ? 'Anza Upya' : 'Restart';
  String get previous => _sw ? 'Iliyotangulia' : 'Previous';
  String get pause => _sw ? 'Sitisha' : 'Pause';
  String get next => _sw ? 'Inayofuata' : 'Next';
  String get finish => _sw ? 'Maliza' : 'Finish';
  String get litany => _sw ? 'Litania' : 'Litany';
  String get closing => _sw ? 'Hitimisho' : 'Closing';
  String get errorTitle => _sw ? 'Rozari haijapakia' : 'Rosary did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma hatua za rozari.'
      : 'There was a problem reading Rosary steps.';
  String get missingTitle =>
      _sw ? 'Maendeleo yameondolewa' : 'Progress was reset';
  String get missingMessage => _sw
      ? 'Maendeleo ya zamani hayakulingana na maudhui ya sasa.'
      : 'Saved progress did not match the current Rosary content.';
  String stepLabel(int current, int total) =>
      _sw ? 'Hatua $current kati ya $total' : 'Step $current of $total';
}

class _MysterySelectionStrings {
  const _MysterySelectionStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Chagua Mafumbo' : 'Choose Mysteries';
  String get loading => _sw ? 'Inapakia mafumbo...' : 'Loading mysteries...';
  String get suggested => _sw ? 'Limependekezwa leo' : 'Suggested today';
  String get back => _sw ? 'Rudi' : 'Back';
  String get errorTitle =>
      _sw ? 'Mafumbo hayajapakia' : 'Mysteries did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma mafumbo ya rozari.'
      : 'There was a problem reading Rosary mysteries.';
}

class _ThanksgivingStrings {
  const _ThanksgivingStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading =>
      _sw ? 'Inapakia shukrani...' : 'Loading thanksgiving...';
  String get back => _sw ? 'Rudi' : 'Back';
  String get errorTitle =>
      _sw ? 'Shukrani haijapakia' : 'Thanksgiving did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma sehemu hii.'
      : 'There was a problem reading this section.';
  String get missingTitle => _sw ? 'Sehemu haikupatikana' : 'Section not found';
  String get missingMessage => _sw
      ? 'Sehemu hii haipo kwenye novena hii.'
      : 'This section is not available for this novena.';
}

class _NovenaDetailStrings {
  const _NovenaDetailStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia novena...' : 'Loading novena...';
  String get back => _sw ? 'Rudi' : 'Back';
  String get progress => _sw ? 'Maendeleo' : 'Progress';
  String get notStarted => _sw ? 'Haijaanza' : 'Not Started';
  String get startPrompt => _sw ? 'Anza Siku ya 1' : 'Start Day 1';
  String get start => _sw ? 'Anza Novena' : 'Start Novena';
  String continueDay(int day) =>
      _sw ? 'Endelea Siku ya $day' : 'Continue to Day $day';
  String get restart => _sw ? 'Anza Upya' : 'Restart';
  String get afterNovena => _sw ? 'Baada ya Novena' : 'After the Novena';
  String dayProgress(int day, int totalDays) =>
      _sw ? 'Siku ya $day kati ya $totalDays' : 'Day $day of $totalDays';
  String get errorTitle => _sw ? 'Novena haijapakia' : 'Novena did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma novena hii.'
      : 'There was a problem reading this novena.';
  String get missingTitle => _sw ? 'Novena haikupatikana' : 'Novena not found';
  String get missingMessage =>
      _sw ? 'Jaribu kuchagua novena nyingine.' : 'Try choosing another novena.';

  String statusLabel(NovenaDayStatus status) {
    return switch (status) {
      NovenaDayStatus.completed => _sw ? 'Imekamilika' : 'Completed',
      NovenaDayStatus.current => _sw ? 'Siku ya sasa' : 'Current day',
      NovenaDayStatus.open => _sw ? 'Fungua' : 'Open',
      NovenaDayStatus.locked => _sw ? 'Imefungwa' : 'Locked',
      NovenaDayStatus.notStarted => _sw ? 'Haijaanza' : 'Not started',
    };
  }
}

class _NovenaDayStrings {
  const _NovenaDayStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia siku...' : 'Loading day...';
  String get back => _sw ? 'Rudi' : 'Back';
  String completeDay(int day) =>
      _sw ? 'Nimemaliza Siku $day' : 'Complete Day $day';
  String get completed => _sw ? 'Imekamilika' : 'Completed';
  String dayLabel(int day) => _sw ? 'Siku ya $day' : 'Day $day';
  String dayProgress(int day, int totalDays) =>
      _sw ? 'Siku ya $day kati ya $totalDays' : 'Day $day of $totalDays';
  String get changeLanguage => _sw ? 'Badili lugha' : 'Change language';
  String get share => _sw ? 'Shiriki' : 'Share';
  String get removeFavorite => _sw ? 'Ondoa kipendwa' : 'Remove favorite';
  String get saveFavorite => _sw ? 'Hifadhi' : 'Save';
  String get source => _sw ? 'Chanzo' : 'Source';
  String get shareFailed => _sw
      ? 'Imeshindikana kushiriki novena hii.'
      : 'Could not share this novena.';
  String get errorTitle => _sw ? 'Siku haijapakia' : 'Day did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma siku hii ya novena.'
      : 'There was a problem reading this novena day.';
  String get missingTitle => _sw ? 'Siku haikupatikana' : 'Day not found';
  String get missingMessage => _sw
      ? 'Siku hii haipo kwenye novena hii.'
      : 'This day is not available in this novena.';

  String languageChanged(String nextLanguageCode) {
    if (nextLanguageCode == 'sw') {
      return _sw
          ? 'Lugha imebadilishwa kwenda Kiswahili.'
          : 'Language changed to Kiswahili.';
    }

    return _sw
        ? 'Lugha imebadilishwa kwenda Kiingereza.'
        : 'Language changed to English.';
  }
}

class _NovenasStrings {
  const _NovenasStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Novenas' : 'Novenas';
  String get subtitle => _sw
      ? 'Ibada za siku tisa zenye maendeleo ya ndani.'
      : 'Nine-day devotions with local progress.';
  String get loading => _sw ? 'Inapakia novenas...' : 'Loading novenas...';
  String get activeNovena => _sw ? 'Novena Inayoendelea' : 'Active Novena';
  String get browse => _sw ? 'Vinjari Novenas' : 'Browse Novenas';
  String get continueLabel => _sw ? 'Endelea' : 'Continue';
  String get view => _sw ? 'Tazama' : 'View';
  String get inProgress => _sw ? 'Inaendelea' : 'In progress';
  String get retry => _sw ? 'Jaribu tena' : 'Retry';
  String dayProgress(int day, int totalDays) =>
      _sw ? 'Siku ya $day kati ya $totalDays' : 'Day $day of $totalDays';
  String get errorTitle => _sw ? 'Novenas hazijapakia' : 'Novenas did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma novenas za ndani.'
      : 'There was a problem reading local novenas.';
  String get emptyTitle => _sw ? 'Hakuna novenas' : 'No novenas';
  String get emptyMessage => _sw
      ? 'Maudhui ya novena hayajapatikana.'
      : 'Novena content was not found.';
}

class _ClosingPrayerStrings {
  const _ClosingPrayerStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia sala...' : 'Loading prayer...';
  String get back => _sw ? 'Rudi' : 'Back';
  String get errorTitle => _sw ? 'Sala haijapakia' : 'Prayer did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma sala hii.'
      : 'There was a problem reading this prayer.';
  String get missingTitle => _sw ? 'Sala haikupatikana' : 'Prayer not found';
  String get missingMessage => _sw
      ? 'Sala hii haipo kwenye novena hii.'
      : 'This prayer is not available for this novena.';
}

class _FavoritesStrings {
  const _FavoritesStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Vipendwa' : 'Favorites';
  String subtitle(int count) =>
      _sw ? '$count vipendwa vilivyohifadhiwa' : '$count saved favorites';
  String get loading => _sw ? 'Inapakia vipendwa...' : 'Loading favorites...';
  String get searchHint => _sw ? 'Tafuta vipendwa...' : 'Search favorites...';
  String get emptyTitle => _sw ? 'Hakuna vipendwa bado' : 'No favorites yet';
  String get emptyMessage => _sw
      ? 'Gusa alama ya moyo kwenye sala ili kuihifadhi hapa.'
      : 'Tap the heart on any prayer to save it here.';
  String get noSearchResults => _sw
      ? 'Hakuna kipendwa kinacholingana na utafutaji huu.'
      : 'No favorite prayer matches this search.';
  String get loadErrorTitle =>
      _sw ? 'Vipendwa havijapakia' : 'Favorites did not load';
  String get loadErrorMessage => _sw
      ? 'Kuna tatizo kusoma sala zilizohifadhiwa.'
      : 'There was a problem reading saved prayers.';
  String get back => _sw ? 'Rudi' : 'Back';
}

class _PrayerLibraryStrings {
  const _PrayerLibraryStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Sala' : 'Pray';
  String get subtitle => _sw
      ? 'Chagua sala, ibada, novena, na rozari kwa mpangilio.'
      : 'Choose prayers, devotions, novenas, and rosary in order.';
  String get loading => _sw ? 'Inapakia sala...' : 'Loading prayers...';
  String get searchHint => _sw ? 'Tafuta sala...' : 'Search prayers...';
  String get corePrayers => _sw ? 'Sala Muhimu' : 'Essential Prayers';
  String get marianAndRosary =>
      _sw ? 'Bikira Maria na Rozari' : 'Mary and Rosary';
  String get devotions => _sw ? 'Ibada Maalum' : 'Devotions';
  String get rosaryAndMysteries =>
      _sw ? 'Rozari na Mafumbo' : 'Rosary and Mysteries';
  String get rosaryAndMysteriesDescription => _sw
      ? 'Sali rozari kwa hatua na mafumbo ya siku.'
      : 'Pray the rosary step by step with the mysteries of the day.';
  String get divineMercyRosary =>
      _sw ? 'Rozari ya Huruma ya Mungu' : 'Divine Mercy Rosary';
  String get divineMercyRosaryDescription => _sw
      ? 'Rozari ya Huruma ya Mungu bila mafumbo.'
      : 'Divine Mercy Rosary without mysteries.';
  String get comingSoon => _sw ? 'Inaandaliwa' : 'Coming soon';
  String countLabel(int count) {
    if (_sw) {
      return count == 1 ? 'Sala 1' : 'Sala $count';
    }

    return count == 1 ? '1 prayer' : '$count prayers';
  }

  String get noSearchResults => _sw
      ? 'Hakuna sala inayolingana na utafutaji huu.'
      : 'No prayers match this search.';
  String get loadErrorTitle =>
      _sw ? 'Sala hazijapakia' : 'Prayers did not load';
  String get loadErrorMessage => _sw
      ? 'Kuna tatizo kusoma maudhui ya ndani.'
      : 'There was a problem reading local content.';
  String get categoriesErrorTitle =>
      _sw ? 'Makundi hayajapakia' : 'Categories did not load';
  String get categoriesErrorMessage => _sw
      ? 'Kuna tatizo kusoma makundi ya sala.'
      : 'There was a problem reading prayer categories.';
  String get retry => _sw ? 'Jaribu tena' : 'Retry';
}

class _PrayerDetailStrings {
  const _PrayerDetailStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia sala...' : 'Loading prayer...';
  String get notFoundTitle => _sw ? 'Sala haikupatikana' : 'Prayer not found';
  String get loadErrorMessage => _sw
      ? 'Jaribu kurudi kwenye orodha ya sala.'
      : 'Try returning to the prayer list.';
  String get missingMessage =>
      _sw ? 'Jaribu kuchagua sala nyingine.' : 'Try choosing another prayer.';
  String get back => _sw ? 'Rudi' : 'Back';
  String get changeLanguage => _sw ? 'Badili lugha' : 'Change language';
  String get share => _sw ? 'Shiriki' : 'Share';
  String get removeFavorite => _sw ? 'Ondoa kipendwa' : 'Remove favorite';
  String get saveFavorite => _sw ? 'Hifadhi' : 'Save';
  String get source => _sw ? 'Chanzo' : 'Source';
  String get defaultSource =>
      _sw ? 'Sala ya kimapokeo ya Kikatoliki' : 'Traditional Catholic Prayer';
  String get shareFailed => _sw
      ? 'Imeshindikana kushiriki sala hii.'
      : 'Could not share this prayer.';

  String languageChanged(String nextLanguageCode) {
    if (nextLanguageCode == 'sw') {
      return _sw
          ? 'Lugha imebadilishwa kwenda Kiswahili.'
          : 'Language changed to Kiswahili.';
    }

    return _sw
        ? 'Lugha imebadilishwa kwenda Kiingereza.'
        : 'Language changed to English.';
  }
}

class _SettingsStrings {
  const _SettingsStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Mipangilio' : 'Settings';
  String get loading => _sw ? 'Inapakia mipangilio...' : 'Loading settings...';
  String get loadError => _sw
      ? 'Kuna tatizo kusoma mipangilio.'
      : 'There was a problem reading settings.';
  String get preferences => _sw ? 'Mapendeleo' : 'Preferences';
  String get supportInfo => _sw ? 'Msaada na Taarifa' : 'Support & Info';
  String get language => _sw ? 'Lugha' : 'Language';
  String get languageSubtitle =>
      _sw ? 'Chagua lugha ya programu' : 'Choose app language';
  String get reminders => _sw ? 'Vikumbusho' : 'Reminders';
  String get dailyReminder =>
      _sw ? 'Kikumbusho cha Kila Siku' : 'Daily Reminder';
  String get reminderSubtitle =>
      _sw ? 'Pokea ukumbusho wa kusali' : 'Receive a reminder to pray';
  String reminderEnabled(String time) =>
      _sw ? 'Kimewekwa saa $time' : 'Set for $time';
  String get reminderDisabled =>
      _sw ? 'Kikumbusho hakijawekwa' : 'No reminder set';
  String get changeTime => _sw ? 'Muda wa Kikumbusho' : 'Reminder Time';
  String get permissionDenied => _sw
      ? 'Ruhusa ya arifa haijatolewa. Unaweza kuiwasha kwenye mipangilio ya kifaa.'
      : 'Notification permission was denied. You can enable it in device settings.';
  String get fontSize => _sw ? 'Ukubwa wa Maandishi' : 'Text Size';
  String get fontSizeSubtitle =>
      _sw ? 'Badili ukubwa wa kusoma' : 'Adjust reading size';
  String get small => _sw ? 'Ndogo' : 'Small';
  String get medium => _sw ? 'Wastani' : 'Medium';
  String get large => _sw ? 'Kubwa' : 'Large';
  String textSizeLabel(_TextSizeValue value) {
    return switch (value) {
      _TextSizeValue.small => small,
      _TextSizeValue.medium => medium,
      _TextSizeValue.large => large,
    };
  }

  String get theme => _sw ? 'Mandhari' : 'Theme';
  String get themeSubtitle =>
      _sw ? 'Chagua mwonekano wa programu' : 'Select app appearance';
  String get system => _sw ? 'Mfumo' : 'System';
  String get light => _sw ? 'Mwanga' : 'Light';
  String get dark => _sw ? 'Giza' : 'Dark';
  String get information => _sw ? 'Taarifa' : 'Information';
  String get about => _sw ? 'Kuhusu Programu' : 'About App';
  String get aboutSubtitle =>
      _sw ? 'Toleo, msanidi, na zaidi' : 'Version, developer and more';
  String get privacyTitle => _sw ? 'Faragha na Sera' : 'Privacy & Policies';
  String get privacySubtitle => _sw
      ? 'Sera ya Faragha, Masharti na Tahadhari'
      : 'Privacy Policy, Terms & Disclaimer';
}

class _AboutStrings {
  const _AboutStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Kuhusu Programu' : 'About App';

  String get back => _sw ? 'Rudi' : 'Back';

  String get version => _sw
      ? 'Toleo ${AppConstants.appVersion}'
      : 'Version ${AppConstants.appVersion}';

  String get introduction => _sw
      ? 'Sala Katoliki huwasaidia waamini Wakatoliki kusali kila siku kwa Kiswahili na Kiingereza kupitia sala, novena, rozari na ibada, wakati wowote hata bila mtandao.'
      : 'Sala Katoliki helps Catholic faithful pray daily in Kiswahili and English with prayers, novenas, rosary content and devotions, anytime, anywhere, even offline.';

  String get aboutTitle => _sw ? 'Kuhusu' : 'About';

  String get aboutBody => _sw
      ? 'Imetengenezwa na Busara Digital kusaidia waamini kukua katika sala.'
      : 'Developed by Busara Digital to help the faithful grow in prayer.';

  String get aboutDetailsTitle =>
      _sw ? 'Kuhusu Sala Katoliki' : 'About Sala Katoliki';

  String get aboutDetailsBody => _sw
      ? 'Sala Katoliki ni programu rahisi ya sala za Kikatoliki iliyoundwa kusaidia watu kusali, kutafakari, na kujenga mazoea ya ibada ya kila siku.\n\nProgramu hii inatoa sala za kawaida za Kikatoliki, sala za Rozari zilizoongozwa, novena, vipendwa, utafutaji, na vikumbusho vya kila siku. Inatumia Kiingereza na Kiswahili, hivyo inarahisisha watu wengi zaidi kusali kwa lugha wanayoielewa vizuri zaidi.\n\nSala Katoliki imeundwa kwa ajili ya kila mtu. Kama wewe ni Mkatoliki, inakusaidia kupata sala na ibada unazozifahamu katika sehemu moja. Kama hujazoea sala za Kikatoliki, programu hii inakupa njia iliyo wazi na rahisi ya kujifunza, kufuata, na kuelewa ibada za kawaida za Kikatoliki.\n\nProgramu hii inafanya kazi nje ya mtandao, hivyo unaweza kuendelea kutumia vipengele vikuu vya sala bila muunganisho wa intaneti. Haihitaji akaunti, malipo, au maandalizi magumu.\n\nSala Katoliki ni kwa ajili ya sala binafsi, tafakari, na ukuaji wa kiroho. Si mbadala wa Kanisa, Biblia, Katekisimu, au mwongozo wa kichungaji, lakini inaweza kusaidia safari yako ya kila siku ya imani.'
      : 'Sala Katoliki is a simple Catholic prayer app created to help people pray, reflect, and build a daily habit of devotion.\n\nThe app provides common Catholic prayers, guided Rosary prayers, novenas, favorites, search, and daily reminders. It supports both English and Kiswahili, making it easier for more people to pray in the language they understand best.\n\nSala Katoliki is designed for everyone. If you are Catholic, it helps you access familiar prayers and devotions in one place. If you are not familiar with Catholic prayer, the app gives you a clear and simple way to learn, follow, and understand common Catholic devotions.\n\nThe app works offline, so you can continue using the main prayer features without an internet connection. It does not require an account, payment, or complicated setup.\n\nSala Katoliki is for personal prayer, reflection, and spiritual growth. It is not a replacement for the Church, the Bible, the Catechism, or pastoral guidance, but it can support your daily journey of faith.';

  String get developerTitle =>
      _sw ? 'Jifunze Kuhusu Busara Digital' : 'Learn About Busara Digital';

  String get developerBody => _sw
      ? 'Jifunze zaidi kuhusu msanidi wa Sala Katoliki.'
      : 'Learn more about the developer behind Sala Katoliki.';

  String get contentSourcesTitle =>
      _sw ? 'Vyanzo vya Maudhui' : 'Content Sources';

  String get contentSourcesBody => _sw
      ? 'Maudhui yanatokana na sala na ibada za kimapokeo za Kikatoliki zinazotumiwa na waamini.'
      : 'Content is based on traditional Catholic prayers and devotions used by the faithful.';

  String get contentSourcesDetailsBody => _sw
      ? 'Maudhui yaliyomo kwenye Sala Katoliki yanatokana na sala za kimapokeo za Kikatoliki, vitabu vya sala, maandiko ya ibada, na rasilimali za Kikatoliki zinazopatikana kwa umma.\n\nNyenzo hizi zinajumuisha sala na ibada zinazotumiwa kwa kawaida katika maisha ya Kikatoliki, kama sala za kila siku, sala za Rozari, litania, na novena. Maudhui huchaguliwa na kupangwa ili kufuata mafundisho ya Kikatoliki, mapokeo, na utaratibu wa ibada.\n\nBaadhi ya maudhui yanaweza kutoka kwenye vitabu vya sala vya kimapokeo na marejeo ya ibada za Kikatoliki. Maudhui mengine yanaweza kurekebishwa kutoka kwenye rasilimali za Kikatoliki za wazi au zinazopatikana kwa umma mtandaoni. Inapohitajika, maudhui hupitiwa na kurekebishwa kwa ajili ya uwazi, lugha, na ulinganifu na imani na mwenendo wa Kikatoliki.\n\nSala Katoliki inalenga kufanya sala za Kikatoliki zipatikane na kueleweka kwa urahisi zaidi kwa Wakatoliki na kwa watu ambao ni wapya katika ibada za Kikatoliki. Programu hii haidai kuchukua nafasi ya nyaraka rasmi za Kanisa, Biblia, Katekisimu, au mwongozo kutoka kwa mapadre na viongozi wa Kanisa.\n\nMaudhui yote hutolewa kwa ajili ya sala binafsi, tafakari, na ukuaji wa kiroho.'
      : 'The content in Sala Katoliki is based on traditional Catholic prayers, prayer books, devotional texts, and publicly available Catholic resources.\n\nThese materials include prayers and devotions that are commonly used in Catholic life, such as daily prayers, Rosary prayers, litanies, and novenas. The content is selected and organized to follow Catholic teaching, tradition, and devotional practice.\n\nSome content may come from traditional prayer books and Catholic devotional references. Other content may be adapted from open-source or publicly available online Catholic resources. Where needed, the content is reviewed and adjusted for clarity, language, and consistency with Catholic faith and practice.\n\nSala Katoliki aims to make Catholic prayer easier to access and understand for both Catholics and people who are new to Catholic devotion. The app does not claim to replace official Church documents, the Bible, the Catechism, or guidance from priests and Church leaders.\n\nAll content is provided for personal prayer, reflection, and spiritual growth.';

  String get disclaimerTitle => _sw ? 'Tahadhari' : 'Disclaimer';

  String get disclaimerBody => _sw
      ? 'Programu hii husaidia ibada binafsi na haibadilishi mafundisho rasmi ya Kanisa au mwongozo wa kichungaji.'
      : 'This app supports personal devotion and does not replace official Church teaching or pastoral guidance.';

  String get contact => _sw ? 'Mawasiliano' : 'Contact';

  String get contactTitle => _sw ? 'Tupo hapa kusaidia' : 'We are here to help';

  String get contactBody => _sw
      ? 'Kwa msaada au marekebisho ya maudhui, wasiliana nasi kupitia:'
      : 'For support or content corrections, reach us via:';

  String get rateAppLabel =>
      _sw ? 'Tathmini Sala Katoliki' : 'Rate Sala Katoliki';

  String get emailLabel => _sw ? 'Barua pepe' : 'Email';

  String get copyright => _sw
      ? '© 2026 Busara Digital. Haki zote zimehifadhiwa.'
      : '© 2026 Busara Digital. All rights reserved.';

  String get contactOpenError => _sw
      ? 'Imeshindikana kufungua programu ya mawasiliano.'
      : 'Could not open a contact app.';

  String get playStoreOpenError => _sw
      ? 'Imeshindikana kufungua Google Play.'
      : 'Could not open Google Play.';
}

class _ReminderNotificationStrings {
  const _ReminderNotificationStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => 'Sala Katoliki';

  String get body => _sw
      ? 'Chukua muda mfupi kwa ajili ya sala leo.'
      : 'Take a moment for prayer today.';
}

class _TodayStrings {
  const _TodayStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia leo...' : 'Loading today...';
  String get eyebrow => _sw ? 'AMANI IWE NAWE' : 'PEACE BE WITH YOU';
  String get todaysPrayer => _sw ? 'SALA YA LEO' : "TODAY'S PRAYER";
  String get noDailyPrayerTitle =>
      _sw ? 'Sala haijapatikana' : 'Prayer unavailable';
  String get noDailyPrayerBody => _sw
      ? 'Fungua maktaba ya sala kuona sala zilizopo.'
      : 'Open the prayer library to view available prayers.';
  String get prayNow => _sw ? 'Sali Sasa' : 'Pray Now';
  String get quickActions => _sw ? 'Fikia Haraka' : 'Quick Actions';
  String get continueNovena => _sw ? 'Endelea Novena' : 'Continue Novena';
  String get activeNovenaUnavailable =>
      _sw ? 'Novena haijapatikana' : 'Novena unavailable';
  String get continueAction => _sw ? 'Endelea' : 'Continue';
  String get novenas => _sw ? 'Novenas' : 'Novenas';
  String get noActiveNovena =>
      _sw ? 'Hakuna novena inayoendelea kwa sasa.' : 'No active novena yet.';
  String get browse => _sw ? 'Fungua' : 'Browse';
  String dayProgress(int day, int totalDays) =>
      _sw ? 'Siku ya $day kati ya $totalDays' : 'Day $day of $totalDays';
  String get rosaryToday => _sw ? 'Rozari Leo' : 'Rosary Today';
  String get suggestedMystery => _sw ? 'Mafumbo ya Leo' : "Today's Mysteries";
  String get todayDay => _sw ? 'Kulingana na siku ya leo' : 'Based on today';
  String get startRosary => _sw ? 'Anza Rozari' : 'Start Rosary';
  String get commonPrayers => _sw ? 'Sala za Kawaida' : 'Common Prayers';
  String get recentlyOpened =>
      _sw ? 'Zilizofunguliwa Karibuni' : 'Recently Opened';
  String get favorites => _sw ? 'Vipendwa' : 'Favorites';
  String reminderEnabled(String time) =>
      _sw ? 'Kikumbusho kimewekwa saa $time' : 'Reminder set for $time';
  String get reminderDisabled =>
      _sw ? 'Kikumbusho hakijawekwa' : 'No reminder set';
  String get availableOffline =>
      _sw ? 'Inapatikana nje ya mtandao' : 'Available offline';
  String get edit => _sw ? 'Hariri' : 'Edit';
}

class _LegalLinksStrings {
  const _LegalLinksStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get note => _sw
      ? 'Kabla ya kuendelea, soma sera na maelezo muhimu kuhusu matumizi na maudhui.'
      : 'Before continuing, review the important policies for use and content.';
  String get privacyPolicy => _sw ? 'Sera ya Faragha' : 'Privacy Policy';
  String get termsOfService => _sw ? 'Masharti ya Huduma' : 'Terms of Service';
  String get contentDisclaimer =>
      _sw ? 'Tahadhari ya Maudhui' : 'Content Disclaimer';
}

class _BottomNavStrings {
  const _BottomNavStrings(this.languageCode);
  final String languageCode;
  bool get _sw => languageCode == 'sw';

  String get today => _sw ? 'Leo' : 'Today';
  String get pray => _sw ? 'Sala' : 'Pray';
  String get novenas => _sw ? 'Novenas' : 'Novenas';
  String get settings => _sw ? 'Mipangilio' : 'Settings';
  String get exitPrompt => _sw
      ? 'Bonyeza tena kufunga Sala Katoliki.'
      : 'Press back again to close Sala Katoliki.';
}

Map<String, String> legacyLocalizedMessages(String languageCode) => {
  'rosaryTitle_0': _RosaryStrings(languageCode).title,
  'rosarySubtitle_0': _RosaryStrings(languageCode).subtitle,
  'rosaryLoading_0': _RosaryStrings(languageCode).loading,
  'rosaryTodayMystery_0': _RosaryStrings(languageCode).todayMystery,
  'rosaryStart_0': _RosaryStrings(languageCode).start,
  'rosaryChoose_0': _RosaryStrings(languageCode).choose,
  'rosarySavedProgress_0': _RosaryStrings(languageCode).savedProgress,
  'rosaryContinueLabel_0': _RosaryStrings(languageCode).continueLabel,
  'rosaryRestart_0': _RosaryStrings(languageCode).restart,
  'rosaryAllMysteries_0': _RosaryStrings(languageCode).allMysteries,
  'rosarySuggestedToday_0': _RosaryStrings(languageCode).suggestedToday,
  'rosaryStepLabel_0': _RosaryStrings(languageCode).stepLabel(0, 0),
  'rosaryStepLabel_1': _RosaryStrings(languageCode).stepLabel(1, 1),
  'rosaryStepLabel_2': _RosaryStrings(languageCode).stepLabel(2, 2),
  'rosaryStepLabel_3': _RosaryStrings(languageCode).stepLabel(9, 9),
  'rosaryStepLabel_4': _RosaryStrings(languageCode).stepLabel(12, 12),
  'rosaryStepLabel_5': _RosaryStrings(languageCode).stepLabel(100, 100),
  'rosaryRetry_0': _RosaryStrings(languageCode).retry,
  'rosaryLoadErrorTitle_0': _RosaryStrings(languageCode).loadErrorTitle,
  'rosaryLoadErrorMessage_0': _RosaryStrings(languageCode).loadErrorMessage,
  'rosaryEmptyTitle_0': _RosaryStrings(languageCode).emptyTitle,
  'rosaryEmptyMessage_0': _RosaryStrings(languageCode).emptyMessage,
  'rosaryStepLoading_0': _RosaryStepStrings(languageCode).loading,
  'rosaryStepBack_0': _RosaryStepStrings(languageCode).back,
  'rosaryStepRestart_0': _RosaryStepStrings(languageCode).restart,
  'rosaryStepPrevious_0': _RosaryStepStrings(languageCode).previous,
  'rosaryStepPause_0': _RosaryStepStrings(languageCode).pause,
  'rosaryStepNext_0': _RosaryStepStrings(languageCode).next,
  'rosaryStepFinish_0': _RosaryStepStrings(languageCode).finish,
  'rosaryStepLitany_0': _RosaryStepStrings(languageCode).litany,
  'rosaryStepClosing_0': _RosaryStepStrings(languageCode).closing,
  'rosaryStepErrorTitle_0': _RosaryStepStrings(languageCode).errorTitle,
  'rosaryStepErrorMessage_0': _RosaryStepStrings(languageCode).errorMessage,
  'rosaryStepMissingTitle_0': _RosaryStepStrings(languageCode).missingTitle,
  'rosaryStepMissingMessage_0': _RosaryStepStrings(languageCode).missingMessage,
  'rosaryStepStepLabel_0': _RosaryStepStrings(languageCode).stepLabel(0, 0),
  'rosaryStepStepLabel_1': _RosaryStepStrings(languageCode).stepLabel(1, 1),
  'rosaryStepStepLabel_2': _RosaryStepStrings(languageCode).stepLabel(2, 2),
  'rosaryStepStepLabel_3': _RosaryStepStrings(languageCode).stepLabel(9, 9),
  'rosaryStepStepLabel_4': _RosaryStepStrings(languageCode).stepLabel(12, 12),
  'rosaryStepStepLabel_5': _RosaryStepStrings(languageCode).stepLabel(100, 100),
  'mysterySelectionTitle_0': _MysterySelectionStrings(languageCode).title,
  'mysterySelectionLoading_0': _MysterySelectionStrings(languageCode).loading,
  'mysterySelectionSuggested_0': _MysterySelectionStrings(
    languageCode,
  ).suggested,
  'mysterySelectionBack_0': _MysterySelectionStrings(languageCode).back,
  'mysterySelectionErrorTitle_0': _MysterySelectionStrings(
    languageCode,
  ).errorTitle,
  'mysterySelectionErrorMessage_0': _MysterySelectionStrings(
    languageCode,
  ).errorMessage,
  'thanksgivingLoading_0': _ThanksgivingStrings(languageCode).loading,
  'thanksgivingBack_0': _ThanksgivingStrings(languageCode).back,
  'thanksgivingErrorTitle_0': _ThanksgivingStrings(languageCode).errorTitle,
  'thanksgivingErrorMessage_0': _ThanksgivingStrings(languageCode).errorMessage,
  'thanksgivingMissingTitle_0': _ThanksgivingStrings(languageCode).missingTitle,
  'thanksgivingMissingMessage_0': _ThanksgivingStrings(
    languageCode,
  ).missingMessage,
  'novenaDetailLoading_0': _NovenaDetailStrings(languageCode).loading,
  'novenaDetailBack_0': _NovenaDetailStrings(languageCode).back,
  'novenaDetailProgress_0': _NovenaDetailStrings(languageCode).progress,
  'novenaDetailNotStarted_0': _NovenaDetailStrings(languageCode).notStarted,
  'novenaDetailStartPrompt_0': _NovenaDetailStrings(languageCode).startPrompt,
  'novenaDetailStart_0': _NovenaDetailStrings(languageCode).start,
  'novenaDetailContinueDay_0': _NovenaDetailStrings(
    languageCode,
  ).continueDay(0),
  'novenaDetailContinueDay_1': _NovenaDetailStrings(
    languageCode,
  ).continueDay(1),
  'novenaDetailContinueDay_2': _NovenaDetailStrings(
    languageCode,
  ).continueDay(2),
  'novenaDetailContinueDay_3': _NovenaDetailStrings(
    languageCode,
  ).continueDay(9),
  'novenaDetailContinueDay_4': _NovenaDetailStrings(
    languageCode,
  ).continueDay(12),
  'novenaDetailContinueDay_5': _NovenaDetailStrings(
    languageCode,
  ).continueDay(100),
  'novenaDetailRestart_0': _NovenaDetailStrings(languageCode).restart,
  'novenaDetailAfterNovena_0': _NovenaDetailStrings(languageCode).afterNovena,
  'novenaDetailDayProgress_0': _NovenaDetailStrings(
    languageCode,
  ).dayProgress(0, 0),
  'novenaDetailDayProgress_1': _NovenaDetailStrings(
    languageCode,
  ).dayProgress(1, 1),
  'novenaDetailDayProgress_2': _NovenaDetailStrings(
    languageCode,
  ).dayProgress(2, 2),
  'novenaDetailDayProgress_3': _NovenaDetailStrings(
    languageCode,
  ).dayProgress(9, 9),
  'novenaDetailDayProgress_4': _NovenaDetailStrings(
    languageCode,
  ).dayProgress(12, 12),
  'novenaDetailDayProgress_5': _NovenaDetailStrings(
    languageCode,
  ).dayProgress(100, 100),
  'novenaDetailErrorTitle_0': _NovenaDetailStrings(languageCode).errorTitle,
  'novenaDetailErrorMessage_0': _NovenaDetailStrings(languageCode).errorMessage,
  'novenaDetailMissingTitle_0': _NovenaDetailStrings(languageCode).missingTitle,
  'novenaDetailMissingMessage_0': _NovenaDetailStrings(
    languageCode,
  ).missingMessage,
  'novenaDetailStatusCompleted_0': _NovenaDetailStrings(
    languageCode,
  ).statusLabel(NovenaDayStatus.completed),
  'novenaDetailStatusCurrent_0': _NovenaDetailStrings(
    languageCode,
  ).statusLabel(NovenaDayStatus.current),
  'novenaDetailStatusOpen_0': _NovenaDetailStrings(
    languageCode,
  ).statusLabel(NovenaDayStatus.open),
  'novenaDetailStatusLocked_0': _NovenaDetailStrings(
    languageCode,
  ).statusLabel(NovenaDayStatus.locked),
  'novenaDetailStatusNotStarted_0': _NovenaDetailStrings(
    languageCode,
  ).statusLabel(NovenaDayStatus.notStarted),
  'novenaDayLoading_0': _NovenaDayStrings(languageCode).loading,
  'novenaDayBack_0': _NovenaDayStrings(languageCode).back,
  'novenaDayCompleteDay_0': _NovenaDayStrings(languageCode).completeDay(0),
  'novenaDayCompleteDay_1': _NovenaDayStrings(languageCode).completeDay(1),
  'novenaDayCompleteDay_2': _NovenaDayStrings(languageCode).completeDay(2),
  'novenaDayCompleteDay_3': _NovenaDayStrings(languageCode).completeDay(9),
  'novenaDayCompleteDay_4': _NovenaDayStrings(languageCode).completeDay(12),
  'novenaDayCompleteDay_5': _NovenaDayStrings(languageCode).completeDay(100),
  'novenaDayCompleted_0': _NovenaDayStrings(languageCode).completed,
  'novenaDayDayLabel_0': _NovenaDayStrings(languageCode).dayLabel(0),
  'novenaDayDayLabel_1': _NovenaDayStrings(languageCode).dayLabel(1),
  'novenaDayDayLabel_2': _NovenaDayStrings(languageCode).dayLabel(2),
  'novenaDayDayLabel_3': _NovenaDayStrings(languageCode).dayLabel(9),
  'novenaDayDayLabel_4': _NovenaDayStrings(languageCode).dayLabel(12),
  'novenaDayDayLabel_5': _NovenaDayStrings(languageCode).dayLabel(100),
  'novenaDayDayProgress_0': _NovenaDayStrings(languageCode).dayProgress(0, 0),
  'novenaDayDayProgress_1': _NovenaDayStrings(languageCode).dayProgress(1, 1),
  'novenaDayDayProgress_2': _NovenaDayStrings(languageCode).dayProgress(2, 2),
  'novenaDayDayProgress_3': _NovenaDayStrings(languageCode).dayProgress(9, 9),
  'novenaDayDayProgress_4': _NovenaDayStrings(languageCode).dayProgress(12, 12),
  'novenaDayDayProgress_5': _NovenaDayStrings(
    languageCode,
  ).dayProgress(100, 100),
  'novenaDayChangeLanguage_0': _NovenaDayStrings(languageCode).changeLanguage,
  'novenaDayShare_0': _NovenaDayStrings(languageCode).share,
  'novenaDayRemoveFavorite_0': _NovenaDayStrings(languageCode).removeFavorite,
  'novenaDaySaveFavorite_0': _NovenaDayStrings(languageCode).saveFavorite,
  'novenaDaySource_0': _NovenaDayStrings(languageCode).source,
  'novenaDayShareFailed_0': _NovenaDayStrings(languageCode).shareFailed,
  'novenaDayErrorTitle_0': _NovenaDayStrings(languageCode).errorTitle,
  'novenaDayErrorMessage_0': _NovenaDayStrings(languageCode).errorMessage,
  'novenaDayMissingTitle_0': _NovenaDayStrings(languageCode).missingTitle,
  'novenaDayMissingMessage_0': _NovenaDayStrings(languageCode).missingMessage,
  'novenaDayLanguageChanged_0': _NovenaDayStrings(
    languageCode,
  ).languageChanged("en"),
  'novenaDayLanguageChanged_1': _NovenaDayStrings(
    languageCode,
  ).languageChanged("sw"),
  'novenaDayLanguageChanged_2': _NovenaDayStrings(
    languageCode,
  ).languageChanged("fr"),
  'novenasTitle_0': _NovenasStrings(languageCode).title,
  'novenasSubtitle_0': _NovenasStrings(languageCode).subtitle,
  'novenasLoading_0': _NovenasStrings(languageCode).loading,
  'novenasActiveNovena_0': _NovenasStrings(languageCode).activeNovena,
  'novenasBrowse_0': _NovenasStrings(languageCode).browse,
  'novenasContinueLabel_0': _NovenasStrings(languageCode).continueLabel,
  'novenasView_0': _NovenasStrings(languageCode).view,
  'novenasInProgress_0': _NovenasStrings(languageCode).inProgress,
  'novenasRetry_0': _NovenasStrings(languageCode).retry,
  'novenasDayProgress_0': _NovenasStrings(languageCode).dayProgress(0, 0),
  'novenasDayProgress_1': _NovenasStrings(languageCode).dayProgress(1, 1),
  'novenasDayProgress_2': _NovenasStrings(languageCode).dayProgress(2, 2),
  'novenasDayProgress_3': _NovenasStrings(languageCode).dayProgress(9, 9),
  'novenasDayProgress_4': _NovenasStrings(languageCode).dayProgress(12, 12),
  'novenasDayProgress_5': _NovenasStrings(languageCode).dayProgress(100, 100),
  'novenasErrorTitle_0': _NovenasStrings(languageCode).errorTitle,
  'novenasErrorMessage_0': _NovenasStrings(languageCode).errorMessage,
  'novenasEmptyTitle_0': _NovenasStrings(languageCode).emptyTitle,
  'novenasEmptyMessage_0': _NovenasStrings(languageCode).emptyMessage,
  'closingPrayerLoading_0': _ClosingPrayerStrings(languageCode).loading,
  'closingPrayerBack_0': _ClosingPrayerStrings(languageCode).back,
  'closingPrayerErrorTitle_0': _ClosingPrayerStrings(languageCode).errorTitle,
  'closingPrayerErrorMessage_0': _ClosingPrayerStrings(
    languageCode,
  ).errorMessage,
  'closingPrayerMissingTitle_0': _ClosingPrayerStrings(
    languageCode,
  ).missingTitle,
  'closingPrayerMissingMessage_0': _ClosingPrayerStrings(
    languageCode,
  ).missingMessage,
  'favoritesTitle_0': _FavoritesStrings(languageCode).title,
  'favoritesSubtitle_0': _FavoritesStrings(languageCode).subtitle(0),
  'favoritesSubtitle_1': _FavoritesStrings(languageCode).subtitle(1),
  'favoritesSubtitle_2': _FavoritesStrings(languageCode).subtitle(2),
  'favoritesSubtitle_3': _FavoritesStrings(languageCode).subtitle(9),
  'favoritesSubtitle_4': _FavoritesStrings(languageCode).subtitle(12),
  'favoritesSubtitle_5': _FavoritesStrings(languageCode).subtitle(100),
  'favoritesLoading_0': _FavoritesStrings(languageCode).loading,
  'favoritesSearchHint_0': _FavoritesStrings(languageCode).searchHint,
  'favoritesEmptyTitle_0': _FavoritesStrings(languageCode).emptyTitle,
  'favoritesEmptyMessage_0': _FavoritesStrings(languageCode).emptyMessage,
  'favoritesNoSearchResults_0': _FavoritesStrings(languageCode).noSearchResults,
  'favoritesLoadErrorTitle_0': _FavoritesStrings(languageCode).loadErrorTitle,
  'favoritesLoadErrorMessage_0': _FavoritesStrings(
    languageCode,
  ).loadErrorMessage,
  'favoritesBack_0': _FavoritesStrings(languageCode).back,
  'prayerLibraryTitle_0': _PrayerLibraryStrings(languageCode).title,
  'prayerLibrarySubtitle_0': _PrayerLibraryStrings(languageCode).subtitle,
  'prayerLibraryLoading_0': _PrayerLibraryStrings(languageCode).loading,
  'prayerLibrarySearchHint_0': _PrayerLibraryStrings(languageCode).searchHint,
  'prayerLibraryCorePrayers_0': _PrayerLibraryStrings(languageCode).corePrayers,
  'prayerLibraryMarianAndRosary_0': _PrayerLibraryStrings(
    languageCode,
  ).marianAndRosary,
  'prayerLibraryDevotions_0': _PrayerLibraryStrings(languageCode).devotions,
  'prayerLibraryRosaryAndMysteries_0': _PrayerLibraryStrings(
    languageCode,
  ).rosaryAndMysteries,
  'prayerLibraryRosaryAndMysteriesDescription_0': _PrayerLibraryStrings(
    languageCode,
  ).rosaryAndMysteriesDescription,
  'prayerLibraryDivineMercyRosary_0': _PrayerLibraryStrings(
    languageCode,
  ).divineMercyRosary,
  'prayerLibraryDivineMercyRosaryDescription_0': _PrayerLibraryStrings(
    languageCode,
  ).divineMercyRosaryDescription,
  'prayerLibraryComingSoon_0': _PrayerLibraryStrings(languageCode).comingSoon,
  'prayerLibraryNoSearchResults_0': _PrayerLibraryStrings(
    languageCode,
  ).noSearchResults,
  'prayerLibraryLoadErrorTitle_0': _PrayerLibraryStrings(
    languageCode,
  ).loadErrorTitle,
  'prayerLibraryLoadErrorMessage_0': _PrayerLibraryStrings(
    languageCode,
  ).loadErrorMessage,
  'prayerLibraryCategoriesErrorTitle_0': _PrayerLibraryStrings(
    languageCode,
  ).categoriesErrorTitle,
  'prayerLibraryCategoriesErrorMessage_0': _PrayerLibraryStrings(
    languageCode,
  ).categoriesErrorMessage,
  'prayerLibraryRetry_0': _PrayerLibraryStrings(languageCode).retry,
  'prayerLibraryCountLabel_0': _PrayerLibraryStrings(
    languageCode,
  ).countLabel(0),
  'prayerLibraryCountLabel_1': _PrayerLibraryStrings(
    languageCode,
  ).countLabel(1),
  'prayerLibraryCountLabel_2': _PrayerLibraryStrings(
    languageCode,
  ).countLabel(2),
  'prayerLibraryCountLabel_3': _PrayerLibraryStrings(
    languageCode,
  ).countLabel(9),
  'prayerLibraryCountLabel_4': _PrayerLibraryStrings(
    languageCode,
  ).countLabel(12),
  'prayerLibraryCountLabel_5': _PrayerLibraryStrings(
    languageCode,
  ).countLabel(100),
  'prayerDetailLoading_0': _PrayerDetailStrings(languageCode).loading,
  'prayerDetailNotFoundTitle_0': _PrayerDetailStrings(
    languageCode,
  ).notFoundTitle,
  'prayerDetailLoadErrorMessage_0': _PrayerDetailStrings(
    languageCode,
  ).loadErrorMessage,
  'prayerDetailMissingMessage_0': _PrayerDetailStrings(
    languageCode,
  ).missingMessage,
  'prayerDetailBack_0': _PrayerDetailStrings(languageCode).back,
  'prayerDetailChangeLanguage_0': _PrayerDetailStrings(
    languageCode,
  ).changeLanguage,
  'prayerDetailShare_0': _PrayerDetailStrings(languageCode).share,
  'prayerDetailRemoveFavorite_0': _PrayerDetailStrings(
    languageCode,
  ).removeFavorite,
  'prayerDetailSaveFavorite_0': _PrayerDetailStrings(languageCode).saveFavorite,
  'prayerDetailSource_0': _PrayerDetailStrings(languageCode).source,
  'prayerDetailDefaultSource_0': _PrayerDetailStrings(
    languageCode,
  ).defaultSource,
  'prayerDetailShareFailed_0': _PrayerDetailStrings(languageCode).shareFailed,
  'prayerDetailLanguageChanged_0': _PrayerDetailStrings(
    languageCode,
  ).languageChanged("en"),
  'prayerDetailLanguageChanged_1': _PrayerDetailStrings(
    languageCode,
  ).languageChanged("sw"),
  'prayerDetailLanguageChanged_2': _PrayerDetailStrings(
    languageCode,
  ).languageChanged("fr"),
  'settingsTitle_0': _SettingsStrings(languageCode).title,
  'settingsLoading_0': _SettingsStrings(languageCode).loading,
  'settingsLoadError_0': _SettingsStrings(languageCode).loadError,
  'settingsPreferences_0': _SettingsStrings(languageCode).preferences,
  'settingsSupportInfo_0': _SettingsStrings(languageCode).supportInfo,
  'settingsLanguage_0': _SettingsStrings(languageCode).language,
  'settingsLanguageSubtitle_0': _SettingsStrings(languageCode).languageSubtitle,
  'settingsReminders_0': _SettingsStrings(languageCode).reminders,
  'settingsDailyReminder_0': _SettingsStrings(languageCode).dailyReminder,
  'settingsReminderSubtitle_0': _SettingsStrings(languageCode).reminderSubtitle,
  'settingsReminderEnabled_0': _SettingsStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'settingsReminderEnabled_1': _SettingsStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'settingsReminderEnabled_2': _SettingsStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'settingsReminderEnabled_3': _SettingsStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'settingsReminderEnabled_4': _SettingsStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'settingsReminderEnabled_5': _SettingsStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'settingsReminderDisabled_0': _SettingsStrings(languageCode).reminderDisabled,
  'settingsChangeTime_0': _SettingsStrings(languageCode).changeTime,
  'settingsPermissionDenied_0': _SettingsStrings(languageCode).permissionDenied,
  'settingsFontSize_0': _SettingsStrings(languageCode).fontSize,
  'settingsFontSizeSubtitle_0': _SettingsStrings(languageCode).fontSizeSubtitle,
  'settingsSmall_0': _SettingsStrings(languageCode).small,
  'settingsMedium_0': _SettingsStrings(languageCode).medium,
  'settingsLarge_0': _SettingsStrings(languageCode).large,
  'settingsTheme_0': _SettingsStrings(languageCode).theme,
  'settingsThemeSubtitle_0': _SettingsStrings(languageCode).themeSubtitle,
  'settingsSystem_0': _SettingsStrings(languageCode).system,
  'settingsLight_0': _SettingsStrings(languageCode).light,
  'settingsDark_0': _SettingsStrings(languageCode).dark,
  'settingsInformation_0': _SettingsStrings(languageCode).information,
  'settingsAbout_0': _SettingsStrings(languageCode).about,
  'settingsAboutSubtitle_0': _SettingsStrings(languageCode).aboutSubtitle,
  'settingsPrivacyTitle_0': _SettingsStrings(languageCode).privacyTitle,
  'settingsPrivacySubtitle_0': _SettingsStrings(languageCode).privacySubtitle,
  'aboutTitle_0': _AboutStrings(languageCode).title,
  'aboutBack_0': _AboutStrings(languageCode).back,
  'aboutVersion_0': _AboutStrings(languageCode).version,
  'aboutIntroduction_0': _AboutStrings(languageCode).introduction,
  'aboutAboutTitle_0': _AboutStrings(languageCode).aboutTitle,
  'aboutAboutBody_0': _AboutStrings(languageCode).aboutBody,
  'aboutAboutDetailsTitle_0': _AboutStrings(languageCode).aboutDetailsTitle,
  'aboutAboutDetailsBody_0': _AboutStrings(languageCode).aboutDetailsBody,
  'aboutDeveloperTitle_0': _AboutStrings(languageCode).developerTitle,
  'aboutDeveloperBody_0': _AboutStrings(languageCode).developerBody,
  'aboutContentSourcesTitle_0': _AboutStrings(languageCode).contentSourcesTitle,
  'aboutContentSourcesBody_0': _AboutStrings(languageCode).contentSourcesBody,
  'aboutContentSourcesDetailsBody_0': _AboutStrings(
    languageCode,
  ).contentSourcesDetailsBody,
  'aboutDisclaimerTitle_0': _AboutStrings(languageCode).disclaimerTitle,
  'aboutDisclaimerBody_0': _AboutStrings(languageCode).disclaimerBody,
  'aboutContact_0': _AboutStrings(languageCode).contact,
  'aboutContactTitle_0': _AboutStrings(languageCode).contactTitle,
  'aboutContactBody_0': _AboutStrings(languageCode).contactBody,
  'aboutRateAppLabel_0': _AboutStrings(languageCode).rateAppLabel,
  'aboutEmailLabel_0': _AboutStrings(languageCode).emailLabel,
  'aboutCopyright_0': _AboutStrings(languageCode).copyright,
  'aboutContactOpenError_0': _AboutStrings(languageCode).contactOpenError,
  'aboutPlayStoreOpenError_0': _AboutStrings(languageCode).playStoreOpenError,
  'reminderNotificationTitle_0': _ReminderNotificationStrings(
    languageCode,
  ).title,
  'reminderNotificationBody_0': _ReminderNotificationStrings(languageCode).body,
  'todayLoading_0': _TodayStrings(languageCode).loading,
  'todayEyebrow_0': _TodayStrings(languageCode).eyebrow,
  'todayTodaysPrayer_0': _TodayStrings(languageCode).todaysPrayer,
  'todayNoDailyPrayerTitle_0': _TodayStrings(languageCode).noDailyPrayerTitle,
  'todayNoDailyPrayerBody_0': _TodayStrings(languageCode).noDailyPrayerBody,
  'todayPrayNow_0': _TodayStrings(languageCode).prayNow,
  'todayQuickActions_0': _TodayStrings(languageCode).quickActions,
  'todayContinueNovena_0': _TodayStrings(languageCode).continueNovena,
  'todayActiveNovenaUnavailable_0': _TodayStrings(
    languageCode,
  ).activeNovenaUnavailable,
  'todayContinueAction_0': _TodayStrings(languageCode).continueAction,
  'todayNovenas_0': _TodayStrings(languageCode).novenas,
  'todayNoActiveNovena_0': _TodayStrings(languageCode).noActiveNovena,
  'todayBrowse_0': _TodayStrings(languageCode).browse,
  'todayDayProgress_0': _TodayStrings(languageCode).dayProgress(0, 0),
  'todayDayProgress_1': _TodayStrings(languageCode).dayProgress(1, 1),
  'todayDayProgress_2': _TodayStrings(languageCode).dayProgress(2, 2),
  'todayDayProgress_3': _TodayStrings(languageCode).dayProgress(9, 9),
  'todayDayProgress_4': _TodayStrings(languageCode).dayProgress(12, 12),
  'todayDayProgress_5': _TodayStrings(languageCode).dayProgress(100, 100),
  'todayRosaryToday_0': _TodayStrings(languageCode).rosaryToday,
  'todaySuggestedMystery_0': _TodayStrings(languageCode).suggestedMystery,
  'todayTodayDay_0': _TodayStrings(languageCode).todayDay,
  'todayStartRosary_0': _TodayStrings(languageCode).startRosary,
  'todayCommonPrayers_0': _TodayStrings(languageCode).commonPrayers,
  'todayRecentlyOpened_0': _TodayStrings(languageCode).recentlyOpened,
  'todayFavorites_0': _TodayStrings(languageCode).favorites,
  'todayReminderEnabled_0': _TodayStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'todayReminderEnabled_1': _TodayStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'todayReminderEnabled_2': _TodayStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'todayReminderEnabled_3': _TodayStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'todayReminderEnabled_4': _TodayStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'todayReminderEnabled_5': _TodayStrings(
    languageCode,
  ).reminderEnabled("08:30"),
  'todayReminderDisabled_0': _TodayStrings(languageCode).reminderDisabled,
  'todayAvailableOffline_0': _TodayStrings(languageCode).availableOffline,
  'todayEdit_0': _TodayStrings(languageCode).edit,
  'legalLinksNote_0': _LegalLinksStrings(languageCode).note,
  'legalLinksPrivacyPolicy_0': _LegalLinksStrings(languageCode).privacyPolicy,
  'legalLinksTermsOfService_0': _LegalLinksStrings(languageCode).termsOfService,
  'legalLinksContentDisclaimer_0': _LegalLinksStrings(
    languageCode,
  ).contentDisclaimer,
  'bottomNavToday_0': _BottomNavStrings(languageCode).today,
  'bottomNavPray_0': _BottomNavStrings(languageCode).pray,
  'bottomNavNovenas_0': _BottomNavStrings(languageCode).novenas,
  'bottomNavSettings_0': _BottomNavStrings(languageCode).settings,
  'bottomNavExitPrompt_0': _BottomNavStrings(languageCode).exitPrompt,
  'settingsTextSizeSmall': _SettingsStrings(
    languageCode,
  ).textSizeLabel(_TextSizeValue.small),
  'settingsTextSizeMedium': _SettingsStrings(
    languageCode,
  ).textSizeLabel(_TextSizeValue.medium),
  'settingsTextSizeLarge': _SettingsStrings(
    languageCode,
  ).textSizeLabel(_TextSizeValue.large),
};
