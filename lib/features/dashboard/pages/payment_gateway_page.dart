import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/customer_order.dart';
import 'package:my_first_app/data/models/payment_session.dart';
import 'package:my_first_app/data/services/payment_service.dart';

class PaymentGatewayPage extends StatefulWidget {
  const PaymentGatewayPage({
    super.key,
    required this.order,
    required this.session,
  });

  final CustomerOrder order;
  final PaymentSession session;

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  final _pinController = TextEditingController();
  final _mobileController = TextEditingController(text: '01712345678');
  bool _isPaying = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_isPaying) return;

    setState(() {
      _isPaying = true;
      _error = null;
    });

    try {
      final result = await PaymentService.instance.verifyPayment(
        sessionId: widget.session.sessionId,
        pin: _pinController.text,
      );

      if (!result.success) {
        throw PaymentException('Payment could not be completed');
      }

      AppController.instance.markOrderPaid(widget.order.id);

      if (!mounted) return;
      Navigator.pop(context, true);
    } on PaymentException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isPaying = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isPaying = false;
      });
    }
  }

  Color get _gatewayColor {
    final gateway = widget.session.gateway.toLowerCase();
    if (gateway.contains('bkash')) return const Color(0xFFE2136E);
    if (gateway.contains('nagad')) return const Color(0xFFF69220);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.session.gateway} Payment'),
        backgroundColor: _gatewayColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_gatewayColor, _gatewayColor.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.session.merchantName,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.formatPrice(widget.session.amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order ${widget.order.id}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  'Session: ${widget.session.sessionId}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Enter your ${widget.session.gateway} details to complete payment.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: const Icon(Icons.phone_android_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 5,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'PIN',
              hintText: 'Enter PIN (demo: any 4+ digits)',
              prefixIcon: const Icon(Icons.lock_outline),
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.discount.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.discount.withValues(alpha: 0.3)),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.discount,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isPaying ? null : _pay,
            style: ElevatedButton.styleFrom(
              backgroundColor: _gatewayColor,
              minimumSize: const Size(double.infinity, 52),
            ),
            child: _isPaying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Confirm & Pay'),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter your payment PIN to confirm.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}
