import 'package:my_first_app/data/models/customer_order.dart';
import 'package:my_first_app/data/models/payment_session.dart';

/// Mock payment API — simulates create-session and verify-payment calls.
class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  Future<PaymentSession> createSession(CustomerOrder order) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return PaymentSession(
      sessionId: 'PAY-${order.id}-${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      amount: order.total,
      gateway: order.paymentMethod,
      merchantName: 'WowKidz',
    );
  }

  Future<PaymentResult> verifyPayment({
    required String sessionId,
    required String pin,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (pin.trim().length < 4) {
      throw PaymentException('Please enter a valid 4-digit PIN');
    }

    if (pin.trim() == '0000') {
      throw PaymentException('Payment declined. Try another PIN.');
    }

    return PaymentResult(
      success: true,
      transactionId: 'TXN-${sessionId.substring(sessionId.length - 8)}',
    );
  }
}
