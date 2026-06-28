import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/shared/utils/cart_snackbar.dart';
import 'package:my_first_app/features/home/widgets/product_card.dart';
import 'package:my_first_app/shared/widgets/section_header.dart';
class ProductSection extends StatelessWidget {
  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    this.subtitle,
    this.accentColor,
    this.showViewAll = false,
    this.isFlashDeal = false,
  });

  final String title;
  final String? subtitle;
  final List<Product> products;
  final Color? accentColor;
  final bool showViewAll;
  final bool isFlashDeal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFlashDeal)
          _FlashDealHeader()
        else
          SectionHeader(
            title: title,
            subtitle: subtitle,
            accentColor: accentColor,
            onViewAll: showViewAll ? () {} : null,
          ),
        SizedBox(
          height: 370,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              return ProductCard(
                product: products[index],
                onAddToCart: () {
                  final product = products[index];
                  AppController.instance.addToCart(
                    product,
                    size: product.sizes.first,
                  );
                  showAddedToCartSnackBar(context, product.name);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FlashDealHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.flashDeal, Color(0xFFFF6B81)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            'Flash Deal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Ends Soon',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
