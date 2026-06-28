import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/mock/mock_data.dart';
import 'package:my_first_app/data/models/category_item.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/product/widgets/product_grid_tile.dart';
import 'package:my_first_app/shared/utils/cart_snackbar.dart';
import 'package:my_first_app/shared/widgets/category_image.dart';

class CategoryProductsPage extends StatefulWidget {
  const CategoryProductsPage({super.key, required this.category});

  final CategoryItem category;

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  String _sort = 'Popular';

  List<Product> get _products {
    final items = MockData.productsByCategory(widget.category.name);
    final sorted = List<Product>.of(items);
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
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
        ],
      ),
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
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
              '${products.length} products found',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CategoryImage(category: widget.category, size: 72),
                          const SizedBox(height: 16),
                          Text(
                            'No products yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Products for ${widget.category.name} coming soon.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
