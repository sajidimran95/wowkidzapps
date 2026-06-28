import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/cart/pages/cart_page.dart';
import 'package:my_first_app/features/category/pages/category_page.dart';
import 'package:my_first_app/features/home/pages/home_page.dart';
import 'package:my_first_app/features/auth/pages/login_page.dart';
import 'package:my_first_app/features/dashboard/pages/addresses_page.dart';
import 'package:my_first_app/features/dashboard/pages/customer_dashboard_page.dart';
import 'package:my_first_app/features/dashboard/pages/help_support_page.dart';
import 'package:my_first_app/shared/widgets/whatsapp_fab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _controller = AppController.instance;
  final _catalog = CatalogStore.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _catalog]),
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _controller.selectedTab,
            children: const [
              HomePage(),
              CategoryPage(),
              CartPage(),
              _AccountPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _controller.selectedTab,
            onTap: _controller.selectTab,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'Category',
              ),
              BottomNavigationBarItem(
                icon: _CartIcon(count: _controller.cartCount),
                activeIcon: _CartIcon(count: _controller.cartCount, active: true),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
          floatingActionButton: const WhatsAppFab(),
        );
      },
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count, this.active = false});

  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.shopping_cart : Icons.shopping_cart_outlined),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.flashDeal,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 9 ? '9+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AccountPage extends StatelessWidget {
  const _AccountPage();

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Account'),
            actions: [
              if (controller.isLoggedIn)
                TextButton(
                  onPressed: controller.logout,
                  child: const Text('Logout'),
                ),
            ],
          ),
          body: ListView(
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: controller.isLoggedIn
                          ? Text(
                              controller.userName?.substring(0, 1) ?? 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.isLoggedIn
                                ? controller.userName ?? 'User'
                                : 'Welcome to WowKidz',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.isLoggedIn
                                ? controller.userContact ?? ''
                                : 'Sign in to track orders',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                          if (controller.isLoggedIn &&
                              controller.userRole != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                controller.userRole!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!controller.isLoggedIn)
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('Login'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomerDashboardPage(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('Dashboard'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                title: 'My Orders',
                onTap: () => _openDashboard(context, controller, 1),
              ),
              _MenuTile(
                icon: Icons.favorite_border,
                title: 'Wishlist',
                onTap: () => _openDashboard(context, controller, 2),
              ),
              _MenuTile(
                icon: Icons.location_on_outlined,
                title: 'Addresses',
                onTap: () => _openSignedIn(
                  context,
                  controller,
                  const AddressesPage(),
                ),
              ),
              _MenuTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => _openSignedIn(
                  context,
                  controller,
                  const HelpSupportPage(),
                ),
              ),
              _MenuTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Visit wowkidzbd.com for our privacy policy.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDashboard(
    BuildContext context,
    AppController controller,
    int tab,
  ) {
    _openSignedIn(
      context,
      controller,
      CustomerDashboardPage(initialTab: tab),
    );
  }

  void _openSignedIn(
    BuildContext context,
    AppController controller,
    Widget page,
  ) {
    if (!controller.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
