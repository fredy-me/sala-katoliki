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

    return Text.rich(
      TextSpan(
        style: effectiveStyle,
        children: _buildSpans(text, effectiveStyle, responseStyle),
      ),
      textAlign: textAlign,
    );
  }

  List<TextSpan> _buildSpans(
    String value,
    TextStyle? baseStyle,
    TextStyle? responseStyle,
  ) {
    final lines = value.split('\n');
    final spans = <TextSpan>[];

    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      spans.add(
        TextSpan(
          text: line,
          style: _isResponseLine(line) ? responseStyle : baseStyle,
        ),
      );
      if (index != lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
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
}
