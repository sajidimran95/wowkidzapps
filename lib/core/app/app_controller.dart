import 'package:flutter/material.dart';
import 'package:my_first_app/data/mock/customer_profile_mock.dart';
import 'package:my_first_app/data/mock/customer_orders_mock.dart';
import 'package:my_first_app/data/mock/mock_data.dart';
import 'package:my_first_app/data/models/cart_item.dart';
import 'package:my_first_app/data/models/customer_order.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/data/models/saved_address.dart';
import 'package:my_first_app/data/models/support_ticket.dart';

class AppController extends ChangeNotifier {
  AppController._();
  static final AppController instance = AppController._();

  final navigatorKey = GlobalKey<NavigatorState>();

  int selectedTab = 0;
  final List<CartItem> _items = [];
  final List<SavedAddress> _addresses = [];
  final List<SupportTicket> _supportTickets = [];
  final List<String> _wishlistProductIds = [];
  int _addressIdCounter = 100;
  int _ticketIdCounter = 2000;

  List<SavedAddress> get addresses => List.unmodifiable(_addresses);
  List<SupportTicket> get supportTickets => List.unmodifiable(_supportTickets);

  List<Product> get wishlistProducts {
    return _wishlistProductIds
        .map(
          (id) => MockData.allProducts.where((p) => p.id == id).firstOrNull,
        )
        .whereType<Product>()
        .toList();
  }

  int get wishlistCount => _wishlistProductIds.length;

  List<CartItem> get items => List.unmodifiable(_items);

