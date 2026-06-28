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
}
