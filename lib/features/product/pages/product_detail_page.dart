import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/services/whatsapp_launcher.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/auth/pages/login_page.dart';
import 'package:my_first_app/shared/utils/cart_auth.dart';
import 'package:my_first_app/shared/utils/cart_snackbar.dart';
import 'package:my_first_app/features/product/widgets/product_variant_chips.dart';
import 'package:my_first_app/shared/utils/product_share.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _product;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  int _imageIndex = 0;
  bool _loadingDetail = false;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _applySelections(_product);
    _loadDetail();
  }

  void _applySelections(Product product) {
    _selectedSize = ProductSelectionDefaults.firstSize(product);
    _selectedColor = ProductSelectionDefaults.firstColor(product);
  }

  Future<void> _loadDetail() async {
    setState(() => _loadingDetail = true);
    final detail =
        await CatalogStore.instance.fetchProductDetail(_product.id);
    if (!mounted) return;

    setState(() {
      _loadingDetail = false;
      if (detail != null) {
        _product = detail;
        _applySelections(_product);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _cartSize => _selectedSize ?? _product.defaultSize;

  bool get _canPurchase => ProductSelectionDefaults.canAddToCart(
        _product,
        size: _selectedSize,
        color: _selectedColor,
      );

  Future<void> _addToCart() async {
    if (!_canPurchase) return;
    if (!await ensureCartAccess(context)) return;
    if (!mounted) return;

    AppController.instance.addToCart(
      _product,
      size: _cartSize,
      quantity: _quantity,
    );
    showAddedToCartSnackBar(context, _product.name);
  }

  Future<void> _buyNow() async {
    if (!_canPurchase) return;
    if (!await ensureCartAccess(context)) return;
    if (!mounted) return;

    AppController.instance.addToCart(
      _product,
      size: _cartSize,
      quantity: _quantity,
    );
    AppController.instance.goToCart(context);
  }

  void _orderOnWhatsApp() {
    final config = CatalogStore.instance.whatsapp;
    if (!config.enabled) return;

    WhatsAppLauncher.openProductOrder(
      config: config,
      productName: _product.name,
      priceText: _product.formattedSalePrice,
      size: _cartSize,
      quantity: _quantity,
      sku: _product.sku.isNotEmpty ? _product.sku : null,
      productUrl:
          _product.productUrl.isNotEmpty ? _product.productUrl : null,
    );
  }

  Future<void> _toggleWishlist(BuildContext context, Product product) async {
    final controller = AppController.instance;
    if (!controller.isLoggedIn) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      if (!context.mounted || !controller.isLoggedIn) return;
    }

    await controller.toggleWishlist(product.id);
    if (!context.mounted) return;

    final inWishlist = controller.isInWishlist(product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          inWishlist
              ? '${product.name} added to wishlist'
              : '${product.name} removed from wishlist',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final whatsapp = CatalogStore.instance.whatsapp;
    final product = _product;
    final shippingSettings = CatalogStore.instance.shippingSettings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            actions: [
              ListenableBuilder(
                listenable: AppController.instance,
                builder: (context, _) {
                  final inWishlist =
                      AppController.instance.isInWishlist(product.id);
                  return IconButton(
                    onPressed: () => _toggleWishlist(context, product),
                    icon: Icon(
                      inWishlist ? Icons.favorite : Icons.favorite_border,
                      color: inWishlist ? AppColors.primary : null,
                    ),
                    tooltip: inWishlist ? 'Remove from wishlist' : 'Add to wishlist',
                  );
                },
              ),
              IconButton(
                onPressed: () => shareProduct(product),
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share product',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: product.allImages.length,
                    onPageChanged: (index) =>
                        setState(() => _imageIndex = index),
                    itemBuilder: (_, index) => CachedNetworkImage(
                      imageUrl: product.allImages[index],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.background,
                      ),
                    ),
                  ),
                  if (product.allImages.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.allImages.length,
                          (i) => Container(
                            width: _imageIndex == i ? 20 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _imageIndex == i
                                  ? AppColors.primary
                                  : Colors.white70,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        product.formattedSalePrice,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        product.formattedOriginalPrice,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.discount,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: product.isPurchasable ? 'In Stock' : 'Out of Stock',
                    color: product.isPurchasable
                        ? AppColors.success
                        : AppColors.discount,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: shippingSettings.freeShippingMessage(
                      (value) => '৳${value.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _InfoRow(
                    icon: Icons.assignment_return_outlined,
                    label: 'Easy returns within 7 days',
                  ),
                  if (product.colors.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ProductVariantChips(
                      title: 'Select Color',
                      options: product.colors,
                      selected: _selectedColor,
                      isAvailable: product.isColorInStock,
                      onSelected: (color) =>
                          setState(() => _selectedColor = color),
                    ),
                  ],
                  if (_loadingDetail) ...[
                    const SizedBox(height: 20),
                    const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ] else if (product.sizes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ProductVariantChips(
                      title: 'Select Size',
                      options: product.sizes,
                      selected: _selectedSize,
                      isAvailable: product.isSizeInStock,
                      onSelected: (size) =>
                          setState(() => _selectedSize = size),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  _QuantityStepper(
                    quantity: _quantity,
                    onChanged: (qty) => setState(() => _quantity = qty),
                    enabled: _canPurchase,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 72),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (whatsapp.enabled) ...[
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: _orderOnWhatsApp,
                    icon: const Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                    label: const Text(
                      'Order on WhatsApp',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      foregroundColor: const Color(0xFF25D366),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _canPurchase ? _addToCart : null,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _canPurchase ? _buyNow : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Buy Now',
                          style: TextStyle(fontSize: 13),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color ?? AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onChanged,
    required this.enabled,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: enabled && quantity > 1
                ? () => onChanged(quantity - 1)
                : null,
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: enabled ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
