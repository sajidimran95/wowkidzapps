import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/data/mock/mock_data.dart';

/// Pre-fills static demo data so every screen can be reviewed without manual steps.
abstract final class DemoSeed {
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    final controller = AppController.instance;
    if (controller.items.isNotEmpty) return;

    final samples = [
      MockData.productById('1'),
      MockData.productById('9'),
      MockData.productById('15'),
    ];

    for (final product in samples) {
      if (product == null || !product.inStock) continue;
      controller.addToCart(product, size: product.sizes[1], quantity: 1);
    }
  }

  static void resetDemoCart() {
    final controller = AppController.instance;
    controller.clearCart();
    _initialized = false;
    initialize();
  }
}
