import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../utils/text_split_cache.dart';
import 'text_style_rules.dart';

/// Renders novena body text.
///
/// This widget is deliberately incapable of drawing a card, container,
/// background or border. Any surface that needs a card must wrap this widget
/// in [AppCard] at the call site, so a reading view can never be boxed by
/// accident. See app_optimization.md section 0.1.
class NovenaTextView extends StatelessWidget {
  const NovenaTextView({
    required this.text,
    this.fontScale = 1,
    this.allSaintsStyle = false,
    this.holySpiritStyle = false,
    this.stRitaStyle = false,
    this.thanksgivingStyle = false,
    super.key,
  });

  final String text;
  final double fontScale;
  final bool allSaintsStyle;
  final bool holySpiritStyle;
  final bool stRitaStyle;
  final bool thanksgivingStyle;

  @override
  Widget build(BuildContext context) {
    final paragraphs = TextSplitCache.paragraphs(text);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < paragraphs.length; index += 1) ...[
          if (allSaintsStyle)
            _AllSaintsNovenaParagraph(
              text: paragraphs[index],
              fontScale: fontScale,
              holySpiritStyle: holySpiritStyle,
              stRitaStyle: stRitaStyle,
              thanksgivingStyle: thanksgivingStyle,
            )
          else
            _NovenaParagraph(text: paragraphs[index], fontScale: fontScale),
          if (index != paragraphs.length - 1)
            const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );

    return content;
  }
}

class _AllSaintsNovenaParagraph extends StatelessWidget {
  const _AllSaintsNovenaParagraph({
    required this.text,
    required this.fontScale,
    this.holySpiritStyle = false,
    this.stRitaStyle = false,
    this.thanksgivingStyle = false,
  });

  final String text;
  final double fontScale;
  final bool holySpiritStyle;
  final bool stRitaStyle;
  final bool thanksgivingStyle;

  /// Hoisted so the patterns are compiled once for the app rather than rebuilt
  /// for every paragraph of every novena day.
  static final RegExp _nonLetterPattern = RegExp(r'[^A-Za-zÀ-ÿ]');
  static final RegExp _stRitaResponsePattern = RegExp(
    r'You help the blind[^.]*restored to life\.|Unawasaidia vipofu[^.]*wanarudishiwa uhai\.',
    caseSensitive: false,
  );
  static final RegExp _stRitaRequestPattern = RegExp(
    r'\((?:here make|hapa omba)[^)]+\)',
    caseSensitive: false,
  );
  static final RegExp _stRitaPrayerHeadingPattern = RegExp(
    r'^(LET US PRAY:|TUOMBE:)\s*(.+)$',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    final displayText = text.replaceAll('*', '').trim();
    // 4.3: every classifier below lowercases the same string. Derive it once
    // and thread it through instead of allocating a copy per check.
    final displayLower = displayText.toLowerCase();
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final style = baseStyle?.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * fontScale,
      height: 1.55,
      fontWeight: FontWeight.w400,
    );

    if (_isIntentions(displayLower)) {
      return Text(
        displayText,
        style: style?.copyWith(fontStyle: FontStyle.italic),
      );
    }

    if ((thanksgivingStyle && _isThanksgivingHeading(text)) ||
        _isHeading(displayText, displayLower) ||
        (holySpiritStyle && _isHolySpiritHeading(displayLower))) {
      return Text(
        displayText.toUpperCase(),
        style: style?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      );
    }

