import 'package:flutter/material.dart';

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
    final lines = value.split('\n');
    final spans = <TextSpan>[];

    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      spans.add(
        TextSpan(
          text: line,
          style: _styleForLine(
            line,
            baseStyle: baseStyle,
            responseStyle: responseStyle,
            sectionStyle: sectionStyle,
          ),
        ),
      );
      if (index != lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  TextStyle? _styleForLine(
    String line, {
    required TextStyle? baseStyle,
    required TextStyle? responseStyle,
    required TextStyle? sectionStyle,
  }) {
    if (_isResponseLine(line)) {
      return responseStyle;
    }
    if (_isSectionHeadingLine(line)) {
      return sectionStyle;
    }
    return baseStyle;
  }

  bool _isResponseLine(String line) {
    final normalized = line
        .replaceAll('*', '')
        .replaceAll('"', '')
        .replaceAll('“', '')
        .replaceAll('”', '')
        .trim()
        .toLowerCase();

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

  bool _isSectionHeadingLine(String line) {
    final normalized = line.trim();
    if (normalized.length < 4 || normalized.length > 48) {
      return false;
    }
    final hasLetter = RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(normalized);
    if (!hasLetter) {
      return false;
    }
    final lettersOnly = normalized.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '');
    if (lettersOnly.isEmpty) {
      return false;
    }
    return lettersOnly == lettersOnly.toUpperCase();
  }
}
