import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/rosary_model.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/rosary_providers.dart';

class MysterySelectionScreen extends ConsumerWidget {
  const MysterySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = _MysterySelectionStrings(languageCode);
    final mysteriesState = ref.watch(rosaryMysteriesProvider);
    final suggested = ref.watch(suggestedRosaryMysteryProvider).asData?.value;

    return Scaffold(
      body: SafeArea(
        child: mysteriesState.when(
          loading: () => AppLoading(label: strings.loading),
          error: (error, stackTrace) => AppErrorState(
            title: strings.errorTitle,
            message: strings.errorMessage,
            actionLabel: strings.back,
            onAction: () => context.pop(),
          ),
          data: (mysteries) => ListView(
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
                    onPressed: () => context.pop(),
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
              const SizedBox(height: AppSpacing.lg),
              for (final mystery in mysteries) ...[
                _MysteryOption(
                  mystery: mystery,
                  isSuggested: mystery.id == suggested?.id,
                  strings: strings,
                  onTap: () => _start(context, ref, mystery.id),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    String mysteryId,
  ) async {
    await ref.read(rosaryProgressProvider.notifier).start(mysteryId);
    if (context.mounted) {
      context.push('/rosary/step/$mysteryId');
    }
  }
}

class _MysteryOption extends StatelessWidget {
  const _MysteryOption({
    required this.mystery,
    required this.isSuggested,
    required this.strings,
    required this.onTap,
  });

  final RosaryMysteryModel mystery;
  final bool isSuggested;
  final _MysterySelectionStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: isSuggested ? AppColors.gold : AppColors.border,
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.gold),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mystery.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isSuggested ? strings.suggested : mystery.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MysterySelectionStrings {
  const _MysterySelectionStrings(this.languageCode);

  final String languageCode;

  bool get _sw => languageCode == 'sw';

  String get title => _sw ? 'Chagua Mafumbo' : 'Choose Mysteries';
  String get loading => _sw ? 'Inapakia mafumbo...' : 'Loading mysteries...';
  String get suggested => _sw ? 'Limependekezwa leo' : 'Suggested today';
  String get back => _sw ? 'Rudi' : 'Back';
  String get errorTitle =>
      _sw ? 'Mafumbo hayajapakia' : 'Mysteries did not load';
  String get errorMessage => _sw
      ? 'Kuna tatizo kusoma mafumbo ya rozari.'
      : 'There was a problem reading Rosary mysteries.';
}
