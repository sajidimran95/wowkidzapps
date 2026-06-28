import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/dashboard/pages/dashboard_home_tab.dart';
import 'package:my_first_app/features/dashboard/pages/dashboard_menu_tab.dart';
import 'package:my_first_app/features/dashboard/pages/orders_tab.dart';
import 'package:my_first_app/features/dashboard/pages/wishlist_tab.dart';

class CustomerDashboardShell extends StatefulWidget {
  const CustomerDashboardShell({
    super.key,
    this.initialTab = 0,
  });

  final int initialTab;

  @override
  State<CustomerDashboardShell> createState() => _CustomerDashboardShellState();
}

class _CustomerDashboardShellState extends State<CustomerDashboardShell> {
  late int _tabIndex;
  final _controller = AppController.instance;

  static const _titles = [
    'Dashboard',
    'My Orders',
    'Wishlist',
    'Menu',
  ];

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab.clamp(0, 3);
  }

  void _selectTab(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (_tabIndex != 0) {
              setState(() => _tabIndex = 0);
            } else {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(_titles[_tabIndex]),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_tabIndex != 0) {
                    setState(() => _tabIndex = 0);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    _controller.logout();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                ),
              ],
            ),
            body: IndexedStack(
              index: _tabIndex,
              children: [
                DashboardHomeTab(
                  onViewAllOrders: () => _selectTab(1),
                  onGoToOrdersTab: _selectTab,
                ),
                const OrdersTab(),
                const WishlistTab(),
                DashboardMenuTab(
                  onOrdersTap: () => _selectTab(1),
                  onWishlistTap: () => _selectTab(2),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _tabIndex,
              onTap: _selectTab,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_outlined),
                  activeIcon: Icon(Icons.menu),
                  label: 'Menu',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Entry point kept for existing imports.
class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return CustomerDashboardShell(initialTab: initialTab);
  }
}
