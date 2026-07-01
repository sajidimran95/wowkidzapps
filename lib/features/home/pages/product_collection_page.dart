import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/product/widgets/product_listing_view.dart';
import 'package:my_first_app/shared/utils/product_filters.dart';
import 'package:my_first_app/shared/widgets/api_state_views.dart';

class ProductCollectionPage extends StatefulWidget {
  const ProductCollectionPage({
    super.key,
    required this.title,
    this.products,
    this.sectionKey,
  });

  final String title;
  final List<Product>? products;
  final String? sectionKey;

  @override
  State<ProductCollectionPage> createState() => _ProductCollectionPageState();
}

class _ProductCollectionPageState extends State<ProductCollectionPage> {
  final _catalog = CatalogStore.instance;
  ProductFilterCriteria _filters = const ProductFilterCriteria();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _products = List<Product>.of(widget.products ?? []);
    if (widget.sectionKey != null) {
      _loadSection();
    } else if (_products.isNotEmpty) {
      _enrichProducts();
    }
  }

  Future<void> _loadSection() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products =
          await _catalog.fetchSectionProducts(widget.sectionKey!);
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
        _isLoading = false;
      });
    }
  }

  Future<void> _enrichProducts() async {
    setState(() => _isLoading = true);
    final enriched = await _catalog.enrichProductsWithVariants(_products);
    if (!mounted) return;
    setState(() {
      _products = enriched;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? const ApiLoadingView(message: 'Loading products...')
          : _error != null && _products.isEmpty
              ? ApiErrorView(message: _error!, onRetry: _loadSection)
              : ProductListingView(
                  allProducts: _products,
                  filters: _filters,
                  onFiltersChanged: (filters) =>
                      setState(() => _filters = filters),
                  showCategoryFilter: true,
                  countLabel:
                      '${applyProductFilters(_products, _filters).length} products',
                  emptyWidget: Center(
                    child: Text(
                      'No products in this section yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ),
                ),
    );
  }
}
