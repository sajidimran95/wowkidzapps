import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

void _hideCartSnackBars(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final rootContext = AppController.instance.navigatorKey.currentContext;
  if (rootContext != null && rootContext.mounted && rootContext != context) {
    ScaffoldMessenger.of(rootContext).hideCurrentSnackBar();
  }
}

void showAddedToCartSnackBar(BuildContext context, String productName) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$productName added to cart',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      persist: false,
      backgroundColor: AppColors.success,
      action: SnackBarAction(
        label: 'View Cart',
        textColor: Colors.white,
        onPressed: () {
          _hideCartSnackBars(context);
          AppController.instance.goToCart(context);
        },
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

void showCartMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        persist: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
}
