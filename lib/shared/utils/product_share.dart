import 'package:my_first_app/data/models/product.dart';
import 'package:share_plus/share_plus.dart';

String productShareUrl(Product product) {
  if (product.productUrl.isNotEmpty) return product.productUrl;
  if (product.slug.isNotEmpty) {
    return 'https://wowkidzbd.com/product/${product.slug}';
  }
  return 'https://wowkidzbd.com/product/${product.id}';
}

Future<void> shareProduct(Product product) {
  final url = productShareUrl(product);
  final text =
      'Check out ${product.name} on WowKidz!\n$url\n${product.formattedSalePrice}';
  return SharePlus.instance.share(
    ShareParams(text: text, subject: product.name),
  );
}
