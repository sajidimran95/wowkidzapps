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
