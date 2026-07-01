import 'package:flutter/material.dart';

import 'package:my_first_app/core/app/app_controller.dart';

import 'package:my_first_app/core/theme/app_colors.dart';

import 'package:my_first_app/data/models/customer_order.dart';

import 'package:my_first_app/features/checkout/widgets/order_success_fireworks.dart';

import 'package:my_first_app/features/dashboard/widgets/animated_order_status_timeline.dart';



class OrderSuccessPage extends StatelessWidget {

  const OrderSuccessPage({

    super.key,

    required this.orderId,

    required this.total,

    this.paymentMethod = 'Cash on Delivery',

    this.paymentStatus = OrderPaymentStatus.paid,

  });



  final String orderId;

  final double total;

  final String paymentMethod;

  final OrderPaymentStatus paymentStatus;



  bool get _isCod => CustomerOrder.isCashOnDelivery(paymentMethod);



  OrderPaymentStatus get _effectiveStatus =>

      _isCod ? OrderPaymentStatus.unpaid : paymentStatus;



  @override

  Widget build(BuildContext context) {

    final controller = AppController.instance;

    final isPaid = _effectiveStatus == OrderPaymentStatus.paid;

    final formattedTotal = controller.formatPrice(total);



    return Scaffold(

      backgroundColor: AppColors.background,

      body: Stack(

        children: [

          const Positioned.fill(child: OrderSuccessFireworks()),

          SafeArea(

            child: Column(

              children: [

                _SuccessHeader(isPaid: isPaid),

                Expanded(

                  child: SingleChildScrollView(

                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

                    child: Column(

                      children: [

                        const SizedBox(height: 8),

                        _MessageCard(

                          orderId: orderId,

                          total: formattedTotal,

                          paymentMethod: paymentMethod,

                          paymentStatus: _effectiveStatus,

                        ),

                        const SizedBox(height: 16),

                        AnimatedOrderStatusTimeline(

                          currentStatus: OrderStatus.confirmed,

                          statusHistory: [

                            OrderStatusEvent(

                              status: OrderStatus.confirmed,

                              at: bangladeshNow(),

                            ),

                          ],

                        ),

                        const SizedBox(height: 16),

                        const _InfoBanner(

                          icon: Icons.sms_outlined,

                          text: 'Order confirmation SMS sent to your phone',

                        ),

                        const SizedBox(height: 10),

                        if (isPaid)

                          const _InfoBanner(

                            icon: Icons.email_outlined,

                            text: 'Receipt will be sent to your email',

                          )

                        else

                          _InfoBanner(

                            icon: Icons.payments_outlined,

                            text:

                                'Pay $formattedTotal in cash when your order is delivered',

                          ),

                      ],

                    ),

                  ),

                ),

                _BottomActions(

                  onContinue: () => controller.goToHome(context),

                  onTrack: () {

                    controller.goToTab(4, context);

                  },

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}



class _SuccessHeader extends StatelessWidget {

  const _SuccessHeader({required this.isPaid});



  final bool isPaid;



  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),

      decoration: const BoxDecoration(

        gradient: LinearGradient(

          colors: [AppColors.primary, AppColors.secondary],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

        ),

        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),

      ),

      child: Column(

        children: [

          Stack(

            alignment: Alignment.center,

            children: [

              Container(

                width: 110,

                height: 110,

                decoration: BoxDecoration(

                  color: Colors.white.withValues(alpha: 0.15),

                  shape: BoxShape.circle,

                ),

              ),

              Container(

                width: 88,

                height: 88,

                decoration: const BoxDecoration(

                  color: Colors.white,

                  shape: BoxShape.circle,

                ),

                child: Icon(

                  isPaid ? Icons.check_rounded : Icons.local_shipping_outlined,

                  size: 52,

                  color: isPaid ? AppColors.success : AppColors.accent,

                ),

              ),

              Positioned(

                top: 8,

                right: 72,

                child: Icon(

                  Icons.celebration,

                  color: Colors.white.withValues(alpha: 0.85),

                  size: 22,

                ),

              ),

              Positioned(

                bottom: 12,

                left: 68,

                child: Icon(

                  Icons.star_rounded,

                  color: Colors.amber.shade300,

                  size: 20,

                ),

              ),

            ],

          ),

          const SizedBox(height: 20),

          Text(

            'Order Placed Successfully!',

            textAlign: TextAlign.center,

            style: Theme.of(context).textTheme.titleLarge?.copyWith(

                  color: Colors.white,

                  fontWeight: FontWeight.w800,

                ),

          ),

          const SizedBox(height: 8),

          Text(

            isPaid

                ? 'Thank you for shopping with WowKidz 🎉'

                : 'Pay on delivery when your order arrives 🎉',

            textAlign: TextAlign.center,

            style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                  color: Colors.white.withValues(alpha: 0.9),

                ),

          ),

        ],

      ),

    );

  }

}



class _MessageCard extends StatelessWidget {

  const _MessageCard({

    required this.orderId,

    required this.total,

    required this.paymentMethod,

    required this.paymentStatus,

  });



  final String orderId;

  final String total;

  final String paymentMethod;

  final OrderPaymentStatus paymentStatus;



  bool get _isPaid => paymentStatus == OrderPaymentStatus.paid;



  @override

  Widget build(BuildContext context) {

    return Transform.translate(

      offset: const Offset(0, -20),

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: AppColors.surface,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: AppColors.border),

          boxShadow: [

            BoxShadow(

              color: AppColors.primary.withValues(alpha: 0.08),

              blurRadius: 20,

              offset: const Offset(0, 8),

            ),

          ],

        ),

        child: Column(

          children: [

            Container(

              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

              decoration: BoxDecoration(

                color: (_isPaid ? AppColors.success : AppColors.discount)

                    .withValues(alpha: 0.1),

                borderRadius: BorderRadius.circular(20),

              ),

              child: Row(

                mainAxisSize: MainAxisSize.min,

                children: [

                  Icon(

                    _isPaid ? Icons.verified : Icons.schedule_outlined,

                    color: _isPaid ? AppColors.success : AppColors.discount,

                    size: 18,

                  ),

                  const SizedBox(width: 6),

                  Text(

                    _isPaid ? 'Payment Confirmed' : 'Payment Due on Delivery',

                    style: Theme.of(context).textTheme.labelMedium?.copyWith(

                          color:

                              _isPaid ? AppColors.success : AppColors.discount,

                          fontWeight: FontWeight.w700,

                        ),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 18),

            _DetailRow(

              icon: Icons.receipt_long_outlined,

              label: 'Order ID',

              value: orderId,

            ),

            const _Divider(),

            _DetailRow(

              icon: Icons.payments_outlined,

              label: _isPaid ? 'Total Paid' : 'Total Due',

              value: total,

              highlight: true,

            ),

            const _Divider(),

            _DetailRow(

              icon: Icons.account_balance_wallet_outlined,

              label: 'Payment',

              value: paymentMethod,

            ),

            const _Divider(),

            _DetailRow(

              icon: Icons.info_outline,

              label: 'Payment Status',

              value: paymentStatus.label,

              valueColor: paymentStatus.color,

            ),

            const _Divider(),

            const _DetailRow(

              icon: Icons.local_shipping_outlined,

              label: 'Delivery',

              value: '3–5 business days',

            ),

          ],

        ),

      ),

    );

  }

}



class _DetailRow extends StatelessWidget {

  const _DetailRow({

    required this.icon,

    required this.label,

    required this.value,

    this.highlight = false,

    this.valueColor,

  });



  final IconData icon;

  final String label;

  final String value;

  final bool highlight;

  final Color? valueColor;



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        children: [

          Icon(icon, size: 20, color: AppColors.textMuted),

          const SizedBox(width: 10),

          Expanded(

            child: Text(

              label,

              style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                    color: AppColors.textSecondary,

                  ),

            ),

          ),

          Text(

            value,

            style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                  fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,

                  color: valueColor ??

                      (highlight ? AppColors.primary : AppColors.textPrimary),

                  fontSize: highlight ? 16 : 14,

                ),

          ),

        ],

      ),

    );

  }

}



