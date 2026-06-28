import 'package:my_first_app/core/network/json_utils.dart';

class PaymentSession {
  const PaymentSession({
    required this.sessionId,
    required this.orderId,
    required this.amount,
    required this.gateway,
    required this.merchantName,
  });

  final String sessionId;
  final String orderId;
  final double amount;
  final String gateway;
  final String merchantName;

  factory PaymentSession.fromJson(Map<String, dynamic> json) {
    return PaymentSession(
      sessionId: readString(json['session_id'] ?? json['sessionId']),
      orderId: readString(json['order_id'] ?? json['orderId']),
      amount: readDouble(json['amount']),
      gateway: readString(json['gateway'] ?? json['payment_method'], 'Online'),
      merchantName: readString(json['merchant_name'] ?? json['merchant'], 'WowKidz'),
    );
  }
}

class PaymentResult {
  const PaymentResult({
    required this.success,
    required this.transactionId,
  });

  final bool success;
  final String transactionId;
}

class PaymentException implements Exception {
  PaymentException(this.message);
  final String message;

  @override
  String toString() => message;
}
