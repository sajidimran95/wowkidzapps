import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/product/widgets/product_grid_tile.dart';
import 'package:my_first_app/features/search/widgets/live_search_bar.dart';
import 'package:my_first_app/shared/utils/product_add_to_cart.dart';
import 'package:my_first_app/shared/widgets/api_state_views.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.query,
    this.initialProducts,
  });

  final String query;
  final List<Product>? initialProducts;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final _catalog = CatalogStore.instance;
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  late String _query;

  @override
  void initState() {
    super.initState();
    _query = widget.query;
    _searchController.text = _query;
    if (widget.initialProducts != null) {
      _products = List<Product>.of(widget.initialProducts!);
      _isLoading = false;
    } else if (_query.isNotEmpty) {
      _runSearch();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _query = query;
    });

    try {
      final products = await _catalog.searchProducts(query);
      if (!mounted) return;
      setState(() {
        _products = products;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: LiveSearchBar(
          inline: true,
          controller: _searchController,
          hintText: 'Search products...',
          onSubmitted: (_) => _runSearch(),
        ),
      ),
      body: _isLoading
          ? const ApiLoadingView(message: 'Searching...')
          : _error != null
              ? ApiErrorView(message: _error!, onRetry: _runSearch)
              : _query.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Type a product name and press search.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  : _products.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 56,
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results for "$_query"',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different keyword or check spelling.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Text(
                            '${_products.length} results for "$_query"',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.56,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return ProductGridTile(
                                product: product,
                                onAddToCart: () => handleProductAddToCart(context, product),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
