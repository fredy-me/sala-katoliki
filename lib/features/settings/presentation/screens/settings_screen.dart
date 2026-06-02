import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/localization/supported_languages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage =
        ref.watch(selectedLanguageProvider).asData?.value ??
        SupportedLanguages.english.code;
    final isKiswahili = selectedLanguage == SupportedLanguages.kiswahili.code;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenTop,
        AppSpacing.screenHorizontal,
        AppSpacing.screenBottom,
      ),
      children: [
        Text(
          isKiswahili ? 'Mipangilio' : 'Settings',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          isKiswahili
              ? 'Dhibiti lugha, vikumbusho, maandishi, na mandhari.'
              : 'Manage language, reminders, text size, and theme.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.section),
        SectionHeader(title: isKiswahili ? 'Lugha' : 'Language'),
        const SizedBox(height: AppSpacing.md),
        for (final language in SupportedLanguages.all) ...[
          _LanguageSettingTile(
            language: language,
            selected: selectedLanguage == language.code,
            onTap: () {
              ref
                  .read(selectedLanguageProvider.notifier)
                  .selectLanguage(language.code);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.section),
        SectionHeader(title: isKiswahili ? 'MVP Ijayo' : 'Next MVP Settings'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          backgroundColor: AppColors.surfaceWarm,
          child: Text(
            isKiswahili
                ? 'Vikumbusho, ukubwa wa maandishi, mandhari, na taarifa za programu zitatekelezwa katika awamu zinazofuata.'
                : 'Reminders, text size, theme controls, and app information will be implemented in the next phases.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _LanguageSettingTile extends StatelessWidget {
  const _LanguageSettingTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final SupportedLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: selected ? AppColors.gold : AppColors.border,
      backgroundColor: selected ? AppColors.goldSoft : AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  language.nativeName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: AppColors.gold)
          else
            const Icon(Icons.radio_button_unchecked, color: AppColors.dimText),
        ],
      ),
    );
  }
}
