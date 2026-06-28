import 'package:my_first_app/data/models/product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.size,
    this.quantity = 1,
  });

  final Product product;
  String size;
  int quantity;

  String get key => '${product.id}_$size';

  double get lineTotal => product.salePrice * quantity;

  String get formattedLineTotal => '৳${lineTotal.toStringAsFixed(0)}';
}
