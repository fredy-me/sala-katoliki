import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../data/models/novena_model.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/novena_text_view.dart';
import '../providers/novena_providers.dart';

class NovenaDayScreen extends ConsumerWidget {
  const NovenaDayScreen({required this.novenaId, required this.day, super.key});

  final String novenaId;
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _NovenaDayStrings(languageCode);
    final novenaState = ref.watch(novenaByIdProvider(novenaId));
    final progress = ref.watch(novenaProgressProvider).asData?.value;

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
              if (novena == null || day < 1 || day > novena.days.length) {
                return AppErrorState(
                  title: strings.missingTitle,
                  message: strings.missingMessage,
                  actionLabel: strings.back,
                  onAction: () => context.popOrGo('/novenas/$novenaId'),
                );
              }

              final dayContent = novena.days.firstWhere(
                (item) => item.day == day,
              );
              final completed = progress?.isCompleted(novenaId, day) ?? false;

              return Column(
                children: [
                  _TopBar(
                    title: novena.title,
                    backLabel: strings.back,
                    onBack: () => context.popOrGo('/novenas/$novenaId'),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerTheme.color,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        AppSpacing.xl,
                        AppSpacing.screenHorizontal,
                        AppSpacing.screenBottom,
                      ),
                      children: [
                        Text(
                          strings.dayLabel(day),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          dayContent.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        NovenaTextView(
                          text: dayContent.body,
                          showContainer: false,
                        ),
                      ],
                    ),
                  ),
                  _CompleteBar(
                    day: day,
                    completed: completed,
                    strings: strings,
                    onComplete: completed
                        ? null
                        : () => _complete(context, ref, novena, dayContent.day),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    NovenaModel novena,
    int day,
  ) async {
    await ref.read(novenaProgressProvider.notifier).completeDay(novena.id, day);
    if (context.mounted) {
      context.go('/novenas/${novena.id}');
    }
  }

}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.backLabel,
    required this.onBack,
  });

  final String title;
  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            tooltip: backLabel,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.minTouchTarget),
        ],
      ),
    );
  }
}

class _CompleteBar extends StatelessWidget {
  const _CompleteBar({
    required this.day,
    required this.completed,
    required this.strings,
    required this.onComplete,
  });

  final int day;
  final bool completed;
  final _NovenaDayStrings strings;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.sm,
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onComplete,
                icon: Icon(
                  completed ? Icons.check : Icons.check_circle_outline,
                  size: 18,
                ),
                label: Text(
                  completed ? strings.completed : strings.completeDay(day),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NovenaDayStrings {
  const _NovenaDayStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get loading => _sw ? 'Inapakia siku...' : 'Loading day...';
  String get back => _sw ? 'Rudi' : 'Back';
  String completeDay(int day) =>
      _sw ? 'Nimemaliza Siku $day' : 'Complete Day $day';
  String get completed => _sw ? 'Imekamilika' : 'Completed';
  String dayLabel(int day) => _sw ? 'Siku ya $day' : 'Day $day';
  String get errorTitle => _sw ? 'Siku haijapakia' : 'Day did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma siku hii ya novena.'
      : 'There was a problem reading this novena day.';
  String get missingTitle => _sw ? 'Siku haikupatikana' : 'Day not found';
  String get missingMessage => _sw
      ? 'Siku hii haipo kwenye novena hii.'
      : 'This day is not available in this novena.';
}
