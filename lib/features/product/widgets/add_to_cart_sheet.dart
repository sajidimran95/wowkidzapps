import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/product/widgets/product_variant_chips.dart';
import 'package:my_first_app/shared/utils/cart_auth.dart';
import 'package:my_first_app/shared/utils/cart_snackbar.dart';

Future<void> promptAddToCart(BuildContext context, Product product) async {
  if (!product.isPurchasable) return;
  if (!await ensureCartAccess(context)) return;
  if (!context.mounted) return;

  final added = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AddToCartSheet(product: product),
  );

  if (added == true && context.mounted) {
    showAddedToCartSnackBar(context, product.name);
  }
}

class AddToCartSheet extends StatefulWidget {
  const AddToCartSheet({super.key, required this.product});

  final Product product;

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  late Product _product = widget.product;
  String? _selectedSize;
  String? _selectedColor;
  bool _loading = true;

  bool get _canAdd => ProductSelectionDefaults.canAddToCart(
        _product,
        size: _selectedSize,
        color: _selectedColor,
      );

  String get _cartSize => _selectedSize ?? _product.defaultSize;

  @override
  void initState() {
    super.initState();
    _applyDefaults(_product);
    _loadDetail();
  }

  void _applyDefaults(Product product) {
    final size = ProductSelectionDefaults.firstSize(product);
    final color = ProductSelectionDefaults.firstColor(product);
    _selectedSize = size;
    _selectedColor = color;
  }

  Future<void> _loadDetail() async {
    final detail =
        await CatalogStore.instance.fetchProductDetail(_product.id);
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (detail != null) {
        _product = detail;
        _applyDefaults(_product);
      }
    });
  }

  Future<void> _addToCart() async {
    if (!_canAdd) return;
    if (!await ensureCartAccess(context)) return;
    if (!mounted) return;

    AppController.instance.addToCart(
      _product,
      size: _cartSize,
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _product.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.categoryPink,
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.categoryPink,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _product.formattedSalePrice,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (_loading) ...[
            const SizedBox(height: 24),
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            if (_product.colors.isNotEmpty) ...[
              const SizedBox(height: 20),
              ProductVariantChips(
                title: 'Select Color',
                options: _product.colors,
                selected: _selectedColor,
                isAvailable: _product.isColorInStock,
                onSelected: (color) => setState(() => _selectedColor = color),
              ),
            ],
            if (_product.sizes.isNotEmpty) ...[
              const SizedBox(height: 20),
              ProductVariantChips(
                title: 'Select Size',
                options: _product.sizes,
                selected: _selectedSize,
                isAvailable: _product.isSizeInStock,
                onSelected: (size) => setState(() => _selectedSize = size),
              ),
            ],
            if (_product.sizes.isEmpty && _product.colors.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _product.inStock
                      ? 'This product is ready to add to your cart.'
                      : 'This product is currently out of stock.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading || !_canAdd ? null : _addToCart,
              child: const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }
}
