import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/customer_order.dart';
import 'package:my_first_app/features/dashboard/utils/pay_now_flow.dart';
import 'package:my_first_app/features/dashboard/widgets/animated_order_status_timeline.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.order});

  final CustomerOrder order;

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final paymentStatus = controller.paymentStatusFor(order);
        final isUnpaid = paymentStatus == OrderPaymentStatus.unpaid;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Order ${order.id}'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      order.status.color,
                      order.status.color.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(order.status.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Status',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            order.status.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      controller.formatPrice(order.total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnpaid) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.discount.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.discount.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.discount),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Payment not completed (${order.paymentMethod})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.discount,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Tracking',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedOrderStatusTimeline(
                      currentStatus: order.status,
                      statusHistory: order.statusHistory,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                children: [
                  _DetailRow(label: 'Order ID', value: order.id),
                  _DetailRow(label: 'Date', value: order.dateLabel),
                  _DetailRow(
                    label: 'Items',
                    value: '${order.itemCount} items — ${order.itemsSummary}',
                  ),
                  _DetailRow(label: 'Payment', value: order.paymentMethod),
                  _DetailRow(
                    label: 'Payment Status',
                    value: paymentStatus.label,
                    valueColor: paymentStatus.color,
                  ),
                  _DetailRow(label: 'Delivery Address', value: order.address),
                ],
              ),
              const SizedBox(height: 16),
              if (isUnpaid)
                ElevatedButton.icon(
                  onPressed: () => startPayNowFlow(context, order),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppColors.discount,
                  ),
                ),
              if (order.status.isRunning) ...[
                if (isUnpaid) const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent_outlined),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
