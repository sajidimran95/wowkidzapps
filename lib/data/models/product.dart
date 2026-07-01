import 'package:my_first_app/core/network/json_utils.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.originalPrice,
    required this.salePrice,
    required this.discountPercent,
    required this.imageUrl,
    this.inStock = true,
    this.description =
        'Premium quality kids wear made with soft, breathable fabric. Perfect for parties and everyday comfort.',
    this.sizes = const [],
    this.colors = const [],
    this.sizeStock = const {},
    this.colorStock = const {},
    this.imageUrls = const [],
    this.slug = '',
    this.productUrl = '',
    this.sku = '',
    this.hasVariants = false,
    this.dealEndDate,
  });

  final String id;
  final String name;
  final String category;
  final double originalPrice;
  final double salePrice;
  final int discountPercent;
  final String imageUrl;
  final bool inStock;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final Map<String, bool> sizeStock;
  final Map<String, bool> colorStock;
  final List<String> imageUrls;
  final String slug;
  final String productUrl;
  final String sku;
  final bool hasVariants;
  final String? dealEndDate;

  List<String> get allImages =>
      imageUrls.isNotEmpty ? imageUrls : [imageUrl];

  bool get hasVariantStockData =>
      sizeStock.isNotEmpty || colorStock.isNotEmpty;

  bool get hasAnyVariantOptionInStock =>
      sizes.any(isSizeInStock) || colors.any(isColorInStock);

  bool get hasAvailableVariants {
    if (sizes.isEmpty && colors.isEmpty) return inStock;
    return hasAnyVariantOptionInStock;
  }

  bool get needsVariantSelection =>
      hasVariants || sizes.isNotEmpty || colors.isNotEmpty;

  /// In stock on cards/lists when any variation has stock (same as website).
  bool get isPurchasable {
    if (!needsVariantSelection) return inStock;
    if (sizes.isNotEmpty || colors.isNotEmpty) {
      return hasAnyVariantOptionInStock;
    }
    return inStock;
  }

  bool isSizeInStock(String size) {
    if (sizeStock.containsKey(size)) return sizeStock[size]!;
    return inStock;
  }

  bool isColorInStock(String color) {
    if (colorStock.containsKey(color)) return colorStock[color]!;
    return inStock;
  }

  String get defaultSize {
    for (final size in sizes) {
      if (isSizeInStock(size)) return size;
    }
    return 'Standard';
  }

  String get formattedSalePrice => '৳${salePrice.toStringAsFixed(0)}';
  String get formattedOriginalPrice => '৳${originalPrice.toStringAsFixed(0)}';

  factory Product.fromJson(Map<String, dynamic> json) {
    final sale = readDouble(
      json['sale_price'] ?? json['price'] ?? json['salePrice'],
    );
    final original = readDouble(
      json['original_price'] ??
          json['mrp'] ??
          json['regular_price'] ??
          json['originalPrice'],
      sale,
    );
    final discount = readInt(
      json['discount_percent'] ??
          json['discount'] ??
          json['discountPercent'],
      original > sale && original > 0
          ? (((original - sale) / original) * 100).round()
          : 0,
    );

    final images = asJsonList(json['images'] ?? json['image_urls'])
        .map((e) => readString(e))
        .where((e) => e.isNotEmpty)
        .toList();

    final imageUrl = readString(
      json['image'] ??
          json['image_url'] ??
          json['thumbnail'] ??
          (images.isNotEmpty ? images.first : ''),
    );

    final productInStock = _parseInStock(
      json['in_stock'] ??
          json['inStock'] ??
          json['stock_status'] ??
          json['stock'],
      fallbackQty: readInt(json['stock'], 1),
    );

    final hasVariants = readBool(
      json['has_variants'] ?? json['hasVariants'],
      false,
    );

    final sizeData = _parseOptionsWithStock(
      json,
      rawKey: 'sizes',
      altKeys: const ['size_options', 'sizeOptions'],
      variantField: 'size',
      productInStock: productInStock,
      hasVariants: hasVariants,
    );
    final colorData = _parseOptionsWithStock(
      json,
      rawKey: 'colors',
      altKeys: const ['color_options', 'colorOptions'],
      variantField: 'color',
      productInStock: productInStock,
      hasVariants: hasVariants,
    );

    final variantInStock = sizeData.stock.values.any((v) => v) ||
        colorData.stock.values.any((v) => v);
    final effectiveInStock = hasVariants && (sizeData.names.isNotEmpty || colorData.names.isNotEmpty)
        ? (productInStock || variantInStock)
        : productInStock;

    return Product(
      id: readString(json['id'] ?? json['product_id']),
      name: readString(json['name'] ?? json['title']),
      category: readString(
        json['category_name'] ??
            (json['category'] is Map
                ? json['category']['name']
                : json['category']),
      ),
      originalPrice: original > 0 ? original : sale,
      salePrice: sale,
      discountPercent: discount,
      imageUrl: imageUrl,
      inStock: effectiveInStock,
      description: readString(
        json['description'] ?? json['short_description'] ?? json['details'],
        'Premium quality kids wear made with soft, breathable fabric.',
      ),
      sizes: sizeData.names,
      colors: colorData.names,
      sizeStock: sizeData.stock,
      colorStock: colorData.stock,
      imageUrls: images,
      slug: readString(json['slug']),
      productUrl: readString(json['product_url'] ?? json['productUrl']),
      sku: readString(json['sku']),
      hasVariants: hasVariants,
      dealEndDate: readNullableString(
        json['flash_end_date'] ?? json['end_date'] ?? json['date'],
      ),
    );
  }

  static bool _parseInStock(dynamic stock, {required int fallbackQty}) {
    if (stock == null) return fallbackQty > 0;
    if (stock is String) {
      final value = stock.toLowerCase();
      if (value.contains('out')) return false;
      if (value == 'in_stock' || value == 'available') return true;
    }
    if (stock is num) return stock > 0;
    return readBool(stock, fallbackQty > 0);
  }

  static bool _parseOptionInStock(
    Map<String, dynamic> map, {
    required bool productInStock,
    required bool hasVariants,
  }) {
    final stock = map['in_stock'] ??
        map['inStock'] ??
        map['stock_status'] ??
        map['stock'] ??
        map['quantity'] ??
        map['qty'] ??
        map['available_quantity'];

    if (stock != null) {
      if (stock is String && stock.toLowerCase() == 'unlimited') return true;
      return _parseInStock(stock, fallbackQty: productInStock ? 1 : 0);
    }

    final available = map['available'] ?? map['is_available'];
    if (available != null) return readBool(available, productInStock);

    return hasVariants || productInStock;
  }

  static _OptionStockData _parseOptionsWithStock(
    Map<String, dynamic> json, {
    required String rawKey,
    required List<String> altKeys,
    required String variantField,
    required bool productInStock,
    required bool hasVariants,
  }) {
    final stockMap = <String, bool>{};

    void addOption(String name, bool optionInStock) {
      if (name.isEmpty) return;
      stockMap[name] = (stockMap[name] ?? false) || optionInStock;
    }

    dynamic raw = json[rawKey];
    for (final key in altKeys) {
      if (raw == null) raw = json[key];
    }

    for (final entry in asJsonList(raw)) {
      if (entry is Map) {
        final map = asJsonMap(entry);
        final name = readString(
          map['name'] ??
              map['label'] ??
              map['value'] ??
              map[variantField] ??
              map['title'],
        );
        addOption(name, _parseOptionInStock(map, productInStock: productInStock, hasVariants: hasVariants));
      } else {
        addOption(
          readString(entry),
          hasVariants ? true : productInStock,
        );
      }
    }

    for (final entry in asJsonList(json['variants'])) {
      final map = asJsonMap(entry);
      final name = readString(
        map[variantField] ??
            map['name'] ??
            map['label'] ??
            map['value'] ??
            map['title'],
      );
      addOption(name, _parseOptionInStock(map, productInStock: productInStock, hasVariants: hasVariants));
    }

    for (final entry in asJsonList(json['attributes'])) {
      final attr = asJsonMap(entry);
      final kind = readString(attr['name']).toLowerCase();
      final isColor = kind.contains('color') || kind.contains('colour');
      final isSize = kind.contains('size') || !isColor;
      if ((isColor && variantField != 'color') ||
          (isSize && variantField != 'size')) {
        continue;
      }
      for (final opt in asJsonList(attr['options'])) {
        if (opt is Map) {
          final map = asJsonMap(opt);
          final name = readString(
            map['name'] ?? map['label'] ?? map['value'] ?? map['title'],
          );
          addOption(
            name,
            _parseOptionInStock(map, productInStock: productInStock, hasVariants: hasVariants),
          );
        }
      }
    }

    return _OptionStockData(
      names: stockMap.keys.toList(),
      stock: stockMap,
    );
  }
}

class _OptionStockData {
  const _OptionStockData({required this.names, required this.stock});

  final List<String> names;
  final Map<String, bool> stock;
}
