import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/customer_order.dart';
import 'package:my_first_app/features/dashboard/widgets/dashboard_order_tile.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key, this.initialFilter});

  final OrderStatus? initialFilter;

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _filters = <({String label, bool runningOnly, OrderStatus? status})>[
    (label: 'All', runningOnly: false, status: null),
    (label: 'Running', runningOnly: true, status: null),
    (label: 'Delivered', runningOnly: false, status: OrderStatus.delivered),
    (label: 'Cancelled', runningOnly: false, status: OrderStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    var initialIndex = 0;
    if (widget.initialFilter == OrderStatus.delivered) {
      initialIndex = 2;
    } else if (widget.initialFilter == OrderStatus.cancelled) {
      initialIndex = 3;
    } else if (widget.initialFilter != null) {
      initialIndex = 1;
    }
    _tabController = TabController(
      length: _filters.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CustomerOrder> _ordersForFilter(
    ({String label, bool runningOnly, OrderStatus? status}) filter,
  ) {
    return AppController.instance.ordersForFilter(
      runningOnly: filter.runningOnly,
      status: filter.status,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppController.instance,
      builder: (context, _) {
        return Column(
          children: [
            Container(
              color: AppColors.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                tabs: _filters.map((f) {
                  final count = _ordersForFilter(f).length;
                  return Tab(text: '${f.label} ($count)');
                }).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _filters.map((filter) {
                  final orders = _ordersForFilter(filter);
                  if (orders.isEmpty) {
                    return const _EmptyOrders();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (_, i) => DashboardOrderTile(order: orders[i]),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'No orders here',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