    final invocation = _isInvocation(displayLower);
    if (invocation) {
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
            TextSpan(text: displayText),
          ],
        ),
      );
    }

    if (stRitaStyle) {
      final prayerHeading = _splitStRitaPrayerHeading(displayText);
      if (prayerHeading != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prayerHeading.heading.toUpperCase(),
              style: style?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(prayerHeading.body, style: style),
          ],
        );
      }

      final request = _splitStRitaRequest(displayText);
      if (request != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.before.isNotEmpty) Text(request.before, style: style),
            if (request.before.isNotEmpty)
              const SizedBox(height: AppSpacing.sm),
            Text(
              request.placeholder,
              style: style?.copyWith(fontStyle: FontStyle.italic),
            ),
            if (request.after.isNotEmpty) const SizedBox(height: AppSpacing.sm),
            if (request.after.isNotEmpty) Text(request.after, style: style),
          ],
        );
      }

      if (_isStRitaPrayerCount(displayLower)) {
        return Text(
          displayText,
          style: style?.copyWith(fontStyle: FontStyle.italic),
        );
      }

      return Text.rich(
        TextSpan(
          style: style,
          children: _stRitaTextSpans(
            displayText,
            displayLower,
            style?.copyWith(fontStyle: FontStyle.italic),
            style?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Text(displayText, style: style);
  }

  /// [normalized] is [value] lowercased, passed in so it is derived once per
  /// paragraph rather than once per classifier.
  List<InlineSpan> _stRitaTextSpans(
    String value,
    String normalized,
    TextStyle? italicStyle,
    TextStyle? responseStyle,
  ) {
    if (startsWithAny(normalized, kStRitaResponsePrefixes)) {
      return [TextSpan(text: value, style: responseStyle)];
    }

    final matches = _stRitaResponsePattern
        .allMatches(value)
        .toList(growable: false);
    if (matches.isEmpty) {
      return [TextSpan(text: value)];
    }

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: value.substring(cursor, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: italicStyle));
      cursor = match.end;
    }
    if (cursor < value.length) {
      spans.add(TextSpan(text: value.substring(cursor)));
    }
    return spans;
  }

  _StRitaTextSplit? _splitStRitaRequest(String value) {
    final match = _stRitaRequestPattern.firstMatch(value);
    if (match == null) {
      return null;
    }

    return _StRitaTextSplit(
      before: value.substring(0, match.start).trim(),
      placeholder: match.group(0)!.trim(),
      after: value.substring(match.end).trim(),
    );
  }

  _StRitaPrayerHeading? _splitStRitaPrayerHeading(String value) {
    final match = _stRitaPrayerHeadingPattern.firstMatch(value);
    if (match == null) {
      return null;
    }

    return _StRitaPrayerHeading(
      heading: match.group(1)!.trim(),
      body: match.group(2)!.trim(),
    );
  }

  /// [normalized] is [value] lowercased, passed in so it is derived once per
  /// paragraph rather than once per classifier.
  bool _isStRitaPrayerCount(String normalized) {
    return containsAny(normalized, kStRitaPrayerCountFragments);
  }

  /// [normalized] is [value] lowercased, passed in so it is derived once per
  /// paragraph rather than once per classifier.
  ///
  /// 4.8: this was eleven literal `startsWith`/`contains` calls. The fragments
  /// are data now, split into the two lists the original code used — the
  /// anchored prefixes and the unanchored `hapa)` fragments — so the
  /// classification is unchanged. Merging them into one `contains` list would
  /// have been broader than the original: it would also match a line that
  /// mentions an intention marker mid-sentence.
  bool _isIntentions(String normalized) {
    return startsWithAny(normalized, kIntentionPrefixes) ||
        containsAny(normalized, kIntentionContainsFragments);
  }

  /// [normalized] is [value] lowercased, passed in so it is derived once per
  /// paragraph rather than once per classifier.
  bool _isInvocation(String normalized) {
    return startsWithAny(normalized, kInvocationPrefixes);
  }

  /// [value] keeps its original case, which the all-caps check depends on;
  /// [normalized] is [value] lowercased.
  bool _isHeading(String value, String normalized) {
    if (equalsAny(normalized, kExactHeadingEquals)) {
      return true;
    }

    if (value.length < 4 || value.length > 48) {
      return false;
    }
    final lettersOnly = value.replaceAll(_nonLetterPattern, '');
    return lettersOnly.isNotEmpty && lettersOnly == lettersOnly.toUpperCase();
  }

  /// [normalized] is [value] lowercased, passed in so it is derived once per
  /// paragraph rather than once per classifier.
  bool _isHolySpiritHeading(String normalized) {
    return equalsAny(normalized, kHolySpiritHeadings);
  }

  bool _isThanksgivingHeading(String value) {
    final trimmed = value.trim();
    return trimmed.startsWith('*') && trimmed.endsWith('*');
  }
}

