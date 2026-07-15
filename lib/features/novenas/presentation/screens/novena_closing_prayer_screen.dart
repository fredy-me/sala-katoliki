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
    final strings = _ClosingPrayerStrings(languageCode);
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
            loading: () => AppLoading(label: strings.loading),
            error: (error, stackTrace) => AppErrorState(
              title: strings.errorTitle,
              message: strings.errorMessage,
              actionLabel: strings.back,
              onAction: () => context.popOrGo('/novenas/$novenaId'),
            ),
            data: (novena) {
              final isStRitaNovena = novenaId == 'st_rita_novena';
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
                  LitanyTextView(
                    text: closingPrayer.body,
                    showContainer: !isStRitaNovena,
                    stRitaStyle: isStRitaNovena,
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

class _ClosingPrayerStrings {
  const _ClosingPrayerStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia sala...' : 'Loading prayer...';
  String get back => _sw ? 'Rudi' : 'Back';
  String get errorTitle => _sw ? 'Sala haijapakia' : 'Prayer did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma sala hii.'
      : 'There was a problem reading this prayer.';
  String get missingTitle => _sw ? 'Sala haikupatikana' : 'Prayer not found';
  String get missingMessage => _sw
      ? 'Sala hii haipo kwenye novena hii.'
      : 'This prayer is not available for this novena.';
}
