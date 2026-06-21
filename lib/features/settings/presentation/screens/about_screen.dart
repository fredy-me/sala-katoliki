import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _AboutStrings(languageCode);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            AppSpacing.screenBottom,
          ),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: strings.back,
                  onPressed: () => context.popOrGo('/settings'),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    strings.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold),
                ),
                child: const Icon(
                  Icons.local_florist,
                  color: AppColors.navy,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sala Katoliki',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings.version,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.section),
            SectionHeader(title: strings.developer),
            const SizedBox(height: AppSpacing.md),
            _AboutCard(title: 'Busara Digital', body: strings.developerBody),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: strings.openSource),
            const SizedBox(height: AppSpacing.md),
            _AboutCard(
              title: strings.openSourceTitle,
              body: strings.openSourceBody,
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: strings.contentSources),
            const SizedBox(height: AppSpacing.md),
            _AboutCard(
              title: strings.contentSourcesTitle,
              body: strings.contentSourcesBody,
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: strings.disclaimer),
            const SizedBox(height: AppSpacing.md),
            _AboutCard(
              title: strings.disclaimerTitle,
              body: strings.disclaimerBody,
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: strings.contact),
            const SizedBox(height: AppSpacing.md),
            _ContactCard(strings: strings),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.strings});

  static const _whatsappNumber = '255696189401';
  static const _displayWhatsappNumber = '+255696189401';
  static const _email = 'busaraplatform@gmail.com';

  final _AboutStrings strings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.contactTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.contactBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _ContactActionTile(
            icon: Icons.chat_outlined,
            title: 'WhatsApp',
            subtitle: _displayWhatsappNumber,
            onTap: () => _openWhatsApp(context, strings),
          ),
          const Divider(height: 1),
          _ContactActionTile(
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

class _ContactActionTile extends StatelessWidget {
  const _ContactActionTile({
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
    return ListTile(
      leading: Icon(icon, color: AppColors.navy),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new),
      onTap: onTap,
    );
  }
}

class _AboutStrings {
  const _AboutStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Kuhusu Programu' : 'About App';
  String get back => _sw ? 'Rudi' : 'Back';
  String get version => _sw ? 'Toleo 1.0.1' : 'Version 1.0.1';
  String get developer => _sw ? 'Msanidi' : 'Developer';
  String get developerBody => _sw
      ? 'Sala Katoliki imetengenezwa na Busara Digital ili kusaidia waamini kupata sala za Kikatoliki kwa Kiswahili na Kiingereza kwa urahisi.'
      : 'Sala Katoliki is developed by Busara Digital to help the faithful access Catholic prayers in Kiswahili and English with ease.';
  String get openSource => _sw ? 'Thamani ya Programu' : 'App Value';
  String get openSourceTitle => _sw ? 'Sala Popote' : 'Prayer Anywhere';
  String get openSourceBody => _sw
      ? 'Programu hii imeundwa kufanya kazi nje ya mtandao, kuhifadhi sala muhimu, novena, rozari, na ibada za kila siku katika kifaa chako.'
      : 'This app is designed for offline use, keeping essential prayers, novenas, rosary content, and daily devotions available on your device.';
  String get contentSources => _sw ? 'Vyanzo vya Maudhui' : 'Content Sources';
  String get contentSourcesTitle =>
      _sw ? 'Sala za Kimapokeo' : 'Traditional Catholic Content';
  String get contentSourcesBody => _sw
      ? 'Maudhui yanakusanywa kutoka sala za kimapokeo za Kikatoliki na ibada zinazotumika na waamini. Tunapokea marekebisho na mapendekezo ya kuboresha usahihi wa sala.'
      : 'Content is collected from traditional Catholic prayers and devotions used by the faithful. Corrections and suggestions are welcome to improve prayer accuracy.';
  String get disclaimer => _sw ? 'Tahadhari' : 'Disclaimer';
  String get disclaimerTitle =>
      _sw ? 'Kwa Ibada Binafsi' : 'For Personal Devotion';
  String get disclaimerBody => _sw
      ? 'Programu hii ni msaada wa sala binafsi na haibadilishi mwongozo wa kichungaji au maandiko rasmi ya Kanisa.'
      : 'This app supports personal prayer and does not replace pastoral guidance or official Church texts.';
  String get contact => _sw ? 'Mawasiliano' : 'Contact';
  String get contactTitle => 'Busara Digital';
  String get contactBody => _sw
      ? 'Kwa msaada, marekebisho ya maudhui, au maoni kuhusu programu, tumia njia mojawapo hapa chini.'
      : 'For support, content corrections, or app feedback, use either option below.';
  String get emailLabel => _sw ? 'Barua pepe' : 'Email';
  String get contactOpenError => _sw
      ? 'Imeshindikana kufungua programu ya mawasiliano.'
      : 'Could not open a contact app.';
}
