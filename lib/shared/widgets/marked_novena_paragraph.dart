import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../content/reading_markup.dart';

/// Renders declared paragraph roles without inspecting the prayer's wording.
/// Surfaces are limited to the existing per-line highlight treatment.
class MarkedNovenaParagraph extends StatelessWidget {
  const MarkedNovenaParagraph({
    required this.node,
    required this.fontScale,
    super.key,
  });

  final ReadingNode node;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge;
    final style = base?.copyWith(
      fontSize: (base.fontSize ?? 16) * fontScale,
      height: 1.55,
      fontWeight: FontWeight.w400,
    );
    final content = node.content.replaceAll('*', '').trim();
    final value = ReadingMarkup.plainText(content);
    final headingStyle = style?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    );
    switch (node.kind) {
      case 'group':
        final children = ReadingMarkup.parse(content)
            .where(
              (child) =>
                  ReadingMarkup.plainText(child.content).trim().isNotEmpty,
            )
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              MarkedNovenaParagraph(node: children[i], fontScale: fontScale),
              if (i != children.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      case 'heading':
        return Text(value.toUpperCase(), style: headingStyle);
      case 'italic':
        return Text(value, style: style?.copyWith(fontStyle: FontStyle.italic));
      case 'invocation':
        return Text.rich(
          TextSpan(
            style: style?.copyWith(fontWeight: FontWeight.w600),
            children: [
              TextSpan(
                text: '+',
                style: style?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(text: value),
            ],
          ),
        );
      case 'response':
        return Text.rich(
          TextSpan(
            style: style,
            children: [
              TextSpan(
                text: value,
                style: style?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      case 'rich':
        return Text.rich(
          TextSpan(
            style: style,
            children: [
              for (final span in ReadingMarkup.parse(content))
                TextSpan(
                  text: span.content,
                  style: span.kind == 'italic'
                      ? style?.copyWith(fontStyle: FontStyle.italic)
                      : null,
                ),
            ],
          ),
        );
      case 'highlight':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.36)),
          ),
          child: Text(
            value,
            style: style?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      default:
        return Text(value, style: style);
    }
  }
}
