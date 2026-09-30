import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../utils/text_split_cache.dart';
import 'text_style_rules.dart';

/// Renders litany text line by line.
///
/// This widget is deliberately incapable of drawing a card, container,
/// background or border. Any surface that needs a card must wrap this widget
/// in [AppCard] at the call site, so a prayer can never be boxed by accident.
/// See app_optimization.md section 0.1.
class LitanyTextView extends StatelessWidget {
  const LitanyTextView({
    required this.text,
    this.fontScale = 1,
    this.stRitaStyle = false,
    super.key,
  });

  final String text;
  final double fontScale;
  final bool stRitaStyle;

  @override
  Widget build(BuildContext context) {
    final lines = TextSplitCache.lines(text);

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

    return content;
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

  /// Hoisted so the pattern is compiled once rather than per line.
  static final RegExp _nonLetterPattern = RegExp(r'[^A-Za-zÀ-ÿ]');

  @override
  Widget build(BuildContext context) {
    final normalized = text
        .replaceAll('"', '')
        .replaceAll('“', '')
        .replaceAll('”', '')
        .trim();
    final isMarked = normalized.contains('*');
    final plainText = normalized.replaceAll('*', '');
    // 4.3: all three classifiers below need a lowercased form of the same
    // string, so derive it once instead of once per classifier.
    final plainLower = plainText.toLowerCase();
    final isHighlighted = isMarked || _isHighlightedLine(plainLower);
    final isLambOfGod = startsWithAny(plainText, kLambOfGodPrefixes);
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final scaledStyle = baseStyle?.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * fontScale,
    );

    if (stRitaStyle) {
      if (_isResponseLine(plainLower)) {
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

      if (_isStRitaHeading(plainLower, plainText)) {
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

  /// [plainLower] is [text] with markers and quotes removed, then lowercased.
  bool _isHighlightedLine(String plainLower) {
    return startsWithAny(plainLower, kResponsePrefixes);
  }

  /// [plainLower] is [text] with markers and quotes removed, then lowercased.
  bool _isResponseLine(String plainLower) {
    return startsWithAny(plainLower, kLitanyResponsePrefixes) ||
        endsWithAny(plainLower, kLitanyResponseSuffixes);
  }

  /// [plainLower] is the lowercased form; [plainText] keeps original case,
  /// which the all-caps check depends on.
  bool _isStRitaHeading(String plainLower, String plainText) {
    final lettersOnly = plainText.replaceAll(_nonLetterPattern, '');
    return (lettersOnly.isNotEmpty &&
            lettersOnly == lettersOnly.toUpperCase()) ||
        startsWithAny(plainLower, kLitanyHeadingPrefixes);
  }
}