  int get cartCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.lineTotal);

  double get shipping => _items.isEmpty ? 0 : (subtotal >= 2000 ? 0 : 120);

  double get discount => _promoApplied ? subtotal * 0.05 : 0;

  double get total => subtotal + shipping - discount;

  bool _promoApplied = false;
  bool get promoApplied => _promoApplied;

  bool isLoggedIn = false;
  String? userName;
  String? userPhone;
  String? userEmail;
  String? userRole;
  String? userPassword;
  String? userProfileImageUrl;

  String? get userContact => userPhone ?? userEmail;

  void login({
    required String name,
    String? phone,
    String? email,
    String? role,
    String? password,
  }) {
    isLoggedIn = true;
    userName = name;
    userPhone = phone;
    userEmail = email;
    userRole = role ?? 'Customer';
    if (password != null) {
      userPassword = password;
    }
    _seedCustomerData();
    notifyListeners();
  }

  void signup({
    required String name,
    String? phone,
    String? email,
    required String role,
    String? password,
  }) {
    login(
      name: name,
      phone: phone,
      email: email,
      role: role,
      password: password,
    );
  }

  void logout() {
    isLoggedIn = false;
    userName = null;
    userPhone = null;
    userEmail = null;
    userRole = null;
    userPassword = null;
    userProfileImageUrl = null;
    _addresses.clear();
    _supportTickets.clear();
    _wishlistProductIds.clear();
    notifyListeners();
  }

  void _seedCustomerData() {
    if (_addresses.isEmpty) {
      _addresses.addAll(CustomerProfileMock.addresses);
    }
    if (_supportTickets.isEmpty) {
      _supportTickets.addAll(CustomerProfileMock.tickets);
    }
    if (_wishlistProductIds.isEmpty) {
      _wishlistProductIds.addAll(CustomerProfileMock.defaultWishlistIds);
    }
  }

  void updateProfile({
    required String name,
    String? phone,
    String? email,
    String? profileImageUrl,
  }) {
    userName = name;
    userPhone = phone;
    userEmail = email;
    if (profileImageUrl != null) {
      userProfileImageUrl =
          profileImageUrl.trim().isEmpty ? null : profileImageUrl.trim();
    }
    notifyListeners();
  }

  void updateProfileImage(String? url) {
    userProfileImageUrl =
        (url == null || url.trim().isEmpty) ? null : url.trim();
    notifyListeners();
  }

  OrderPaymentStatus paymentStatusFor(CustomerOrder order) {
    final fresh = CustomerOrdersMock.findById(order.id);
    return fresh?.paymentStatus ?? order.paymentStatus;
  }

  void markOrderPaid(String orderId) {
    final order = CustomerOrdersMock.findById(orderId);
    if (order == null || order.paymentStatus == OrderPaymentStatus.paid) {
      return;
    }
    CustomerOrdersMock.updateOrder(
      order.copyWith(paymentStatus: OrderPaymentStatus.paid),
    );
    notifyListeners();
  }

  /// Returns null on success, or an error message.
  String? updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    if (userPassword == null || userPassword != currentPassword) {
      return 'Current password is incorrect';
    }
    if (newPassword.length < 6) {
      return 'New password must be at least 6 characters';
    }
    userPassword = newPassword;
    notifyListeners();
    return null;
  }

  void addAddress(SavedAddress address) {
    if (address.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(address);
    notifyListeners();
  }

  void updateAddress(SavedAddress address) {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index == -1) return;

    if (address.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses[index] = address;
    notifyListeners();
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_addresses.isNotEmpty && !_addresses.any((a) => a.isDefault)) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    notifyListeners();
  }

  void setDefaultAddress(String id) {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }
    notifyListeners();
  }

  String nextAddressId() => 'addr_${_addressIdCounter++}';

  void addSupportTicket({
    required String subject,
    required String message,
    String? attachmentName,
  }) {
    _supportTickets.insert(
      0,
      SupportTicket(
        id: 'TKT-${_ticketIdCounter++}',
        subject: subject,
        message: message,
        createdAt: DateTime.now(),
        attachmentName: attachmentName,
      ),
    );
    notifyListeners();
  }

  void removeFromWishlist(String productId) {
    _wishlistProductIds.remove(productId);
    notifyListeners();
  }

  bool isInWishlist(String productId) =>
      _wishlistProductIds.contains(productId);

  void selectTab(int index) {
    if (selectedTab == index) return;
    selectedTab = index;
    notifyListeners();
  }

  /// Pops all pushed routes and switches bottom tab.
  void goToTab(int index, [BuildContext? context]) {
    _popToRoot(context);
    selectedTab = index;
    notifyListeners();
  }

  void goToCart([BuildContext? context]) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    final root = navigatorKey.currentContext;
    if (root != null && root.mounted) {
      ScaffoldMessenger.of(root).hideCurrentSnackBar();
    }
    goToTab(2, context);
  }

  void goToCategory([BuildContext? context]) => goToTab(1, context);

  void goToHome([BuildContext? context]) => goToTab(0, context);

  /// Leaves customer dashboard and opens the storefront home tab.
  void goToShop([BuildContext? context]) => goToHome(context);

  void _popToRoot(BuildContext? context) {
    if (context != null && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  void addToCart(Product product, {required String size, int quantity = 1}) {
    if (!product.inStock) return;

    final existing = _items.where(
      (item) => item.product.id == product.id && item.size == size,
    );
    if (existing.isNotEmpty) {
      existing.first.quantity += quantity;
    } else {
      _items.add(CartItem(product: product, size: size, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      removeItem(item);
      return;
    }
    item.quantity = quantity;
    notifyListeners();
  }

  void updateSize(CartItem item, String newSize) {
    if (item.size == newSize) return;

    final duplicate = _items.where(
      (i) =>
          i != item &&
          i.product.id == item.product.id &&
          i.size == newSize,
    );

    if (duplicate.isNotEmpty) {
      duplicate.first.quantity += item.quantity;
      _items.remove(item);
    } else {
      item.size = newSize;
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  bool applyPromo(String code) {
    if (code.trim().toUpperCase() == 'WOWKIDZ') {
      _promoApplied = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearCart() {
    _items.clear();
    _promoApplied = false;
    notifyListeners();
  }

  String formatPrice(double amount) => '৳${amount.toStringAsFixed(0)}';
}
