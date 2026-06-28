import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
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
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoCard(
                icon: Icons.menu_book_outlined,
                title: strings.contentSourcesTitle,
                body: strings.contentSourcesBody,
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoCard(
                icon: Icons.verified_user_outlined,
                title: strings.disclaimerTitle,
                body: strings.disclaimerBody,
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
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _AboutPanel(
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
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right, color: _AboutColors.mutedText(context)),
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
  const _AboutPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _AboutColors.panel(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: _AboutColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: _AboutColors.shadow(context),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
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
  static Color panel(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

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
      Theme.of(context).colorScheme.secondary;

  static Color shadow(BuildContext context) =>
      Theme.of(context).shadowColor.withValues(alpha: 0.16);
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
