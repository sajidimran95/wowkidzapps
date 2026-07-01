import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/product.dart';

class ProductVariantChips extends StatelessWidget {
  const ProductVariantChips({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.isAvailable,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final bool Function(String option) isAvailable;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final available = isAvailable(option);
            final isSelected = selected == option && available;
            return ChoiceChip(
              label: Text(
                available ? option : '$option (Out)',
                style: TextStyle(
                  decoration: available ? null : TextDecoration.lineThrough,
                ),
              ),
              selected: isSelected,
              onSelected: available ? (_) => onSelected(option) : null,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              disabledColor: AppColors.background,
              labelStyle: TextStyle(
                color: available
                    ? (isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary)
                    : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ProductSelectionDefaults {
  static String? firstSize(Product product) {
    for (final size in product.sizes) {
      if (product.isSizeInStock(size)) return size;
    }
    return null;
  }

  static String? firstColor(Product product) {
    for (final color in product.colors) {
      if (product.isColorInStock(color)) return color;
    }
    return null;
  }

  static bool canAddToCart(
    Product product, {
    String? size,
    String? color,
  }) {
    if (!product.isPurchasable) return false;
    if (product.sizes.isNotEmpty) {
      final chosen = size?.trim();
      if (chosen == null || chosen.isEmpty) return false;
      if (!product.isSizeInStock(chosen)) return false;
    }
    if (product.colors.isNotEmpty) {
      final chosen = color?.trim();
      if (chosen == null || chosen.isEmpty) return false;
      if (!product.isColorInStock(chosen)) return false;
    }
    return true;
  }

  /// First in-stock size, or null when user must pick manually.
  static String? pickSize(Product product) => firstSize(product);

  /// First in-stock color, or null when user must pick manually.
  static String? pickColor(Product product) => firstColor(product);
}
