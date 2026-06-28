import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
    this.formatPrice,
  });

  final double subtotal;
  final double shipping;
  final double discount;
  final double total;
  final String Function(double)? formatPrice;

  String _format(double value) =>
      formatPrice?.call(value) ?? '৳${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _Row(label: 'Subtotal', value: _format(subtotal)),
          const SizedBox(height: 8),
          _Row(
            label: 'Shipping',
            value: shipping == 0 ? 'FREE' : _format(shipping),
            valueColor: shipping == 0 ? AppColors.success : null,
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _Row(
              label: 'Discount',
              value: '-${_format(discount)}',
              valueColor: AppColors.success,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _Row(
            label: 'Total',
            value: _format(total),
            isBold: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: valueColor ?? AppColors.textPrimary,
        );

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}
