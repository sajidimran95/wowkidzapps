import 'package:my_first_app/core/network/json_utils.dart';

class WhatsAppChatConfig {
  const WhatsAppChatConfig({
    this.enabled = false,
    this.number = '',
    this.numberDigits = '',
    this.prefillMessage = 'I am searching for ',
    this.chatUrl,
    this.storeName = 'WowKidz',
    this.productGreeting = '',
    this.productLabels = const {},
  });

  final bool enabled;
  final String number;
  final String numberDigits;
  final String prefillMessage;
  final String? chatUrl;
  final String storeName;
  final String productGreeting;
  final Map<String, String> productLabels;

  factory WhatsAppChatConfig.fromJson(Map<String, dynamic> json) {
    final productOrder = asJsonMap(json['product_order']);
    final labelsRaw = asJsonMap(productOrder['labels']);

    return WhatsAppChatConfig(
      enabled: readBool(json['enabled'], false),
      number: readString(json['number']),
      numberDigits: readString(json['number_digits'] ?? json['numberDigits']),
      prefillMessage: readString(
        json['prefill_message'] ?? json['prefillMessage'],
        'I am searching for ',
      ),
      chatUrl: readNullableString(json['chat_url'] ?? json['chatUrl']),
      storeName: readString(json['store_name'] ?? json['storeName'], 'WowKidz'),
      productGreeting: readString(productOrder['greeting']),
      productLabels: labelsRaw.map(
        (key, value) => MapEntry(key, readString(value)),
      ),
    );
  }

  String get displayContact =>
      number.isNotEmpty ? number : numberDigits;

  String urlForText(String text) {
    if (numberDigits.isEmpty) return '';
    return 'https://wa.me/$numberDigits?text=${Uri.encodeComponent(text)}';
  }

  String productOrderMessage({
    required String productName,
    required String priceText,
    String? size,
    int? quantity,
    String? sku,
    String? productUrl,
  }) {
    final lines = <String>[];
    final greeting = productGreeting.isNotEmpty
        ? productGreeting
        : "Hello! $storeName, I'm interested in:";
    lines.add(greeting);
    lines.add('');
    lines.add('${productLabels['product'] ?? 'Product'}: $productName');
    lines.add('${productLabels['price'] ?? 'Price'}: $priceText');
    if (size != null && size.isNotEmpty) {
      lines.add('${productLabels['attributes'] ?? 'Attributes'}: $size');
    }
    if (quantity != null && quantity > 0) {
      lines.add('${productLabels['quantity'] ?? 'Quantity'}: $quantity');
    }
    if (sku != null && sku.isNotEmpty) {
      lines.add('${productLabels['sku'] ?? 'SKU'}: $sku');
    }
    if (productUrl != null && productUrl.isNotEmpty) {
      lines.add('${productLabels['product_url'] ?? 'Product URL'}: $productUrl');
    }
    return lines.join('\n');
  }
}
