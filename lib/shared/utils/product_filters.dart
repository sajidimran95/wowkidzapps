import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/shared/utils/product_sort.dart';

enum ProductSort { popular, priceLow, priceHigh, discount }

class ProductFilterCriteria {
  const ProductFilterCriteria({
    this.category,
    this.size,
    this.color,
    this.sort = ProductSort.popular,
  });

  final String? category;
  final String? size;
  final String? color;
  final ProductSort sort;

  bool get hasActiveFilters =>
      (category != null && category!.isNotEmpty) ||
      (size != null && size!.isNotEmpty) ||
      (color != null && color!.isNotEmpty) ||
      sort != ProductSort.popular;

  ProductFilterCriteria copyWith({
    String? category,
    String? size,
    String? color,
    ProductSort? sort,
    bool clearCategory = false,
    bool clearSize = false,
    bool clearColor = false,
  }) {
    return ProductFilterCriteria(
      category: clearCategory ? null : (category ?? this.category),
      size: clearSize ? null : (size ?? this.size),
      color: clearColor ? null : (color ?? this.color),
      sort: sort ?? this.sort,
    );
  }

  static String sortLabel(ProductSort sort) => switch (sort) {
        ProductSort.popular => 'Popular',
        ProductSort.priceLow => 'Price: Low',
        ProductSort.priceHigh => 'Price: High',
        ProductSort.discount => 'Discount',
      };

  static ProductSort sortFromLabel(String label) => switch (label) {
        'Price: Low' => ProductSort.priceLow,
        'Price: High' => ProductSort.priceHigh,
        'Discount' => ProductSort.discount,
        _ => ProductSort.popular,
      };
}

List<Product> applyProductFilters(
  List<Product> products,
  ProductFilterCriteria criteria,
) {
  var result = List<Product>.of(products);

  final category = criteria.category?.trim();
  if (category != null && category.isNotEmpty) {
    result = result
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  final size = criteria.size?.trim();
  if (size != null && size.isNotEmpty) {
    result = result
        .where(
          (p) => p.sizes.any((s) => s.toLowerCase() == size.toLowerCase()),
        )
        .toList();
  }

  final color = criteria.color?.trim();
  if (color != null && color.isNotEmpty) {
    result = result
        .where(
          (p) => p.colors.any((c) => c.toLowerCase() == color.toLowerCase()),
        )
        .toList();
  }

  switch (criteria.sort) {
    case ProductSort.priceLow:
      result.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    case ProductSort.priceHigh:
      result.sort((a, b) => b.salePrice.compareTo(a.salePrice));
    case ProductSort.discount:
      result.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    case ProductSort.popular:
      break;
  }

  return sortProductsStockFirst(result);
}

List<String> collectProductCategories(List<Product> products) {
  final values = <String>{};
  for (final product in products) {
    if (product.category.trim().isNotEmpty) {
      values.add(product.category.trim());
    }
  }
  final list = values.toList()..sort();
  return list;
}

List<String> collectProductSizes(List<Product> products) {
  final values = <String>{};
  for (final product in products) {
    values.addAll(product.sizes);
  }
  final list = values.toList()..sort(_compareSizeLabels);
  return list;
}

int _compareSizeLabels(String a, String b) {
  final aNum = _sizeSortValue(a);
  final bNum = _sizeSortValue(b);
  if (aNum != bNum) return aNum.compareTo(bNum);
  return a.toLowerCase().compareTo(b.toLowerCase());
}

int _sizeSortValue(String size) {
  final match = RegExp(r'(\d+)').firstMatch(size);
  if (match != null) return int.tryParse(match.group(1)!) ?? 999;
  return switch (size.toUpperCase()) {
    'XS' => 100,
    'S' => 101,
    'M' => 102,
    'L' => 103,
    'XL' => 104,
    'XXL' => 105,
    _ => 999,
  };
}

List<String> collectProductColors(List<Product> products) {
  final values = <String>{};
  for (final product in products) {
    values.addAll(product.colors);
  }
  final list = values.toList()..sort();
  return list;
}
