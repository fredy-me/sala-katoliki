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
    final strings = _ThanksgivingStrings(languageCode);
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
              final section = novena?.thanksgivingSection;
              if (novena == null || section == null) {
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
                          section.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    radius: AppSpacing.radiusXl,
                    child: Text(
                      section.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NovenaTextView(text: section.body),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ThanksgivingStrings {
  const _ThanksgivingStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading =>
      _sw ? 'Inapakia shukrani...' : 'Loading thanksgiving...';
  String get back => _sw ? 'Rudi' : 'Back';
  String get errorTitle =>
      _sw ? 'Shukrani haijapakia' : 'Thanksgiving did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma sehemu hii.'
      : 'There was a problem reading this section.';
  String get missingTitle => _sw ? 'Sehemu haikupatikana' : 'Section not found';
  String get missingMessage => _sw
      ? 'Sehemu hii haipo kwenye novena hii.'
      : 'This section is not available for this novena.';
}
