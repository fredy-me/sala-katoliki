import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/localization/supported_languages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String _selectedLanguageCode = SupportedLanguages.english.code;

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedLanguageProvider, (previous, next) {
      final languageCode = next.asData?.value;
      if (languageCode != null && mounted) {
        context.go('/today');
      }
    });

    final isKiswahili =
        _selectedLanguageCode == SupportedLanguages.kiswahili.code;
    final languageState = ref.watch(selectedLanguageProvider);
    if (languageState.asData?.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/today');
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xl,
              ),
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.more_horiz, color: AppColors.mutedText),
                ),
                const SizedBox(height: 34),
                const _AppMark(),
                const SizedBox(height: AppSpacing.section),
                Text(
                  isKiswahili
                      ? 'Chagua Lugha Yako ya Sala'
                      : 'Choose Your Prayer Language',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  isKiswahili
                      ? 'Chagua lugha unayopendelea kwa sala na maudhui ya programu.'
                      : 'Select the language you prefer for prayers and app content.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.section),
                _LanguageOptionCard(
                  language: SupportedLanguages.english,
                  selected:
                      _selectedLanguageCode == SupportedLanguages.english.code,
                  onTap: () => setState(
                    () =>
                        _selectedLanguageCode = SupportedLanguages.english.code,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _LanguageOptionCard(
                  language: SupportedLanguages.kiswahili,
                  selected:
                      _selectedLanguageCode ==
                      SupportedLanguages.kiswahili.code,
                  onTap: () => setState(
                    () => _selectedLanguageCode =
                        SupportedLanguages.kiswahili.code,
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                FilledButton(
                  onPressed: languageState.isLoading
                      ? null
                      : () => ref
                            .read(selectedLanguageProvider.notifier)
                            .selectLanguage(_selectedLanguageCode),
                  child: Text(isKiswahili ? 'Endelea' : 'Continue'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: languageState.isLoading
                      ? null
                      : () => ref
                            .read(selectedLanguageProvider.notifier)
                            .selectLanguage(SupportedLanguages.english.code),
                  child: Text(isKiswahili ? 'Ruka' : 'Skip'),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isKiswahili
                      ? 'Unaweza kubadilisha hii baadaye katika Mipangilio.'
                      : 'You can change this later in Settings.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: const Icon(Icons.local_florist, color: AppColors.navy, size: 30),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
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
      backgroundColor: selected ? AppColors.goldSoft : AppColors.surface,
      borderColor: selected ? AppColors.gold : AppColors.border,
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
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
          Container(
            width: AppSpacing.minTouchTarget,
            height: AppSpacing.minTouchTarget,
            alignment: Alignment.center,
            child: selected
                ? const CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.gold,
                    child: Icon(Icons.check, color: AppColors.text, size: 16),
                  )
                : Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
