import 'package:flutter/material.dart';

import '../utils/text_split_cache.dart';
import 'text_style_rules.dart';

class PrayerTextView extends StatelessWidget {
  const PrayerTextView({
    required this.text,
    this.textAlign = TextAlign.start,
    this.fontScale = 1,
    super.key,
  });

  final String text;
  final TextAlign textAlign;
  final double fontScale;

  /// Hoisted so the patterns are compiled once for the app rather than rebuilt
  /// for every line of every prayer.
  static final RegExp _italicPattern = RegExp(r'_(.+?)_');
  static final RegExp _hasLetterPattern = RegExp(r'[A-Za-zÀ-ÿ]');
  static final RegExp _nonLetterPattern = RegExp(r'[^A-Za-zÀ-ÿ]');

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineMedium;
    final effectiveStyle = baseStyle?.copyWith(
      fontSize: 20 * fontScale,
      height: 1.62,
      fontWeight: FontWeight.w400,
    );
    final responseStyle = effectiveStyle?.copyWith(
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.primary,
    );
    final sectionStyle = effectiveStyle?.copyWith(
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.primary,
      letterSpacing: 0.4,
    );

    return Text.rich(
      TextSpan(
        style: effectiveStyle,
        children: _buildSpans(
          text,
          effectiveStyle,
          responseStyle,
          sectionStyle,
        ),
      ),
      textAlign: textAlign,
    );
  }

  List<TextSpan> _buildSpans(
    String value,
    TextStyle? baseStyle,
    TextStyle? responseStyle,
    TextStyle? sectionStyle,
  ) {
    final lines = TextSplitCache.rawLines(value);
    final spans = <TextSpan>[];

    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      final lineSpans = _buildLineSpans(
        line,
        baseStyle: baseStyle,
        responseStyle: responseStyle,
        sectionStyle: sectionStyle,
      );
      spans.addAll(lineSpans);
      if (index != lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  List<TextSpan> _buildLineSpans(
    String line, {
    required TextStyle? baseStyle,
    required TextStyle? responseStyle,
    required TextStyle? sectionStyle,
  }) {
    final matches = _italicPattern.allMatches(line).toList();

    if (matches.isEmpty) {
      return [
        TextSpan(
          text: line,
          style: _styleForLine(
            line,
            baseStyle: baseStyle,
            responseStyle: responseStyle,
            sectionStyle: sectionStyle,
          ),
        ),
      ];
    }

    final spans = <TextSpan>[];
    var lastEnd = 0;
    final lineStyle = _styleForLine(
      line,
      baseStyle: baseStyle,
      responseStyle: responseStyle,
      sectionStyle: sectionStyle,
    );

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: line.substring(lastEnd, match.start),
            style: lineStyle,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: lineStyle?.copyWith(fontStyle: FontStyle.italic),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd), style: lineStyle));
    }

    return spans;
  }

  TextStyle? _styleForLine(
    String line, {
    required TextStyle? baseStyle,
    required TextStyle? responseStyle,
    required TextStyle? sectionStyle,
  }) {
    // 4.3: the trimmed form is needed by both checks, so derive it once
    // instead of once per check.
    final trimmed = line.trim();

    if (_isResponseLine(line, trimmed)) {
      return responseStyle;
    }
    if (_isSectionHeadingLine(trimmed)) {
      return sectionStyle;
    }
    return baseStyle;
  }

  bool _isResponseLine(String line, String trimmed) {
    final normalized = line
        .replaceAll('*', '')
        .replaceAll('"', '')
        .replaceAll('“', '')
        .replaceAll('”', '')
        .trim()
        .toLowerCase();

    return startsWithAny(normalized, kResponsePrefixes);
  }

  bool _isSectionHeadingLine(String trimmed) {
    if (trimmed.length < 4 || trimmed.length > 48) {
      return false;
    }
    if (!_hasLetterPattern.hasMatch(trimmed)) {
      return false;
    }
    final lettersOnly = trimmed.replaceAll(_nonLetterPattern, '');
    if (lettersOnly.isEmpty) {
      return false;
    }
    return lettersOnly == lettersOnly.toUpperCase();
  }
}
