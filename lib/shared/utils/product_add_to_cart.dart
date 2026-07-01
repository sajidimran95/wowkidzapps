import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/product/widgets/add_to_cart_sheet.dart';
import 'package:my_first_app/shared/utils/cart_auth.dart';
import 'package:my_first_app/shared/utils/cart_snackbar.dart';

Future<void> handleProductAddToCart(
  BuildContext context,
  Product product,
) async {
  if (!product.isPurchasable) return;
  if (!await ensureCartAccess(context)) return;
  if (!context.mounted) return;

  if (product.needsVariantSelection) {
    await promptAddToCart(context, product);
    return;
  }

  AppController.instance.addToCart(
    product,
    size: product.defaultSize,
  );
  showAddedToCartSnackBar(context, product.name);
}
