import 'package:my_first_app/data/models/product.dart';

/// In-stock products first, out-of-stock last (stable order within each group).
List<Product> sortProductsStockFirst(List<Product> products) {
  final indexed = products.asMap().entries.toList();
  indexed.sort((a, b) {
    final aRank = a.value.isPurchasable ? 0 : 1;
    final bRank = b.value.isPurchasable ? 0 : 1;
    if (aRank != bRank) return aRank.compareTo(bRank);
    return a.key.compareTo(b.key);
  });
  return indexed.map((e) => e.value).toList();
}
