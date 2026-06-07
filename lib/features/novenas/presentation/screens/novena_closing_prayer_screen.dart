import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/novena_providers.dart';

class NovenaClosingPrayerScreen extends ConsumerWidget {
  const NovenaClosingPrayerScreen({required this.novenaId, super.key});

  final String novenaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _ClosingPrayerStrings(languageCode);
    final novenaState = ref.watch(novenaByIdProvider(novenaId));

    return Scaffold(
      body: SafeArea(
        child: novenaState.when(
          loading: () => AppLoading(label: strings.loading),
          error: (error, stackTrace) => AppErrorState(
            title: strings.errorTitle,
            message: strings.errorMessage,
            actionLabel: strings.back,
            onAction: () => context.popOrGo('/novenas/$novenaId'),
          ),
          data: (novena) {
            final closingPrayer = novena?.closingPrayer;
            if (novena == null || closingPrayer == null) {
              return AppErrorState(
                title: strings.missingTitle,
                message: strings.missingMessage,
                actionLabel: strings.back,
                onAction: () => context.popOrGo('/novenas/$novenaId'),
              );
            }

            return ListView(
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
                      onPressed: () => context.popOrGo('/novenas/$novenaId'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        closingPrayer.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  radius: AppSpacing.radiusXl,
                  child: Text(
                    closingPrayer.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _LitanyPrayerCard(text: closingPrayer.body),
                if (novena.source != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.source,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          novena.source!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LitanyPrayerCard extends StatelessWidget {
  const _LitanyPrayerCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList(growable: false);

    return AppCard(
      radius: AppSpacing.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < paragraphs.length; index += 1) ...[
            _LitanyLine(text: paragraphs[index]),
            if (index != paragraphs.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _LitanyLine extends StatelessWidget {
  const _LitanyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final normalized = text.replaceAll('*', '').replaceAll('"', '').trim();
    final isResponse =
        normalized.startsWith('Kiitikio') ||
        normalized.startsWith('Response') ||
        normalized.startsWith('R:') ||
        normalized.startsWith('V:') ||
        normalized.startsWith('K:') ||
        normalized.startsWith('W:') ||
        normalized.startsWith('TUOMBE') ||
        normalized.startsWith('LET US PRAY');
    final isLambOfGod =
        normalized.startsWith('Mwanakondoo') ||
        normalized.startsWith('Lamb of God');

    if (isResponse || isLambOfGod) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isResponse
                ? AppColors.gold
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          normalized,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Text(
      normalized,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(height: 1.5, fontWeight: FontWeight.w400),
    );
  }
}

class _ClosingPrayerStrings {
  const _ClosingPrayerStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia sala...' : 'Loading prayer...';
  String get back => _sw ? 'Rudi' : 'Back';
  String get source => _sw ? 'Chanzo' : 'Source';
  String get errorTitle => _sw ? 'Sala haijapakia' : 'Prayer did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma sala hii.'
      : 'There was a problem reading this prayer.';
  String get missingTitle => _sw ? 'Sala haikupatikana' : 'Prayer not found';
  String get missingMessage => _sw
      ? 'Sala hii haipo kwenye novena hii.'
      : 'This prayer is not available for this novena.';
}
