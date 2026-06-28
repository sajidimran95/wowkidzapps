import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/product/widgets/product_grid_tile.dart';
import 'package:my_first_app/shared/utils/cart_snackbar.dart';

class ProductCollectionPage extends StatefulWidget {
  const ProductCollectionPage({
    super.key,
    required this.title,
    required this.products,
  });

  final String title;
  final List<Product> products;

  @override
  State<ProductCollectionPage> createState() => _ProductCollectionPageState();
}

class _ProductCollectionPageState extends State<ProductCollectionPage> {
  String _sort = 'Popular';

  List<Product> get _products {
    final sorted = List<Product>.of(widget.products);
    switch (_sort) {
      case 'Price: Low':
        sorted.sort((a, b) => a.salePrice.compareTo(b.salePrice));
      case 'Price: High':
        sorted.sort((a, b) => b.salePrice.compareTo(a.salePrice));
      case 'Discount':
        sorted.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final products = _products;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['Popular', 'Price: Low', 'Price: High', 'Discount']
                  .map((sort) {
                final selected = _sort == sort;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(sort),
                    selected: selected,
                    onSelected: (_) => setState(() => _sort = sort),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              '${products.length} products',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductGridTile(
                  product: product,
                  onAddToCart: () {
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
      ),
    );
  }
}
