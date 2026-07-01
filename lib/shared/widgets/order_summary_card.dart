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
    this.compact = false,
    this.shippingLabel,
  });

  final double subtotal;
  final double shipping;
  final double discount;
  final double total;
  final String Function(double)? formatPrice;
  final bool compact;
  /// When set (e.g. "At checkout"), shown instead of a numeric shipping value.
  final String? shippingLabel;

  String _format(double value) =>
      formatPrice?.call(value) ?? '৳${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final padding = compact ? 10.0 : 16.0;
    final rowGap = compact ? 4.0 : 8.0;
    final dividerPadding = compact ? 6.0 : 12.0;
    final textStyle = compact
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.bodyMedium;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _Row(
            label: 'Subtotal',
            value: _format(subtotal),
            style: textStyle,
          ),
          SizedBox(height: rowGap),
          _Row(
            label: 'Shipping',
            value: shippingLabel ??
                (shipping == 0 ? 'FREE' : _format(shipping)),
            valueColor: shippingLabel == null && shipping == 0
                ? AppColors.success
                : null,
            style: textStyle,
          ),
          if (discount > 0) ...[
            SizedBox(height: rowGap),
            _Row(
              label: 'Discount',
              value: '-${_format(discount)}',
              valueColor: AppColors.success,
              style: textStyle,
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: dividerPadding),
            child: const Divider(height: 1),
          ),
          _Row(
            label: 'Total',
            value: _format(total),
            isBold: true,
            valueColor: AppColors.primary,
            style: textStyle,
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
    this.style,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolved = style ?? Theme.of(context).textTheme.bodyMedium;
    final rowStyle = resolved?.copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: valueColor ?? AppColors.textPrimary,
        );

    return Row(
      children: [
        Text(label, style: rowStyle),
        const Spacer(),
        Text(value, style: rowStyle),
      ],
    );
  }
}
