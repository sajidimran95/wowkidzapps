import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/home/pages/product_collection_page.dart';
import 'package:my_first_app/features/product/widgets/product_grid_tile.dart';
import 'package:my_first_app/shared/utils/product_add_to_cart.dart';
import 'package:my_first_app/shared/utils/product_sort.dart';
import 'package:my_first_app/shared/widgets/section_header.dart';

/// Vertical recommended grid — shows all available recommended products (max 20).
class RecommendedProductGrid extends StatelessWidget {
  const RecommendedProductGrid({
    super.key,
    required this.title,
    required this.products,
    this.sectionKey,
    this.maxCount = CatalogStore.recommendedHomeMax,
  });

  final String title;
  final List<Product> products;
  final String? sectionKey;
  final int maxCount;

  void _openViewAll(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductCollectionPage(
          title: title,
          products: products,
          sectionKey: sectionKey,
        ),
      ),
    );
  }

  String _countLabel(int count) {
    if (count == 0) return '';
    if (count == 1) return '1 recommended product';
    return '$count recommended products';
  }

  @override
  Widget build(BuildContext context) {
    final items = sortProductsStockFirst(products).take(maxCount).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: _countLabel(items.length),
          onViewAll: sectionKey != null ? () => _openViewAll(context) : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.56,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductGridTile(
                product: product,
                onAddToCart: () => handleProductAddToCart(context, product),
              );
            },
          ),
        ),
      ],
    );
  }
}
