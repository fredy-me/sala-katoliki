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
import '../../../../shared/widgets/litany_text_view.dart';
import '../providers/novena_providers.dart';

class NovenaClosingPrayerScreen extends ConsumerWidget {
  const NovenaClosingPrayerScreen({required this.novenaId, super.key});

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
            loading: () => AppLoading(label: strings.closingPrayerLoading),
            error: (error, stackTrace) => AppErrorState(
              title: strings.closingPrayerErrorTitle,
              message: strings.closingPrayerErrorMessage,
              actionLabel: strings.closingPrayerBack,
              onAction: () => context.popOrGo('/novenas/$novenaId'),
            ),
            data: (novena) {
              final isStRitaNovena = novena?.usesStRitaStyle ?? false;
              final closingPrayer = novena?.closingPrayer;
              if (novena == null || closingPrayer == null) {
                return AppErrorState(
                  title: strings.closingPrayerMissingTitle,
                  message: strings.closingPrayerMissingMessage,
                  actionLabel: strings.closingPrayerBack,
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
                        tooltip: strings.closingPrayerBack,
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
                  if (isStRitaNovena)
                    Text(
                      closingPrayer.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  else
                    AppCard(
                      radius: AppSpacing.radiusXl,
                      child: Text(
                        closingPrayer.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  if (isStRitaNovena)
                    LitanyTextView(
                      text: closingPrayer.readingText,
                      stRitaStyle: isStRitaNovena,
                    )
                  else
                    AppCard(
                      radius: AppSpacing.radiusXl,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: LitanyTextView(
                        text: closingPrayer.readingText,
                        stRitaStyle: isStRitaNovena,
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
