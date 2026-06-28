import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// Same gradient used for every section title (Featured Categories style).
const List<Color> kSectionTitleGradient = [
  AppColors.primary,
  AppColors.secondary,
  AppColors.accent,
];

class GradientSectionTitle extends StatelessWidget {
  const GradientSectionTitle({
    super.key,
    required this.title,
    this.style,
  });

  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    const colors = kSectionTitleGradient;
    final textStyle = (style ?? Theme.of(context).textTheme.titleLarge)?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        );

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(title, style: textStyle),
    );
  }
}
