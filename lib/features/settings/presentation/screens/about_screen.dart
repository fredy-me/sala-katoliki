import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/legal_links.dart';
import '../../../../shared/widgets/sala_logo_mark.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _AboutStrings(languageCode);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemOverlayStyle(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.screenBottom,
            ),
            children: [
              _AboutHeader(strings: strings),

              const SizedBox(height: AppSpacing.section),

              Center(
                child: SalaLogoMark(
                  size: 116,
                  padding: 4,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  borderColor: _AboutColors.accent(context),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                'Sala Katoliki',
                textAlign: TextAlign.center,
                style: _AboutText.display(context),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                strings.version,
                textAlign: TextAlign.center,
                style: _AboutText.body(context),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                strings.introduction,
                textAlign: TextAlign.center,
                style: _AboutText.body(context),
              ),

              const SizedBox(height: AppSpacing.section),

              _InfoCard(
                icon: Icons.star_border,
                title: strings.aboutTitle,
                body: strings.aboutBody,
                onTap: () => _showAboutDetails(context, strings),
              ),

              const SizedBox(height: AppSpacing.md),

              _InfoCard(
                icon: Icons.menu_book_outlined,
                title: strings.contentSourcesTitle,
                body: strings.contentSourcesBody,
                onTap: () => _showContentSources(context, strings),
              ),

              const SizedBox(height: AppSpacing.md),

              _InfoCard(
                icon: Icons.verified_user_outlined,
                title: strings.disclaimerTitle,
                body: strings.disclaimerBody,
                actionIcon: Icons.open_in_new,
                onTap: () => _openDisclaimer(context, strings),
              ),

              const SizedBox(height: AppSpacing.section),

              _SectionLabel(strings.contact),

              const SizedBox(height: AppSpacing.md),

              _ContactCard(strings: strings),

              const SizedBox(height: AppSpacing.md),

              _DeveloperCard(strings: strings),

              const SizedBox(height: AppSpacing.xl),

              Text(
                strings.copyright,
                textAlign: TextAlign.center,
                style: _AboutText.bodySmall(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDetails(BuildContext context, _AboutStrings strings) {
    _showDetailsSheet(
      context,
      title: strings.aboutDetailsTitle,
      body: strings.aboutDetailsBody,
    );
  }

  void _showContentSources(BuildContext context, _AboutStrings strings) {
    _showDetailsSheet(
      context,
      title: strings.contentSourcesTitle,
      body: strings.contentSourcesDetailsBody,
    );
  }

  void _showDetailsSheet(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    showModalBottomSheet<void>(

      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {

        return SafeArea(

          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            ),

            child: ListView(

              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),

              children: [
                Text(title, style: _AboutText.heading(context)),
                const SizedBox(height: AppSpacing.lg),
                Text(body, style: _AboutText.body(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDisclaimer(
    BuildContext context,
    _AboutStrings strings,
  ) async {
    try {
      if (await launchUrl(
        LegalLinks.contentDisclaimerUrl,
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // The snackbar below is enough for a failed external launch.
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.contactOpenError)));
    }
  }
}

SystemUiOverlayStyle _systemOverlayStyle(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader({required this.strings});

  final _AboutStrings strings;

  @override
  Widget build(BuildContext context) {
    return Row(

      children: [
        IconButton(
          tooltip: strings.back,
          onPressed: () => context.popOrGo('/settings'),
          icon: Icon(Icons.arrow_back, color: _AboutColors.accent(context)),
        ),

        Expanded(
          child: Text(
            strings.title,
            textAlign: TextAlign.center,
            style: _AboutText.heading(context),
          ),

        ),
        const SizedBox(width: AppSpacing.minTouchTarget),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionIcon = Icons.chevron_right,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final IconData actionIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _AboutPanel(
      onTap: onTap,
      child: Row(
        children: [
          _IconBadge(icon: icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title, style: _AboutText.title(context)),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: _AboutText.bodySmall(context)),
              ],
            ),
          ),

          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(actionIcon, color: _AboutColors.mutedText(context)),
          ],
        ],
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({required this.strings});

  static final _websiteUri = Uri.parse(
    'https://busaradigital.ebuild.workers.dev/',
  );

  final _AboutStrings strings;

  @override
  Widget build(BuildContext context) {
    return _AboutPanel(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => _openWebsite(context),

        child: Row(
          children: [
            const _IconBadge(icon: Icons.public),
            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.developerTitle,
                    style: _AboutText.title(context),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    strings.developerBody,
                    style: _AboutText.bodySmall(context),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Icon(Icons.open_in_new, color: _AboutColors.accent(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _openWebsite(BuildContext context) async {
    try {
      if (await launchUrl(_websiteUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // The snackbar below is enough for a failed external launch.
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.contactOpenError)));
    }
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.strings});

  static const _whatsappNumber = '255696189401';
  static const _displayWhatsappNumber = '+255 696 189 401';
  static const _email = 'busaraplatform@gmail.com';

  final _AboutStrings strings;

  @override
  Widget build(BuildContext context) {
    return _AboutPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.contactTitle, style: _AboutText.title(context)),
          const SizedBox(height: AppSpacing.xs),
          Text(strings.contactBody, style: _AboutText.bodySmall(context)),
          const SizedBox(height: AppSpacing.lg),

          _ContactAction(
            icon: Icons.chat_outlined,
            title: 'WhatsApp',
            subtitle: _displayWhatsappNumber,
            onTap: () => _openWhatsApp(context, strings),
          ),

          Divider(height: AppSpacing.xl, color: _AboutColors.border(context)),

          _ContactAction(
            icon: Icons.email_outlined,
            title: strings.emailLabel,
            subtitle: _email,
            onTap: () => _openEmail(context, strings),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(
    BuildContext context,
    _AboutStrings strings,
  ) async {
    final appUri = Uri.parse('whatsapp://send?phone=$_whatsappNumber');
    final webUri = Uri.parse('https://wa.me/$_whatsappNumber');

    if (await _tryLaunch(appUri) || await _tryLaunch(webUri)) {
      return;
    }

    if (context.mounted) {
      _showLaunchError(context, strings.contactOpenError);
    }
  }

  Future<void> _openEmail(BuildContext context, _AboutStrings strings) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {'subject': 'Sala Katoliki Support'},
    );

    if (await _tryLaunch(uri)) {
      return;
    }

    if (context.mounted) {
      _showLaunchError(context, strings.contactOpenError);
    }
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  void _showLaunchError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ContactAction extends StatelessWidget {
  const _ContactAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            _IconBadge(icon: icon, foreground: _AboutColors.text(context)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(title, style: _AboutText.title(context)),
                  const SizedBox(height: AppSpacing.xs),

                  Text(subtitle, style: _AboutText.bodySmall(context)),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: _AboutColors.accent(context)),
          ],
        ),
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.foreground});

  final IconData icon;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: _AboutColors.iconBackground(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),

      child: Icon(
        icon,
        color: foreground ?? _AboutColors.accent(context),
        size: 30,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: _AboutText.section(context));
  }
}

abstract final class _AboutColors {
  static Color iconBackground(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color border(BuildContext context) =>
      Theme.of(context).dividerTheme.color ??
      Theme.of(context).colorScheme.outlineVariant;

  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color mutedText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color accent(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.color ??
      Theme.of(context).colorScheme.secondary;
}

abstract final class _AboutText {
  static TextStyle? display(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge;

  static TextStyle? heading(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium;

  static TextStyle? title(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;

  static TextStyle? body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;

  static TextStyle? bodySmall(BuildContext context) => body(context);

  static TextStyle? section(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall;
}

class _AboutStrings {
  const _AboutStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Kuhusu Programu' : 'About App';

  String get back => _sw ? 'Rudi' : 'Back';

  String get version => _sw ? 'Toleo 1.0.1' : 'Version 1.0.1';

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

  String get contact => _sw ? 'Mawasiliano na Maoni' : 'Contact & Feedback';

  String get contactTitle => _sw ? 'Tupo hapa kusaidia' : 'We are here to help';

  String get contactBody => _sw
      ? 'Kwa msaada, marekebisho ya maudhui au maoni, wasiliana nasi kupitia:'
      : 'For support, content corrections or feedback, reach us via:';

  String get emailLabel => _sw ? 'Barua pepe' : 'Email';

  String get copyright => _sw
      ? '© 2026 Busara Digital. Haki zote zimehifadhiwa.'
      : '© 2026 Busara Digital. All rights reserved.';

  String get contactOpenError => _sw
      ? 'Imeshindikana kufungua programu ya mawasiliano.'
      : 'Could not open a contact app.';
}
