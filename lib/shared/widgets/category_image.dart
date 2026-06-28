import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/category_item.dart';

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
    final image = _buildImage();

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

  Widget _buildImage() {
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
