import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/product/widgets/product_filter_sheet.dart';
import 'package:my_first_app/features/product/widgets/product_grid_tile.dart';
import 'package:my_first_app/shared/utils/product_add_to_cart.dart';
import 'package:my_first_app/shared/utils/product_filters.dart';

class ProductListingView extends StatelessWidget {
  const ProductListingView({
    super.key,
    required this.allProducts,
    required this.filters,
    required this.onFiltersChanged,
    this.emptyWidget,
    this.showCategoryFilter = true,
    this.categoryOptions,
    this.countLabel,
  });

  final List<Product> allProducts;
  final ProductFilterCriteria filters;
  final ValueChanged<ProductFilterCriteria> onFiltersChanged;
  final Widget? emptyWidget;
  final bool showCategoryFilter;
  final List<String>? categoryOptions;
  final String? countLabel;

  List<Product> get _filteredProducts =>
      applyProductFilters(allProducts, filters);

  Future<void> _openFilters(BuildContext context) async {
    final categories = categoryOptions ??
        (showCategoryFilter ? collectProductCategories(allProducts) : <String>[]);
    final sizes = collectProductSizes(allProducts);
    final colors = collectProductColors(allProducts);

    final result = await showProductFilterSheet(
      context: context,
      initial: filters,
      categories: categories,
      sizes: sizes,
      colors: colors,
      showCategoryFilter: showCategoryFilter,
    );

    if (result != null) {
      onFiltersChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    final sortLabels = ProductSort.values
        .map(ProductFilterCriteria.sortLabel)
        .toList();
    final sizes = collectProductSizes(allProducts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  children: sortLabels.map((label) {
                    final sort = ProductFilterCriteria.sortFromLabel(label);
                    final selected = filters.sort == sort;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) => onFiltersChanged(
                          filters.copyWith(sort: sort),
                        ),
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
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
              IconButton(
                onPressed: () => _openFilters(context),
                icon: Badge(
                  isLabelVisible: filters.hasActiveFilters,
                  smallSize: 8,
                  child: const Icon(Icons.tune),
                ),
                tooltip: 'Filter',
              ),
            ],
          ),
        ),
        if (sizes.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              itemCount: sizes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final size = sizes[index];
                final selected = filters.size == size;
                return FilterChip(
                  label: Text(size),
                  selected: selected,
                  onSelected: (_) => onFiltersChanged(
                    selected
                        ? filters.copyWith(clearSize: true)
                        : filters.copyWith(size: size),
                  ),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        if (filters.hasActiveFilters)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (filters.category != null)
                  _ActiveFilterChip(
                    label: filters.category!,
                    onRemove: () => onFiltersChanged(
                      filters.copyWith(clearCategory: true),
                    ),
                  ),
                if (filters.size != null)
                  _ActiveFilterChip(
                    label: 'Size: ${filters.size}',
                    onRemove: () => onFiltersChanged(
                      filters.copyWith(clearSize: true),
                    ),
                  ),
                if (filters.color != null)
                  _ActiveFilterChip(
                    label: 'Color: ${filters.color}',
                    onRemove: () => onFiltersChanged(
                      filters.copyWith(clearColor: true),
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            countLabel ?? '${products.length} products found',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? emptyWidget ??
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No products match your filters.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ),
                  )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.56,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
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

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIconColor: AppColors.primary,
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
