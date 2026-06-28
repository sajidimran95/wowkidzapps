import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/category_item.dart';
import 'package:my_first_app/shared/widgets/gradient_section_title.dart';

class CategoryImage extends StatelessWidget {
  const CategoryImage({
    super.key,
    required this.category,
    this.size = 76,
    this.borderRadius = 18,
    this.fill = false,
  });

  final CategoryItem category;
  final double size;
  final double borderRadius;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    if (!category.showImage) {
      return _CategoryIconPanel(
        category: category,
        borderRadius: borderRadius,
        fill: fill,
        size: size,
      );
    }

    final image = _buildNetworkImage();

    if (fill) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: category.color.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: image,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: category.color.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      ),
    );
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: category.imageUrl,
      fit: BoxFit.cover,
      width: fill ? double.infinity : size,
      height: fill ? double.infinity : size,
      placeholder: (_, _) => Container(
        color: category.color,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (_, _, _) => Container(
        color: category.color,
        alignment: Alignment.center,
        child: Icon(
          category.icon,
          size: fill ? 36 : size * 0.4,
          color: AppColors.textPrimary.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _CategoryIconPanel extends StatelessWidget {
  const _CategoryIconPanel({
    required this.category,
    required this.borderRadius,
    required this.fill,
    required this.size,
  });

  final CategoryItem category;
  final double borderRadius;
  final bool fill;
  final double size;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      width: fill ? double.infinity : size,
      height: fill ? double.infinity : size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color,
            Color.lerp(category.color, AppColors.primary, 0.25)!,
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: category.color.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            category.icon,
            size: fill ? 42 : size * 0.42,
            color: AppColors.primary.withValues(alpha: 0.75),
          ),
          if (fill) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GradientSectionTitle(
                title: category.name,
                style: TextStyle(
                  fontSize: category.name.length > 14 ? 12 : 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return panel;
  }
}
