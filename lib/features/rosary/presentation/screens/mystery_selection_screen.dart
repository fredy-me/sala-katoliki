import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/navigation_utils.dart';
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
    final strings = AppStrings(languageCode);
    final mysteriesState = ref.watch(rosaryMysteriesProvider);
    final suggested = ref.watch(suggestedRosaryMysteryProvider).asData?.value;

    return Scaffold(
      body: SafeArea(
        child: mysteriesState.when(
          loading: () => AppLoading(label: strings.mysterySelectionLoading),
          error: (error, stackTrace) => AppErrorState(
            title: strings.mysterySelectionErrorTitle,
            message: strings.mysterySelectionErrorMessage,
            actionLabel: strings.mysterySelectionBack,
            onAction: () => context.popOrGo('/rosary'),
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
                    tooltip: strings.mysterySelectionBack,
                    onPressed: () => context.popOrGo('/rosary'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      strings.mysterySelectionTitle,
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
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: isSuggested ? AppColors.gold : null,
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
                  isSuggested
                      ? strings.mysterySelectionSuggested
                      : mystery.description,
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
