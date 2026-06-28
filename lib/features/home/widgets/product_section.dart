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
    this.showViewAll = false,
    this.isFlashDeal = false,
  });

  final String title;
  final String? subtitle;
  final List<Product> products;
  final bool showViewAll;
  final bool isFlashDeal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
          trailing: isFlashDeal ? const _EndsSoonChip() : null,
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

class _EndsSoonChip extends StatelessWidget {
  const _EndsSoonChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.flashDeal, Color(0xFFFF6B81)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'Ends Soon',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
