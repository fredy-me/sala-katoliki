import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

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
    return Text(
      text,
      textAlign: textAlign,
      style: AppTextStyles.prayerBody.copyWith(
        fontSize: AppTextStyles.prayerBody.fontSize! * fontScale,
      ),
    );
  }
}
