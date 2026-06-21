import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

class NovenaTextView extends StatelessWidget {
  const NovenaTextView({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList(growable: false);

    return AppCard(
      radius: AppSpacing.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < paragraphs.length; index += 1) ...[
            _NovenaParagraph(text: paragraphs[index]),
            if (index != paragraphs.length - 1)
              const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _NovenaParagraph extends StatelessWidget {
  const _NovenaParagraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final displayText = _stripMarkers(text);
    final style = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(height: 1.55, fontWeight: FontWeight.w400);
    final openingSplit = _splitOpening(displayText);
    final requestSplit = _splitRequestPlaceholder(displayText);
    final headingSplit = _splitHeading(displayText);

    if (openingSplit != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HighlightedParagraph(text: openingSplit.$1, style: style),
          const SizedBox(height: AppSpacing.sm),
          _NovenaParagraph(text: openingSplit.$2),
        ],
      );
    }

    if (requestSplit != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (requestSplit.before.isNotEmpty) ...[
            Text(requestSplit.before, style: style),
            const SizedBox(height: AppSpacing.sm),
          ],
          _HighlightedParagraph(text: requestSplit.placeholder, style: style),
          if (requestSplit.after.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(requestSplit.after, style: style),
          ],
        ],
      );
    }

    if (headingSplit != null) {
      return _HeadingWithBody(
        heading: headingSplit.heading,
        body: headingSplit.body,
        style: style,
      );
    }

    if (_isStructuredHighlight(displayText)) {
      return _HighlightedParagraph(text: displayText, style: style);
    }

    return Text(displayText, style: style);
  }

  String _stripMarkers(String value) {
    return value.replaceAll('*', '').trim();
  }

  bool _isStructuredHighlight(String value) {
    final normalized = value.toLowerCase();

    return _isOpening(normalized) ||
        _isRequestPlaceholder(normalized) ||
        _isPrayerCount(normalized) ||
        _isLeaderResponse(normalized) ||
        _isStandaloneHeading(normalized);
  }

  (String, String)? _splitOpening(String value) {
    final lines = value.split('\n');
    if (lines.length < 2 || !_isOpening(lines.first.toLowerCase())) {
      return null;
    }

    final rest = lines.skip(1).join('\n').trim();
    if (rest.isEmpty) {
      return null;
    }

    return (lines.first.trim(), rest);
  }

  _RequestSplit? _splitRequestPlaceholder(String value) {
    final match = RegExp(
      r'\((?:hapa omba|here make)[^)]+\)',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) {
      return null;
    }

    return _RequestSplit(
      before: value.substring(0, match.start).trim(),
      placeholder: match.group(0)!.trim(),
      after: value.substring(match.end).trim(),
    );
  }

  _HeadingSplit? _splitHeading(String value) {
    final patterns = <RegExp>[
      RegExp(r'^(Kwa njia ya Mtakatifu Rita:-)\s*(.+)$'),
      RegExp(r'^(Kwa maombezi yako:-)\s*(.+)$'),
      RegExp(r'^(TUOMBE:)\s*(.+)$'),
      RegExp(r'^(UTUOMBE:)\s*(.+)$'),
      RegExp(r'^(Through Saint Rita:)\s*(.+)$'),
      RegExp(r'^(Through your intercession:)\s*(.+)$'),
      RegExp(r'^(LET US PRAY:)\s*(.+)$'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(value);
      if (match != null) {
        return _HeadingSplit(
          heading: match.group(1)!.trim(),
          body: match.group(2)!.trim(),
        );
      }
    }

    return null;
  }

  bool _isOpening(String value) {
    return value.startsWith('kwa jina la baba') ||
        value.startsWith('in the name of the father');
  }

  bool _isRequestPlaceholder(String value) {
    return value.contains('(hapa omba') || value.contains('(here make');
  }

  bool _isPrayerCount(String value) {
    final sw =
        value.contains('baba yetu (3)') &&
        value.contains('salamu maria (3)') &&
        value.contains('atukuzwe baba (3)');
    final en =
        value.contains('our father (3)') &&
        value.contains('hail mary (3)') &&
        value.contains('glory be (3)');

    return sw || en;
  }

  bool _isLeaderResponse(String value) {
    return value.startsWith('k:') ||
        value.startsWith('w:') ||
        value.startsWith('v:') ||
        value.startsWith('r:');
  }

  bool _isStandaloneHeading(String value) {
    return value == 'tuombe:' ||
        value == 'utuombe:' ||
        value == 'let us pray:' ||
        value == 'sehemu ya pili' ||
        value == 'part two' ||
        value.startsWith('siku 3 za kumshukuru mungu') ||
        value.startsWith('three days of thanksgiving') ||
        value == 'baba yetu (3), salamu maria (3), atukuzwe baba (3)' ||
        value == 'our father (3), hail mary (3), glory be (3)';
  }
}

class _HeadingWithBody extends StatelessWidget {
  const _HeadingWithBody({
    required this.heading,
    required this.body,
    required this.style,
  });

  final String heading;
  final String body;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HighlightedParagraph(text: heading, style: style),
        const SizedBox(height: AppSpacing.sm),
        Text(body, style: style),
      ],
    );
  }
}

class _HeadingSplit {
  const _HeadingSplit({required this.heading, required this.body});

  final String heading;
  final String body;
}

class _RequestSplit {
  const _RequestSplit({
    required this.before,
    required this.placeholder,
    required this.after,
  });

  final String before;
  final String placeholder;
  final String after;
}

class _HighlightedParagraph extends StatelessWidget {
  const _HighlightedParagraph({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.36)),
      ),
      child: Text(
        text,
        style: style?.copyWith(
          color: colorScheme.onSurface,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
