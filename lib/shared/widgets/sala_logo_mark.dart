import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/theme/app_colors.dart';

class SalaLogoMark extends StatelessWidget {
  const SalaLogoMark({
    super.key,
    this.size = 72,
    this.backgroundColor = AppColors.goldSoft,
    this.borderColor = AppColors.gold,
    this.padding = 6,
  });

  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final logicalImageSize = (size - padding * 2).clamp(1.0, double.infinity);
    final cacheWidth = (logicalImageSize * devicePixelRatio).round();

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: ClipOval(
        child: Image.asset(
          AssetPaths.appLogo,
          fit: BoxFit.contain,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.medium,
          semanticLabel: 'Sala Katoliki',
        ),
      ),
    );
  }
}
