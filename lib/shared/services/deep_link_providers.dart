import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/localization_providers.dart';
import '../../features/novenas/presentation/providers/novena_providers.dart';
import '../../features/prayers/presentation/providers/prayer_providers.dart';
import '../../features/rosary/presentation/providers/rosary_providers.dart';
import 'deep_link_service.dart';

/// Builds the deep link resolver once bundled content is ready.
///
/// Slugs come from the Kiswahili titles (the site's URL language), so the
/// prayer/novena/rosary content is indexed in Kiswahili while the current
/// app language is used only to prefer ids that exist on screen.
final deepLinkContextProvider = FutureProvider<DeepLinkService>((ref) async {
  // `prayersProvider` is watched for the active language, so when that language
  // is already Kiswahili its cached corpus is reused instead of parsed again.
  final activePrayers = await ref.watch(prayersProvider.future);
  final swPrayers = ref.read(activeLanguageProvider) == 'sw'
      ? activePrayers
      : await ref
            .watch(getAllPrayersUseCaseProvider)
            .call(languageCode: 'sw');
  final novenas = await ref
      .watch(novenaRepositoryProvider)
      .getNovenas(languageCode: 'sw');
  final mysteries = await ref
      .watch(rosaryRepositoryProvider)
      .getRosaryMysteries(languageCode: 'sw');

  return DeepLinkService(
    prayerIndex: swPrayers,
    activePrayers: activePrayers,
    novenas: novenas,
    mysteries: mysteries,
  );
});