class _StRitaTextSplit {
  const _StRitaTextSplit({
    required this.before,
    required this.placeholder,
    required this.after,
  });

  final String before;
  final String placeholder;
  final String after;
}

class _StRitaPrayerHeading {
  const _StRitaPrayerHeading({required this.heading, required this.body});

  final String heading;
  final String body;
}

class _NovenaParagraph extends StatelessWidget {
  const _NovenaParagraph({required this.text, required this.fontScale});

  final String text;
  final double fontScale;

  /// Hoisted so the pattern is compiled once for the app rather than rebuilt
  /// for every paragraph of every novena day.
  static final RegExp _requestPlaceholderPattern = RegExp(
    r'\((?:hapa omba|here make)[^)]+\)',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    final displayText = _stripMarkers(text);
    // 4.3: the lowercased form is needed by the cheap gates and by
    // _isStructuredHighlight, so derive it once.
    final displayLower = displayText.toLowerCase();
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final style = baseStyle?.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * fontScale,
      height: 1.55,
      fontWeight: FontWeight.w400,
    );

    // 4.2: the cheap prefix/contains checks run first; the regex-based splits
    // only run when the paragraph could possibly match. Previously all three
    // splits — 8 regexes in total — ran on every paragraph.
    final openingSplit = _isOpening(displayLower)
        ? _splitOpening(displayText)
        : null;
    final requestSplit = _isRequestPlaceholder(displayLower)
        ? _splitRequestPlaceholder(displayText)
        : null;
    final headingSplit = _couldBeHeading(displayLower)
        ? _splitHeading(displayText)
        : null;

    if (openingSplit != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HighlightedParagraph(text: openingSplit.$1, style: style),
          const SizedBox(height: AppSpacing.sm),
          _NovenaParagraph(text: openingSplit.$2, fontScale: fontScale),
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

    if (_isStructuredHighlight(displayLower)) {
      return _HighlightedParagraph(text: displayText, style: style);
    }

    return Text(displayText, style: style);
  }

  String _stripMarkers(String value) {
    return value.replaceAll('*', '').trim();
  }

  /// [normalized] is [text] lowercased, passed in so it is derived once per
  /// paragraph rather than once per classifier.
  bool _isStructuredHighlight(String normalized) {
    return _isOpening(normalized) ||
        _isRequestPlaceholder(normalized) ||
        _isPrayerCount(normalized) ||
        _isLeaderResponse(normalized) ||
        _isStandaloneHeading(normalized);
  }

  (String, String)? _splitOpening(String value) {
    final lines = TextSplitCache.rawLines(value);
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
    final match = _requestPlaceholderPattern.firstMatch(value);
    if (match == null) {
      return null;
    }

    return _RequestSplit(
      before: value.substring(0, match.start).trim(),
      placeholder: match.group(0)!.trim(),
      after: value.substring(match.end).trim(),
    );
  }

  /// Cheap necessary condition for [_splitHeading] to match. The patterns are
  /// case sensitive and anchored at the start, so a paragraph whose lowercased
  /// form contains none of the prefixes cannot match any of them.
  bool _couldBeHeading(String normalized) {
    return containsAny(normalized, kHeadingWithBodyPrefixes);
  }

  _HeadingSplit? _splitHeading(String value) {
    for (final pattern in kHeadingWithBodyPatterns) {
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
    return startsWithAny(value, kInvocationPrefixes);
  }

  bool _isRequestPlaceholder(String value) {
    return containsAny(value, kRequestPlaceholderFragments);
  }

  bool _isPrayerCount(String value) {
    return containsAllOfAnyTriple(value, kPrayerCountTriples);
  }

  bool _isLeaderResponse(String value) {
    return startsWithAny(value, kLeaderResponsePrefixes);
  }

  bool _isStandaloneHeading(String value) {
    return equalsAny(value, kStandaloneHeadingEquals) ||
        startsWithAny(value, kStandaloneHeadingPrefixes);
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
