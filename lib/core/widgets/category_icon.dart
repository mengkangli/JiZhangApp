import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'app_icon_data.dart';

class CategoryIcon extends StatelessWidget {
  final int iconCodePoint;
  final Color color;
  final double size;

  const CategoryIcon({
    super.key,
    required this.iconCodePoint,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacityMuted),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Icon(
        AppIconData.fromCodePoint(iconCodePoint),
        color: color,
        size: size * 0.55,
      ),
    );
  }
}
