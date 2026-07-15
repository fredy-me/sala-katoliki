import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

class LitanyTextView extends StatelessWidget {
  const LitanyTextView({
    required this.text,
    this.fontScale = 1,
    this.showContainer = true,
    this.stRitaStyle = false,
    super.key,
  });

  final String text;
  final double fontScale;
  final bool showContainer;
  final bool stRitaStyle;

  @override
  Widget build(BuildContext context) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < lines.length; index += 1) ...[
          _LitanyLine(
            text: lines[index],
            fontScale: fontScale,
            stRitaStyle: stRitaStyle,
          ),
          if (index != lines.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );

    if (!showContainer) {
      return content;
    }

    return AppCard(
      radius: AppSpacing.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: content,
    );
  }
}

class _LitanyLine extends StatelessWidget {
  const _LitanyLine({
    required this.text,
    required this.fontScale,
    this.stRitaStyle = false,
  });

  final String text;
  final double fontScale;
  final bool stRitaStyle;

  @override
  Widget build(BuildContext context) {
    final normalized = text
        .replaceAll('"', '')
        .replaceAll('“', '')
        .replaceAll('”', '')
        .trim();
    final isMarked = normalized.contains('*');
    final plainText = normalized.replaceAll('*', '');
    final isHighlighted = isMarked || _isHighlightedLine(normalized);
    final isLambOfGod =
        plainText.startsWith('Mwanakondoo') ||
        plainText.startsWith('Lamb of God');
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final scaledStyle = baseStyle?.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * fontScale,
    );

    if (stRitaStyle) {
      if (_isResponseLine(plainText)) {
        return Text(
          plainText,
          style: scaledStyle?.copyWith(
            height: 1.5,
            color: Theme.of(context).colorScheme.primary,
            fontStyle: FontStyle.italic,
          ),
        );
      }

      if (isLambOfGod) {
        return Text(
          plainText,
          style: scaledStyle?.copyWith(
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        );
      }

      if (_isStRitaHeading(plainText)) {
        return Text(
          plainText.toUpperCase(),
          style: scaledStyle?.copyWith(
            height: 1.45,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        );
      }

      return Text(
        plainText,
        style: scaledStyle?.copyWith(height: 1.5, fontWeight: FontWeight.w400),
      );
    }

    if (isHighlighted || isLambOfGod) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isHighlighted
                ? AppColors.gold
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          plainText,
          style: scaledStyle?.copyWith(
            height: 1.45,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Text(
      plainText,
      style: scaledStyle?.copyWith(height: 1.5, fontWeight: FontWeight.w400),
    );
  }

  bool _isHighlightedLine(String line) {
    final normalized = line.replaceAll('*', '').toLowerCase();
    return normalized.startsWith('kiitikio') ||
        normalized.startsWith('response') ||
        normalized.startsWith('r:') ||
        normalized.startsWith('v:') ||
        normalized.startsWith('k:') ||
        normalized.startsWith('w:') ||
        normalized.startsWith('k.') ||
        normalized.startsWith('w.') ||
        normalized.startsWith('kiongozi:') ||
        normalized.startsWith('wote:') ||
        normalized.startsWith('tuombe') ||
        normalized.startsWith('let us pray');
  }

  bool _isResponseLine(String line) {
    final normalized = line.toLowerCase();
    return normalized.startsWith('kiitikio') ||
        normalized.startsWith('response') ||
        normalized.startsWith('r:') ||
        normalized.startsWith('w:') ||
        normalized.startsWith('r.') ||
        normalized.startsWith('w.') ||
        normalized.endsWith('utuombee') ||
        normalized.endsWith('pray for us');
  }

  bool _isStRitaHeading(String line) {
    final normalized = line.toLowerCase();
    final lettersOnly = line.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '');
    return (lettersOnly.isNotEmpty && lettersOnly == lettersOnly.toUpperCase()) ||
        normalized.startsWith('tuombe') ||
        normalized.startsWith('let us pray');
  }
}
