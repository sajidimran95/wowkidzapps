import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/customer_order.dart';
import 'package:my_first_app/data/services/payment_service.dart';
import 'package:my_first_app/features/dashboard/pages/payment_gateway_page.dart';

Future<void> startPayNowFlow(BuildContext context, CustomerOrder order) async {
  final controller = AppController.instance;

  if (controller.paymentStatusFor(order) == OrderPaymentStatus.paid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This order is already paid'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Connecting to payment gateway...')),
          ],
        ),
      ),
    ),
  );

  try {
    final session = await PaymentService.instance.createSession(order);
    if (!context.mounted) return;
    Navigator.pop(context);

    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentGatewayPage(order: order, session: session),
      ),
    );

    if (!context.mounted || paid != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment successful for ${order.id}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: $e'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.discount,
      ),
    );
  }
}
