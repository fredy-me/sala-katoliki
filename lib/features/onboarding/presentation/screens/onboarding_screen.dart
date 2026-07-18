import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/localization/supported_languages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/sala_logo_mark.dart';
import '../../../../shared/widgets/legal_links.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String _selectedLanguageCode = SupportedLanguages.english.code;

  @override
  Widget build(BuildContext context) {
    final isKiswahili =
        _selectedLanguageCode == SupportedLanguages.kiswahili.code;
    final languageState = ref.watch(selectedLanguageProvider);

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
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
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
                      : () => _selectLanguage(_selectedLanguageCode),
                  child: Text(isKiswahili ? 'Endelea' : 'Continue'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: languageState.isLoading
                      ? null
                      : () => _selectLanguage(SupportedLanguages.english.code),
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
                const SizedBox(height: AppSpacing.lg),
                LegalLinks(languageCode: _selectedLanguageCode, centered: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectLanguage(String languageCode) async {
    await ref
        .read(selectedLanguageProvider.notifier)
        .selectLanguage(languageCode);
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SalaLogoMark(
      size: 116,
      padding: 4,
      backgroundColor: colorScheme.surface,
      borderColor: theme.textTheme.labelSmall?.color ?? colorScheme.secondary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedBackground = theme.brightness == Brightness.dark
        ? colorScheme.primary.withValues(alpha: 0.16)
        : AppColors.goldSoft;
    final background = selected ? selectedBackground : colorScheme.surface;
    final borderColor = selected
        ? colorScheme.primary
        : theme.dividerTheme.color ?? colorScheme.outlineVariant;

    return AppCard(
      onTap: onTap,
      backgroundColor: background,
      borderColor: borderColor,
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  language.nativeName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
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
                      border: Border.all(color: borderColor, width: 2),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
