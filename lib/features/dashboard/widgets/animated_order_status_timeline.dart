import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/customer_order.dart';

class AnimatedOrderStatusTimeline extends StatefulWidget {
  const AnimatedOrderStatusTimeline({
    super.key,
    required this.currentStatus,
    required this.statusHistory,
  });

  final OrderStatus currentStatus;
  final List<OrderStatusEvent> statusHistory;

  @override
  State<AnimatedOrderStatusTimeline> createState() =>
      _AnimatedOrderStatusTimelineState();
}

class _AnimatedOrderStatusTimelineState extends State<AnimatedOrderStatusTimeline>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final List<Animation<double>> _stepAnimations;

  static const _stepSubtitles = {
    OrderStatus.confirmed: 'Your order has been placed',
    OrderStatus.processing: 'We are preparing your items',
    OrderStatus.packed: 'Items packed and ready to ship',
    OrderStatus.outForDelivery: 'On the way to your address',
    OrderStatus.delivered: 'Successfully delivered',
  };

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    final steps = kOrderTrackingSteps.length;
    _stepAnimations = List.generate(steps, (index) {
      final start = index * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entryController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentStatus == OrderStatus.cancelled) {
      final cancelledAt = widget.statusHistory
          .where((e) => e.status == OrderStatus.cancelled)
          .map((e) => e.at)
          .firstOrNull;
      return _CancelledBanner(cancelledAt: cancelledAt);
    }

    final activeIndex = widget.currentStatus.stepIndex;

    DateTime? timestampFor(OrderStatus status) {
      for (final event in widget.statusHistory) {
        if (event.status == status) return event.at;
      }
      return null;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _pulseController]),
      builder: (context, _) {
        return Column(
          children: [
            for (var i = 0; i < kOrderTrackingSteps.length; i++)
              _AnimatedStep(
                status: kOrderTrackingSteps[i],
                subtitle: _stepSubtitles[kOrderTrackingSteps[i]]!,
                timestamp: timestampFor(kOrderTrackingSteps[i]),
                isDone: i < activeIndex,
                isActive: i == activeIndex,
                isLast: i == kOrderTrackingSteps.length - 1,
                progress: _stepAnimations[i].value,
                pulse: i == activeIndex ? _pulseController.value : 0,
              ),
          ],
        );
      },
    );
  }
}

class _AnimatedStep extends StatelessWidget {
  const _AnimatedStep({
    required this.status,
    required this.subtitle,
    required this.timestamp,
    required this.isDone,
    required this.isActive,
    required this.isLast,
    required this.progress,
    required this.pulse,
  });

  final OrderStatus status;
  final String subtitle;
  final DateTime? timestamp;
  final bool isDone;
  final bool isActive;
  final bool isLast;
  final double progress;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final visible = progress.clamp(0.0, 1.0);
    final dotScale = isActive ? 1.0 + pulse * 0.12 : 1.0;
    final color = isDone
        ? AppColors.success
        : isActive
            ? status.color
            : AppColors.textMuted;

    return Opacity(
      opacity: visible,
      child: Transform.translate(
        offset: Offset(0, (1 - visible) * 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Transform.scale(
                    scale: dotScale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.success
                            : isActive
                                ? status.color.withValues(alpha: 0.15)
                                : AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2.5),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: status.color.withValues(alpha: 0.35),
                                  blurRadius: 8 + pulse * 6,
                                  spreadRadius: pulse * 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isDone
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : isActive
                              ? Icon(status.icon, size: 14, color: status.color)
                              : null,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 3,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              isDone
                                  ? AppColors.success
                                  : AppColors.border,
                              isDone && !isActive
                                  ? AppColors.success.withValues(alpha: 0.5)
                                  : AppColors.border,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDone || isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                      if (timestamp != null && (isDone || isActive)) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 13,
                              color: isActive ? status.color : AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatOrderStatusDateTime(timestamp!),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isActive
                                        ? status.color
                                        : AppColors.textSecondary,
                                    fontWeight:
                                        isActive ? FontWeight.w600 : FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                      if (isActive) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            value: null,
                            backgroundColor: status.color.withValues(alpha: 0.15),
                            color: status.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner({this.cancelledAt});

  final DateTime? cancelledAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.discount.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.discount.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: AppColors.discount),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Cancelled',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.discount,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'This order was cancelled. Contact support if you need help.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (cancelledAt != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 13,
                        color: AppColors.discount,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatOrderStatusDateTime(cancelledAt!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.discount,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
