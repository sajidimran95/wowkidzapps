import 'package:flutter/material.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/home/pages/product_collection_page.dart';
import 'package:my_first_app/features/home/widgets/flash_deal_banner.dart';
import 'package:my_first_app/features/home/widgets/product_card.dart';
import 'package:my_first_app/shared/utils/product_add_to_cart.dart';
import 'package:my_first_app/shared/utils/product_sort.dart';
import 'package:my_first_app/shared/widgets/section_header.dart';

class ProductSection extends StatelessWidget {
  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    this.subtitle,
    this.showViewAll = true,
    this.isFlashDeal = false,
    this.sectionKey,
    this.endDate,
  });

  final String title;
  final String? subtitle;
  final List<Product> products;
  final bool showViewAll;
  final bool isFlashDeal;
  final String? sectionKey;
  final DateTime? endDate;

  void _openViewAll(BuildContext context, List<Product> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductCollectionPage(
          title: title,
          products: items,
          sectionKey: sectionKey,
        ),
      ),
    );
  }

  static const _sectionHeight = 328.0;

  @override
  Widget build(BuildContext context) {
    final items = sortProductsStockFirst(products);
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFlashDeal)
          FlashDealBanner(
            title: title,
            endDate: endDate,
            onViewAll: showViewAll ? () => _openViewAll(context, items) : null,
          )
        else
          SectionHeader(
            title: title,
            subtitle: subtitle,
            onViewAll: showViewAll ? () => _openViewAll(context, items) : null,
          ),
        SizedBox(
          height: _sectionHeight,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16, 0, 16, isFlashDeal ? 8 : 4),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              return SizedBox(
                height: _sectionHeight,
                child: ProductCard(
                  product: items[index],
                  onAddToCart: () =>
                      handleProductAddToCart(context, items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
