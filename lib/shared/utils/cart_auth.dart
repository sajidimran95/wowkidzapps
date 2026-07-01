import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/features/auth/pages/login_page.dart';

/// When guest checkout is disabled in admin, cart/checkout require login.
Future<bool> ensureCartAccess(BuildContext context) async {
  final catalog = CatalogStore.instance;
  final controller = AppController.instance;

  if (catalog.guestCheckoutEnabled || controller.isLoggedIn) {
    return true;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
  );

  if (!context.mounted) return false;

  if (controller.isLoggedIn) {
    await controller.loadCustomerData();
  }

  return controller.isLoggedIn;
}

Future<bool> ensureCheckoutAccess(BuildContext context) async {
  final allowed = await ensureCartAccess(context);
  if (!allowed || !context.mounted) return false;

  final controller = AppController.instance;
  if (controller.isLoggedIn && controller.addresses.isEmpty) {
    await controller.loadCustomerData();
  }

  return controller.isLoggedIn || CatalogStore.instance.guestCheckoutEnabled;
}
