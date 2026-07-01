import 'package:my_first_app/core/network/json_utils.dart';

class ShippingOption {
  const ShippingOption({
    required this.id,
    required this.title,
    required this.price,
  });

  final String id;
  final String title;
  final double price;

  factory ShippingOption.fromJson(Map<String, dynamic> json) {
    return ShippingOption(
      id: readString(json['id']),
      title: readString(json['title']),
      price: readDouble(json['price']),
    );
  }
}

class ShippingSettings {
  const ShippingSettings({
    this.freeShippingMinimum = 5000,
    this.freeShippingEnabled = true,
    this.options = const [],
  });

  final double freeShippingMinimum;
  final bool freeShippingEnabled;
  final List<ShippingOption> options;

  String freeShippingMessage(String Function(double) formatPrice) =>
      'Free shipping on orders over ${formatPrice(freeShippingMinimum)}';

  ShippingOption? optionById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  ShippingOption? get defaultOption =>
      options.isNotEmpty ? options.first : null;

  double get dhakaRate =>
      _findByKeywords(const ['inside', 'dhaka'])?.price ??
      defaultOption?.price ??
      80;

  double get outsideRate =>
      _findByKeywords(const ['outside'])?.price ??
      (options.length > 1 ? options[1].price : 120);

  ShippingOption? _findByKeywords(List<String> keywords) {
    for (final option in options) {
      final title = option.title.toLowerCase();
      if (keywords.every((word) => title.contains(word))) {
        return option;
      }
      if (keywords.any((word) => title.contains(word))) {
        return option;
      }
    }
    return null;
  }

  factory ShippingSettings.fromJson(Map<String, dynamic> json) {
    final shipping = asJsonMap(
      json['shipping'] ?? json['shipping_settings'] ?? json['delivery'],
    );

    final options = asJsonList(shipping['options'])
        .map((e) => ShippingOption.fromJson(asJsonMap(e)))
        .where((option) => option.title.isNotEmpty)
        .toList();

    return ShippingSettings(
      freeShippingMinimum: readDouble(
        shipping['free_shipping_minimum'] ??
            shipping['free_shipping_min'] ??
            shipping['free_shipping_amount'] ??
            shipping['free_shipping_threshold'] ??
            json['free_shipping_minimum'],
        5000,
      ),
      freeShippingEnabled: readBool(
        shipping['free_shipping_enabled'],
        readDouble(shipping['free_shipping_minimum'], 5000) > 0,
      ),
      options: options,
    );
  }
}

class ShippingQuote {
  const ShippingQuote({
    required this.shippingId,
    required this.title,
    required this.price,
    required this.isFree,
    required this.freeShippingMinimum,
  });

  final String? shippingId;
  final String title;
  final double price;
  final bool isFree;
  final double freeShippingMinimum;

  factory ShippingQuote.fromJson(Map<String, dynamic> json) {
    return ShippingQuote(
      shippingId: readNullableString(json['shipping_id']),
      title: readString(json['title']),
      price: readDouble(json['price']),
      isFree: readBool(json['is_free'], false),
      freeShippingMinimum: readDouble(json['free_shipping_minimum']),
    );
  }
}