class _Divider extends StatelessWidget {

  const _Divider();



  @override

  Widget build(BuildContext context) {

    return const Padding(

      padding: EdgeInsets.symmetric(vertical: 10),

      child: Divider(height: 1, color: AppColors.border),

    );

  }

}



class _InfoBanner extends StatelessWidget {

  const _InfoBanner({required this.icon, required this.text});



  final IconData icon;

  final String text;



  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      decoration: BoxDecoration(

        color: AppColors.primary.withValues(alpha: 0.06),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: AppColors.primary.withValues(alpha: 0.12),

        ),

      ),

      child: Row(

        children: [

          Icon(icon, size: 20, color: AppColors.primary),

          const SizedBox(width: 10),

          Expanded(

            child: Text(

              text,

              style: Theme.of(context).textTheme.bodySmall?.copyWith(

                    color: AppColors.textSecondary,

                  ),

            ),

          ),

        ],

      ),

    );

  }

}



class _BottomActions extends StatelessWidget {

  const _BottomActions({

    required this.onContinue,

    required this.onTrack,

  });



  final VoidCallback onContinue;

  final VoidCallback onTrack;



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),

      decoration: BoxDecoration(

        color: AppColors.surface,

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

          children: [

            ElevatedButton.icon(

              onPressed: onContinue,

              icon: const Icon(Icons.shopping_bag_outlined, size: 20),

              label: const Text('Continue Shopping'),

              style: ElevatedButton.styleFrom(

                minimumSize: const Size(double.infinity, 52),

              ),

            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(

              onPressed: onTrack,

              icon: const Icon(Icons.location_on_outlined, size: 20),

              label: const Text('Track Order'),

              style: OutlinedButton.styleFrom(

                minimumSize: const Size(double.infinity, 52),

                side: const BorderSide(color: AppColors.primary),

                foregroundColor: AppColors.primary,

              ),

            ),

          ],

        ),

      ),

    );

  }

}


