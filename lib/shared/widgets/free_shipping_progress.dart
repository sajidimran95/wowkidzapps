import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

class FreeShippingProgressBanner extends StatelessWidget {
  const FreeShippingProgressBanner({
    super.key,
    required this.subtotal,
    required this.freeShippingMinimum,
    required this.remaining,
    required this.qualifies,
    required this.formatPrice,
  });

  final double subtotal;
  final double freeShippingMinimum;
  final double remaining;
  final bool qualifies;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    final progress = freeShippingMinimum <= 0
        ? 1.0
        : (subtotal / freeShippingMinimum).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: qualifies
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: qualifies
              ? AppColors.success.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                qualifies
                    ? Icons.local_shipping_rounded
                    : Icons.local_shipping_outlined,
                size: 18,
                color: qualifies ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  qualifies
                      ? 'You unlocked FREE shipping!'
                      : 'Add ${formatPrice(remaining)} more for FREE shipping',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: qualifies
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: qualifies ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            qualifies
                ? 'Orders over ${formatPrice(freeShippingMinimum)} ship free'
                : 'Free shipping on orders over ${formatPrice(freeShippingMinimum)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
