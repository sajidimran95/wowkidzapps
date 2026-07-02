import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/category_item.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/product/widgets/product_listing_view.dart';
import 'package:my_first_app/features/search/pages/search_results_page.dart';
import 'package:my_first_app/shared/utils/product_filters.dart';
import 'package:my_first_app/shared/widgets/api_state_views.dart';
import 'package:my_first_app/shared/widgets/category_image.dart';

class CategoryProductsPage extends StatefulWidget {
  const CategoryProductsPage({super.key, required this.category});

  final CategoryItem category;

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final _catalog = CatalogStore.instance;
  late ProductFilterCriteria _filters = ProductFilterCriteria(
    category: widget.category.name,
  );
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  String get _activeCategory =>
      _filters.category?.trim().isNotEmpty == true
          ? _filters.category!.trim()
          : widget.category.name;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _catalog.fetchCategoryProducts(_activeCategory);
      final enriched = await _catalog.enrichProductsWithVariants(products);
      if (!mounted) return;
      setState(() {
        _products = enriched;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _products = _catalog.productsByCategory(_activeCategory);
        _isLoading = false;
      });
    }
  }

  void _onFiltersChanged(ProductFilterCriteria filters) {
    final previousCategory = _activeCategory;
    setState(() => _filters = filters);
    final nextCategory = _activeCategory;
    if (nextCategory != previousCategory) {
      _loadProducts();
    }
  }

  List<String> get _categoryOptions {
    final names = _catalog.categories
        .map((c) => c.name)
        .where((name) => name.isNotEmpty)
        .toList();
    if (names.isEmpty) return [_activeCategory];
    return names;
  }

  @override
  Widget build(BuildContext context) {
    final countLabel = _isLoading
        ? 'Loading collection...'
        : '${_products.length} items in this category';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _PinkCategoryHeader(
            title: _activeCategory,
            category: widget.category,
            countLabel: countLabel,
            onSearch: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchResultsPage(query: ''),
                ),
              );
            },
          ),
          Expanded(
            child: _isLoading
                ? const ApiLoadingView(message: 'Loading products...')
                : _error != null && _products.isEmpty
                    ? ApiErrorView(message: _error!, onRetry: _loadProducts)
                    : ProductListingView(
                        allProducts: _products,
                        filters: _filters,
                        onFiltersChanged: _onFiltersChanged,
                        showCategoryFilter: true,
                        categoryOptions: _categoryOptions,
                        emptyWidget: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: AppColors.categoryPink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CategoryImage(
                                    category: widget.category,
                                    size: 72,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Products for $_activeCategory coming soon.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _PinkCategoryHeader extends StatelessWidget {
  const _PinkCategoryHeader({
    required this.title,
    required this.category,
    required this.countLabel,
    required this.onSearch,
  });

  final String title;
  final CategoryItem category;
  final String countLabel;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC2185B),
            AppColors.primary,
            Color(0xFFFF6B9D),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: onSearch,
                    icon: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: CategoryImage(
                          category: category,
                          fill: true,
                          borderRadius: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                countLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
