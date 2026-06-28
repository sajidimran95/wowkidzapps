import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/pages/login_page.dart';
import 'package:my_first_app/features/auth/pages/signup_page.dart';
import 'package:my_first_app/features/cart/pages/cart_page.dart';
import 'package:my_first_app/features/category/pages/category_page.dart';
import 'package:my_first_app/features/category/pages/category_products_page.dart';
import 'package:my_first_app/features/checkout/pages/checkout_page.dart';
import 'package:my_first_app/features/checkout/pages/order_success_page.dart';
import 'package:my_first_app/features/home/pages/home_page.dart';
import 'package:my_first_app/features/product/pages/product_detail_page.dart';

class DesignPreviewPage extends StatelessWidget {
  const DesignPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = CatalogStore.instance;
    final sampleProduct = catalog.allProducts.firstOrNull;
    final sampleCategory = catalog.categories.firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Pages Preview'),
        actions: [
          TextButton(
            onPressed: () {
              AppController.instance.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear Cart'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(),
          const SizedBox(height: 16),
          _SectionLabel(title: 'Main Tabs'),
          _PreviewTile(
            icon: Icons.home_outlined,
            title: 'Home Page',
            subtitle: 'Banner, categories, flash deals, products',
            color: AppColors.primary,
            onTap: () => _open(context, const _TabPreview(tab: 0)),
          ),
          _PreviewTile(
            icon: Icons.grid_view_outlined,
            title: 'Category Page',
            subtitle: 'All 7 category cards with product counts',
            color: AppColors.secondary,
            onTap: () => _open(context, const _TabPreview(tab: 1)),
          ),
          _PreviewTile(
            icon: Icons.shopping_cart_outlined,
            title: 'Cart Page (with items)',
            subtitle: 'Pre-filled demo cart — qty, promo, checkout',
            color: AppColors.accent,
            onTap: () {
              if (sampleProduct != null) {
                AppController.instance.addToCart(
                  sampleProduct,
                  size: sampleProduct.sizes.first,
                );
              }
              _open(context, const _TabPreview(tab: 2));
            },
          ),
          _PreviewTile(
            icon: Icons.shopping_cart_outlined,
            title: 'Cart Page (empty)',
            subtitle: 'Empty state design',
            color: AppColors.textMuted,
            onTap: () {
              AppController.instance.clearCart();
              _open(context, const _TabPreview(tab: 2));
            },
          ),
          _PreviewTile(
            icon: Icons.person_outline,
            title: 'Account Page',
            subtitle: 'Profile card and menu list',
            color: AppColors.secondary,
            onTap: () => _open(context, const _TabPreview(tab: 3)),
          ),
          _PreviewTile(
            icon: Icons.login,
            title: 'Login Page',
            subtitle: 'Mobile or email sign in',
            color: AppColors.primary,
            onTap: () => _open(context, const LoginPage()),
          ),
          _PreviewTile(
            icon: Icons.person_add_outlined,
            title: 'Sign Up Page',
            subtitle: 'Create account with mobile or email',
            color: AppColors.secondary,
            onTap: () => _open(context, const SignupPage()),
          ),
          const SizedBox(height: 8),
          _SectionLabel(title: 'Product Flow'),
          _PreviewTile(
            icon: Icons.category_outlined,
            title: 'Category Products',
            subtitle: 'Girls Clothing grid with sort filters',
            color: AppColors.categoryPink,
            onTap: () {
              if (sampleCategory == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Load catalog from API first')),
                );
                return;
              }
              _open(
                context,
                CategoryProductsPage(category: sampleCategory),
              );
            },
          ),
          _PreviewTile(
            icon: Icons.inventory_2_outlined,
            title: 'Product Detail',
            subtitle: 'Images, sizes, quantity, add to cart',
            color: AppColors.primary,
            onTap: () {
              if (sampleProduct == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Load catalog from API first')),
                );
                return;
              }
              _open(
                context,
                ProductDetailPage(product: sampleProduct),
              );
            },
          ),
          const SizedBox(height: 8),
          _SectionLabel(title: 'Checkout Flow'),
          _PreviewTile(
            icon: Icons.payment_outlined,
            title: 'Checkout Page',
            subtitle: 'Address form, payment methods, summary',
            color: AppColors.success,
            onTap: () {
              if (sampleProduct != null) {
                AppController.instance.addToCart(
                  sampleProduct,
                  size: sampleProduct.sizes.first,
                );
              }
              _open(context, const CheckoutPage());
            },
          ),
          _PreviewTile(
            icon: Icons.check_circle_outline,
            title: 'Order Success',
            subtitle: 'Confirmation screen after placing order',
            color: AppColors.success,
            onTap: () => _open(
              context,
              const OrderSuccessPage(orderId: 'WK48291', total: 4930),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All pages load data from https://wowkidzbd.com/api when available.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _TabPreview extends StatelessWidget {
  const _TabPreview({required this.tab});

  final int tab;

  static const _pages = [
    HomePage(),
    CategoryPage(),
    CartPage(),
    _AccountPreview(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[tab]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _pages[tab],
    );
  }

  static const _titles = ['Home', 'Categories', 'Cart', 'Account'];
}

class _AccountPreview extends StatelessWidget {
  const _AccountPreview();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to WowKidz',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sign in to track orders',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          child: ListTile(
            leading: Icon(Icons.receipt_long_outlined, color: AppColors.primary),
            title: Text('My Orders'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.favorite_border, color: AppColors.primary),
            title: Text('Wishlist'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.palette_outlined, color: Colors.white, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Static Design Review',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap any page below to preview its design',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
