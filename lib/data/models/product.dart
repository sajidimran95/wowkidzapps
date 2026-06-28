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
    this.sizes = const ['2-3Y', '4-5Y', '6-7Y', '8-9Y', '10-11Y'],
    this.imageUrls = const [],
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
  final List<String> imageUrls;

  List<String> get allImages =>
      imageUrls.isNotEmpty ? imageUrls : [imageUrl];

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
          images.firstOrNull,
    );

    final stock = json['in_stock'] ??
        json['inStock'] ??
        json['stock_status'] ??
        json['stock'];

    final sizes = asJsonList(json['sizes'])
        .map((e) => readString(e))
        .where((e) => e.isNotEmpty)
        .toList();

    return Product(
      id: readString(json['id'] ?? json['product_id']),
      name: readString(json['name'] ?? json['title']),
      category: readString(
        json['category_name'] ??
            json['category'] ??
            (json['category'] is Map ? json['category']['name'] : null),
      ),
      originalPrice: original > 0 ? original : sale,
      salePrice: sale,
      discountPercent: discount,
      imageUrl: imageUrl,
      inStock: stock == null
          ? true
          : stock == 'in_stock' ||
              stock == 'available' ||
              readBool(stock, readInt(json['stock'], 1) > 0),
      description: readString(
        json['description'] ?? json['short_description'],
        'Premium quality kids wear made with soft, breathable fabric.',
      ),
      sizes: sizes.isEmpty
          ? const ['2-3Y', '4-5Y', '6-7Y', '8-9Y', '10-11Y']
          : sizes,
      imageUrls: images,
    );
  }
}
