import 'package:salakatoliki/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/localization_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/legal_links.dart';
import '../../../../shared/widgets/sala_logo_mark.dart';
import '../widgets/settings_ui.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(activeLanguageProvider);
    final strings = AppStrings(languageCode);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemOverlayStyle(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.screenBottom,
            ),
            children: [
              _AboutHeader(strings: strings),

              const SizedBox(height: AppSpacing.section),

              Center(
                child: SalaLogoMark(
                  size: 116,
                  padding: 4,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  borderColor: SettingsColors.accent(context),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                'Sala Katoliki',
                textAlign: TextAlign.center,
                style: SettingsTextStyles.display(context),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                strings.aboutVersion(AppConstants.appVersion),
                textAlign: TextAlign.center,
                style: SettingsTextStyles.body(context),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                strings.aboutIntroduction,
                textAlign: TextAlign.center,
                style: SettingsTextStyles.body(context),
              ),

              const SizedBox(height: AppSpacing.section),

              _InfoCard(
                icon: Icons.star_border,
                title: strings.aboutAboutTitle,
                body: strings.aboutAboutBody,
                onTap: () => _showAboutDetails(context, strings),
              ),

              const SizedBox(height: AppSpacing.md),

              _InfoCard(
                icon: Icons.menu_book_outlined,
                title: strings.aboutContentSourcesTitle,
                body: strings.aboutContentSourcesBody,
                onTap: () => _showContentSources(context, strings),
              ),

              const SizedBox(height: AppSpacing.md),

              _InfoCard(
                icon: Icons.verified_user_outlined,
                title: strings.aboutDisclaimerTitle,
                body: strings.aboutDisclaimerBody,
                actionIcon: Icons.open_in_new,
                onTap: () => _openDisclaimer(context, strings),
              ),

              const SizedBox(height: AppSpacing.section),

              SettingsSectionLabel(strings.aboutContact),

              const SizedBox(height: AppSpacing.md),

              _ContactCard(strings: strings),

              const SizedBox(height: AppSpacing.md),

              _DeveloperCard(strings: strings),

              const SizedBox(height: AppSpacing.xl),

              Text(
                strings.aboutCopyright,
                textAlign: TextAlign.center,
                style: SettingsTextStyles.bodySmall(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDetails(BuildContext context, AppStrings strings) {
    _showDetailsSheet(
      context,
      title: strings.aboutAboutDetailsTitle,
      body: strings.aboutAboutDetailsBody,
    );
  }

  void _showContentSources(BuildContext context, AppStrings strings) {
    _showDetailsSheet(
      context,
      title: strings.aboutContentSourcesTitle,
      body: strings.aboutContentSourcesDetailsBody,
    );
  }

  void _showDetailsSheet(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            ),

            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),

              children: [
                Text(title, style: SettingsTextStyles.heading(context)),
                const SizedBox(height: AppSpacing.lg),
                Text(body, style: SettingsTextStyles.body(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDisclaimer(BuildContext context, AppStrings strings) async {
    try {
      if (await launchUrl(
        LegalLinks.contentDisclaimerUrl,
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // The snackbar below is enough for a failed external launch.
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.aboutContactOpenError)));
    }
  }
}

SystemUiOverlayStyle _systemOverlayStyle(BuildContext context) {
  return AppTheme.systemOverlayStyleFor(Theme.of(context).brightness);
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: strings.aboutBack,
          onPressed: () => context.popOrGo('/settings'),
          icon: Icon(Icons.arrow_back, color: SettingsColors.accent(context)),
        ),

        Expanded(
          child: Text(
            strings.aboutAboutTitle,
            textAlign: TextAlign.center,
            style: SettingsTextStyles.heading(context),
          ),
        ),
        const SizedBox(width: AppSpacing.minTouchTarget),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionIcon = Icons.chevron_right,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final IconData actionIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _AboutPanel(
      onTap: onTap,
      child: Row(
        children: [
          SettingsIconBadge(icon: icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title, style: SettingsTextStyles.title(context)),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: SettingsTextStyles.bodySmall(context)),
              ],
            ),
          ),

          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(actionIcon, color: SettingsColors.mutedText(context)),
          ],
        ],
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({required this.strings});

  static final _websiteUri = Uri.parse('https://busaradigital.com/');

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return _AboutPanel(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => _openWebsite(context),

        child: Row(
          children: [
            const SettingsIconBadge(icon: Icons.public),
            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.aboutDeveloperTitle,
                    style: SettingsTextStyles.title(context),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    strings.aboutDeveloperBody,
                    style: SettingsTextStyles.bodySmall(context),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Icon(Icons.open_in_new, color: SettingsColors.accent(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _openWebsite(BuildContext context) async {
    try {
      if (await launchUrl(_websiteUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // The snackbar below is enough for a failed external launch.
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.aboutContactOpenError)));
    }
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.strings});

  static const _email = 'support@busaradigital.com';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.busaradigital.salakatoliki';

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return _AboutPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.aboutContactTitle,
            style: SettingsTextStyles.title(context),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.aboutContactBody,
            style: SettingsTextStyles.bodySmall(context),
          ),
          const SizedBox(height: AppSpacing.lg),

          _ContactAction(
            icon: Icons.star_outline,
            title: strings.aboutRateAppLabel,
            subtitle: 'Google Play',
            onTap: () => _openPlayStore(context, strings),
          ),

          Divider(height: AppSpacing.xl, color: SettingsColors.border(context)),

          _ContactAction(
            icon: Icons.email_outlined,
            title: strings.aboutEmailLabel,
            subtitle: _email,
            onTap: () => _openEmail(context, strings),
          ),
        ],
      ),
    );
  }

  Future<void> _openPlayStore(BuildContext context, AppStrings strings) async {
    if (await _tryLaunch(Uri.parse(_playStoreUrl))) {
      return;
    }

    if (context.mounted) {
      _showLaunchError(context, strings.aboutPlayStoreOpenError);
    }
  }

  Future<void> _openEmail(BuildContext context, AppStrings strings) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {'subject': 'Sala Katoliki Support'},
    );

    if (await _tryLaunch(uri)) {
      return;
    }

    if (context.mounted) {
      _showLaunchError(context, strings.aboutContactOpenError);
    }
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  void _showLaunchError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ContactAction extends StatelessWidget {
  const _ContactAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            SettingsIconBadge(
              icon: icon,
              foreground: SettingsColors.text(context),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(title, style: SettingsTextStyles.title(context)),
                  const SizedBox(height: AppSpacing.xs),

                  Text(subtitle, style: SettingsTextStyles.bodySmall(context)),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: SettingsColors.accent(context)),
          ],
        ),
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}
