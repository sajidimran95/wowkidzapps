import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/cart_item.dart';
import 'package:my_first_app/shared/utils/cart_auth.dart';
import 'package:my_first_app/features/checkout/pages/checkout_page.dart';
import 'package:my_first_app/shared/widgets/empty_state.dart';
import 'package:my_first_app/shared/widgets/free_shipping_progress.dart';
import 'package:my_first_app/shared/widgets/order_summary_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _couponController = TextEditingController();
  String? _couponMessage;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon(AppController controller) async {
    final applied = await controller.applyPromo(_couponController.text);
    if (!mounted) return;
    setState(() {
      _couponMessage = applied
          ? 'Coupon applied! 5% discount'
          : 'Invalid coupon code';
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.items.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('My Cart')),
            body: EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Browse categories and add items you love.',
              actionLabel: 'Browse Categories',
              onAction: () => controller.goToCategory(context),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('My Cart (${controller.cartCount})'),
            actions: [
              TextButton(
                onPressed: controller.clearCart,
                child: const Text('Clear'),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _CartItemTile(item: controller.items[index]);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Coupon Code',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              decoration: InputDecoration(
                                hintText: 'Enter coupon (e.g. WOWKIDZ)',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _applyCoupon(controller),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      if (_couponMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _couponMessage!,
                          style: TextStyle(
                            fontSize: 11,
                            color: controller.promoApplied
                                ? AppColors.success
                                : AppColors.discount,
                          ),
                        ),
                      ],
                      if (controller.shippingSettings.freeShippingEnabled) ...[
                        const SizedBox(height: 8),
                        FreeShippingProgressBanner(
                        subtotal: controller.subtotal,
                        freeShippingMinimum:
                            controller.shippingSettings.freeShippingMinimum,
                        remaining: controller.freeShippingRemaining,
                        qualifies: controller.qualifiesForFreeShipping,
                        formatPrice: controller.formatPrice,
                      ),
                      const SizedBox(height: 8),
                      ],
                      OrderSummaryCard(
                        subtotal: controller.subtotal,
                        shipping: controller.qualifiesForFreeShipping
                            ? 0
                            : controller.shippingSettings.dhakaRate,
                        shippingLabel: controller.qualifiesForFreeShipping
                            ? null
                            : 'At checkout',
                        discount: controller.discount,
                        total: controller.cartTotal,
                        formatPrice: controller.formatPrice,
                        compact: true,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (!await ensureCheckoutAccess(context)) return;
                          if (!context.mounted) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Proceed to Checkout • ${controller.formatPrice(controller.cartTotal)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 80,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                _SizeSelector(item: item),
                const SizedBox(height: 8),
                Text(
                  item.formattedLineTotal,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () => controller.updateQuantity(
                        item,
                        item.quantity - 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () => controller.updateQuantity(
                        item,
                        item.quantity + 1,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => controller.removeItem(item),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.discount,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;

    return Row(
      children: [
        Text(
          'Size:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.background,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: item.product.sizes.contains(item.size)
                    ? item.size
                    : item.product.sizes.first,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                items: item.product.sizes
                    .map(
                      (size) => DropdownMenuItem(
                        value: size,
                        child: Text(size),
                      ),
                    )
                    .toList(),
                onChanged: (size) {
                  if (size != null) controller.updateSize(item, size);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
