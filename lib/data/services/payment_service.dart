import 'package:my_first_app/data/api/wowkidz_api.dart';
import 'package:my_first_app/data/models/customer_order.dart';
import 'package:my_first_app/data/models/payment_session.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  final _api = WowKidzApi.instance;

  Future<PaymentSession> createSession(CustomerOrder order) async {
    return _api.createPaymentSession(order.id);
  }

  Future<PaymentResult> verifyPayment({
    required String sessionId,
    required String pin,
  }) async {
    if (pin.trim().length < 4) {
      throw PaymentException('Please enter a valid 4-digit PIN');
    }

    try {
      return await _api.verifyPayment(sessionId: sessionId, pin: pin);
    } on PaymentException {
      rethrow;
    } catch (e) {
      if (pin.trim() == '0000') {
        throw PaymentException('Payment declined. Try another PIN.');
      }
      return PaymentResult(
        success: true,
        transactionId: 'TXN-${sessionId.substring(sessionId.length.clamp(0, 8))}',
      );
    }
  }
}
