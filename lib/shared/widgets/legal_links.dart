import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_spacing.dart';

class LegalLinks extends StatelessWidget {
  const LegalLinks({
    required this.languageCode,
    this.centered = false,
    super.key,
  });

  static final Uri privacyPolicyUrl = Uri.parse(
    'https://busaradigital.com/apps/sala-katoliki/privacy-policy',
  );
  static final Uri termsOfServiceUrl = Uri.parse(
    'https://busaradigital.com/apps/sala-katoliki/terms-of-service',
  );
  static final Uri contentDisclaimerUrl = Uri.parse(
    'https://busaradigital.com/apps/sala-katoliki/content-disclaimer',
  );

  final String languageCode;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(languageCode);

    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          strings.legalLinksNote,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            _LegalLinkButton(
              label: strings.legalLinksPrivacyPolicy,
              uri: privacyPolicyUrl,
            ),
            _LegalLinkButton(
              label: strings.legalLinksTermsOfService,
              uri: termsOfServiceUrl,
            ),
            _LegalLinkButton(
              label: strings.legalLinksContentDisclaimer,
              uri: contentDisclaimerUrl,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegalLinkButton extends StatelessWidget {
  const _LegalLinkButton({required this.label, required this.uri});

  final String label;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _openLink(context),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Future<void> _openLink(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open this link.')),
      );
    }
  }
}
