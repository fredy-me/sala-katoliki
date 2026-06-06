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

    return Text(
      text,
      textAlign: textAlign,
      style: baseStyle?.copyWith(
        fontSize: 20 * fontScale,
        height: 1.62,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
