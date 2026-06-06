import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            _AboutCard(
              title: 'Kilimanjaro Technology',
              body: strings.developerBody,
            ),
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
            _AboutCard(title: strings.contactTitle, body: strings.contactBody),
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

class _AboutStrings {
  const _AboutStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Kuhusu Programu' : 'About App';
  String get back => _sw ? 'Rudi' : 'Back';
  String get version => _sw ? 'Toleo 1.0.0' : 'Version 1.0.0';
  String get developer => _sw ? 'Msanidi' : 'Developer';
  String get developerBody => _sw
      ? 'Programu hii imetengenezwa kwa Sala Katoliki MVP na Kilimanjaro Technology.'
      : 'This app is developed for the Sala Katoliki MVP by Kilimanjaro Technology.';
  String get openSource => _sw ? 'Chanzo Wazi' : 'Open Source';
  String get openSourceTitle =>
      _sw ? 'Mchango wa Baadaye' : 'Future Contributions';
  String get openSourceBody => _sw
      ? 'Muundo wa maudhui umeandaliwa ili kurahisisha ukaguzi, tafsiri, na michango ya baadaye.'
      : 'The content structure is prepared for future review, translation, and contribution workflows.';
  String get contentSources => _sw ? 'Vyanzo vya Maudhui' : 'Content Sources';
  String get contentSourcesTitle =>
      _sw ? 'Sala za Kimapokeo' : 'Traditional Catholic Content';
  String get contentSourcesBody => _sw
      ? 'Maudhui ya MVP yanatoka kwenye sala za kimapokeo za Kikatoliki na ibada zilizoidhinishwa. Maudhui mapya yanahitaji ukaguzi wa haki na chanzo.'
      : 'MVP content comes from traditional Catholic prayers and approved devotions. New content requires rights and source review.';
  String get disclaimer => _sw ? 'Tahadhari' : 'Disclaimer';
  String get disclaimerTitle =>
      _sw ? 'Kwa Ibada Binafsi' : 'For Personal Devotion';
  String get disclaimerBody => _sw
      ? 'Programu hii ni msaada wa sala binafsi na haibadilishi mwongozo wa kichungaji au maandiko rasmi ya Kanisa.'
      : 'This app supports personal prayer and does not replace pastoral guidance or official Church texts.';
  String get contact => _sw ? 'Mawasiliano' : 'Contact';
  String get contactTitle => 'Kilimanjaro Technology';
  String get contactBody => _sw
      ? 'Tovuti na maelezo ya msaada yataongezwa kabla ya toleo la uzalishaji.'
      : 'Website and support contact details will be added before production release.';
}
