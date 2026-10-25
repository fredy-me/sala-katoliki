import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/novena_text_view.dart';
import '../providers/novena_providers.dart';

class NovenaThanksgivingScreen extends ConsumerWidget {
  const NovenaThanksgivingScreen({required this.novenaId, super.key});

  final String novenaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = AppStrings(languageCode);
    final novenaState = ref.watch(novenaByIdProvider(novenaId));

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        context.popOrGo('/novenas/$novenaId');
      },
      child: Scaffold(
        body: SafeArea(
          child: novenaState.when(
            loading: () => AppLoading(label: strings.thanksgivingLoading),
            error: (error, stackTrace) => AppErrorState(
              title: strings.thanksgivingErrorTitle,
              message: strings.thanksgivingErrorMessage,
              actionLabel: strings.thanksgivingBack,
              onAction: () => context.popOrGo('/novenas/$novenaId'),
            ),
            data: (novena) {
              final isStRitaNovena = novena?.usesStRitaStyle ?? false;
              final section = novena?.thanksgivingSection;
              if (novena == null || section == null) {
                return AppErrorState(
                  title: strings.thanksgivingMissingTitle,
                  message: strings.thanksgivingMissingMessage,
                  actionLabel: strings.thanksgivingBack,
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
                        tooltip: strings.thanksgivingBack,
                        onPressed: () => context.popOrGo('/novenas/$novenaId'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          section.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (isStRitaNovena)
                    Text(
                      section.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  else
                    AppCard(
                      radius: AppSpacing.radiusXl,
                      child: Text(
                        section.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  if (isStRitaNovena)
                    NovenaTextView(
                      text: section.readingText,
                      allSaintsStyle: isStRitaNovena,
                      thanksgivingStyle: isStRitaNovena,
                    )
                  else
                    AppCard(
                      radius: AppSpacing.radiusXl,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: NovenaTextView(
                        text: section.readingText,
                        allSaintsStyle: isStRitaNovena,
                        thanksgivingStyle: isStRitaNovena,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
