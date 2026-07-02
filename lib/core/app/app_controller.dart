import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/auth_result.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/network/api_exception.dart';
import 'package:my_first_app/core/network/json_utils.dart';
import 'package:my_first_app/core/network/token_storage.dart';
import 'package:my_first_app/data/api/wowkidz_api.dart';
import 'package:my_first_app/data/models/cart_item.dart';
import 'package:my_first_app/data/models/customer_order.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/data/models/saved_address.dart';
import 'package:my_first_app/data/models/shipping_settings.dart';
import 'package:my_first_app/data/models/support_ticket.dart';

class AppController extends ChangeNotifier {
  AppController._();
  static final AppController instance = AppController._();

  final navigatorKey = GlobalKey<NavigatorState>();
  final _api = WowKidzApi.instance;
  final _catalog = CatalogStore.instance;

  int selectedTab = 0;
  final List<CartItem> _items = [];
  final List<SavedAddress> _addresses = [];
  final List<SupportTicket> _supportTickets = [];
  final List<String> _wishlistProductIds = [];
  final List<CustomerOrder> _orders = [];

  bool isAuthLoading = false;
  bool isCustomerDataLoading = false;
  String? authError;

  List<SavedAddress> get addresses => List.unmodifiable(_addresses);
  List<SupportTicket> get supportTickets => List.unmodifiable(_supportTickets);
  List<CustomerOrder> get orders => List.unmodifiable(_orders);

  List<Product> get wishlistProducts {
    return _wishlistProductIds
        .map((id) => _catalog.productById(id))
        .whereType<Product>()
        .toList();
  }

  int get wishlistCount => _wishlistProductIds.length;

  List<CartItem> get items => List.unmodifiable(_items);

  int get cartCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.lineTotal);

  ShippingSettings get shippingSettings => _catalog.shippingSettings;

  String? _selectedShippingId;
  String? get selectedShippingId => _selectedShippingId;

  bool get qualifiesForFreeShipping =>
      shippingSettings.freeShippingEnabled &&
      _items.isNotEmpty &&
      subtotal >= shippingSettings.freeShippingMinimum;

  double get freeShippingRemaining =>
      qualifiesForFreeShipping
          ? 0
          : (shippingSettings.freeShippingMinimum - subtotal)
              .clamp(0, double.infinity);

  double get shipping {
    if (_items.isEmpty) return 0;
    if (qualifiesForFreeShipping) return 0;
    final option = shippingSettings.optionById(_selectedShippingId) ??
        shippingSettings.defaultOption;
    return option?.price ?? 0;
  }

  /// Cart total excludes shipping until checkout delivery option is selected.
  double get cartTotal => subtotal - discount;

  void setShippingOption(String? id) {
    if (_selectedShippingId == id) return;
    _selectedShippingId = id;
    notifyListeners();
  }

  void ensureDefaultShippingOption() {
    if (_selectedShippingId != null &&
        shippingSettings.optionById(_selectedShippingId) != null) {
      return;
    }
    _selectedShippingId = shippingSettings.defaultOption?.id;
  }

  double get discount => _promoApplied ? subtotal * 0.05 : 0;

  double get total => subtotal + shipping - discount;

  bool _promoApplied = false;
  bool get promoApplied => _promoApplied;
  String? _appliedPromoCode;

  bool isLoggedIn = false;
  String? userName;
  String? userPhone;
  String? userEmail;
  String? userRole;
  String? userPassword;
  String? userProfileImageUrl;

  String? get userContact => userPhone ?? userEmail;

  Future<AuthResult> login({
    required String contact,
    required String password,
  }) async {
    isAuthLoading = true;
    authError = null;
    notifyListeners();

    try {
      final data = await _api.login(contact: contact, password: password);
      await _applyAuthResponse(data, password: password);
      await loadCustomerData();
      return const AuthResult.success();
    } on ApiException catch (e) {
      if (e.statusCode == 403 && e.details is Map) {
        final details = asJsonMap(e.details);
        if (readBool(details['requires_verification'], false)) {
          return AuthResult.needsVerification(contact);
        }
      }
      authError = e.message;
      return AuthResult.error(e.message);
    } catch (e) {
      authError = e.toString();
      return AuthResult.error(authError!);
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> signup({
    required String name,
    String? phone,
    String? email,
    required String role,
    required String password,
  }) async {
    isAuthLoading = true;
    authError = null;
    notifyListeners();

    try {
      final data = await _api.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        role: role,
      );
      final contact = email ?? phone;
      if (readBool(data['requires_verification'], false) && contact != null) {
        return AuthResult.needsVerification(contact);
      }
      await _applyAuthResponse(data, password: password);
      await loadCustomerData();
      return const AuthResult.success();
    } on ApiException catch (e) {
      authError = e.message;
      return AuthResult.error(e.message);
    } catch (e) {
      authError = e.toString();
      return AuthResult.error(authError!);
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<String?> verifyEmail({
    required String contact,
    required String code,
    String? password,
  }) async {
    isAuthLoading = true;
    authError = null;
    notifyListeners();

    try {
      final data = await _api.verifyEmail(contact: contact, code: code);
      await _applyAuthResponse(data, password: password);
      await loadCustomerData();
      return null;
    } on ApiException catch (e) {
      authError = e.message;
      return e.message;
    } catch (e) {
      authError = e.toString();
      return authError;
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<String?> resendVerification({required String contact}) async {
    try {
      await _api.resendVerification(contact: contact);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> requestPasswordReset({required String contact}) async {
    isAuthLoading = true;
    notifyListeners();
    try {
      await _api.forgotPassword(contact: contact);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<String?> resetPassword({
    required String contact,
    required String code,
    required String password,
  }) async {
    isAuthLoading = true;
    notifyListeners();
    try {
      await _api.resetPassword(
        contact: contact,
        code: code,
        password: password,
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applyAuthResponse(
    Map<String, dynamic> data, {
    String? password,
  }) async {
    final token = readNullableString(data['token'] ?? data['access_token']);
    if (token != null) {
      await TokenStorage.instance.writeToken(token);
    }

    final user = asJsonMap(data['user'] ?? data);
    isLoggedIn = true;
    userName = readNullableString(user['name']) ?? userName;
    userPhone = readNullableString(user['phone']) ?? userPhone;
    userEmail = readNullableString(user['email']) ?? userEmail;
    userRole = readNullableString(user['role']) ?? userRole ?? 'Customer';
    userProfileImageUrl = readNullableString(
      user['profile_image'] ?? user['avatar'] ?? user['image'],
    );
    if (password != null) {
      userPassword = password;
    }
    notifyListeners();
  }

  Future<void> loadCustomerData() async {
    if (!isLoggedIn) return;

    isCustomerDataLoading = true;
    notifyListeners();

    try {
      final profile = await _api.getProfile();
      final user = asJsonMap(profile['user'] ?? profile);
      userName = readNullableString(user['name']) ?? userName;
      userPhone = readNullableString(user['phone']) ?? userPhone;
      userEmail = readNullableString(user['email']) ?? userEmail;
      userRole = readNullableString(user['role']) ?? userRole;
      userProfileImageUrl = readNullableString(
        user['profile_image'] ?? user['avatar'],
      );
    } catch (_) {}

    try {
      _addresses
        ..clear()
        ..addAll(await _api.getAddresses());
    } catch (_) {}

    try {
      _supportTickets
        ..clear()
        ..addAll(await _api.getSupportTickets());
    } catch (_) {}

    try {
      _wishlistProductIds
        ..clear()
        ..addAll(await _api.getWishlistProductIds());
    } catch (_) {}

    try {
      _orders
        ..clear()
        ..addAll(await _api.getOrders());
    } catch (_) {}

    isCustomerDataLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    await TokenStorage.instance.clearToken();
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
    _orders.clear();
    notifyListeners();
  }

  Future<String?> updateProfile({
    required String name,
    String? phone,
    String? email,
    String? profileImageUrl,
  }) async {
    try {
      final data = await _api.updateProfile(
        name: name,
        phone: phone,
        email: email,
        profileImageUrl: profileImageUrl,
      );
      final user = asJsonMap(data['user'] ?? data);
      userName = readString(user['name'], name);
      userPhone = readNullableString(user['phone']) ?? phone;
      userEmail = readNullableString(user['email']) ?? email;
      if (profileImageUrl != null) {
        userProfileImageUrl =
            profileImageUrl.trim().isEmpty ? null : profileImageUrl.trim();
      }
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      userName = name;
      userPhone = phone;
      userEmail = email;
      if (profileImageUrl != null) {
        userProfileImageUrl =
            profileImageUrl.trim().isEmpty ? null : profileImageUrl.trim();
      }
      notifyListeners();
      return e.message;
    }
  }

  void updateProfileImage(String? url) {
    userProfileImageUrl =
        (url == null || url.trim().isEmpty) ? null : url.trim();
    notifyListeners();
  }

  OrderPaymentStatus paymentStatusFor(CustomerOrder order) {
    final fresh = _orders.where((o) => o.id == order.id).firstOrNull;
    return fresh?.paymentStatus ?? order.paymentStatus;
  }

  CustomerOrder? orderById(String id) =>
      _orders.where((o) => o.id == id).firstOrNull;

  Future<String?> markOrderPaid(String orderId) async {
    try {
      await _api.markOrderPaid(orderId);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          paymentStatus: OrderPaymentStatus.paid,
        );
      }
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          paymentStatus: OrderPaymentStatus.paid,
        );
        notifyListeners();
      }
      return e.message;
    }
  }

  Future<String?> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      userPassword = newPassword;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      if (userPassword == null || userPassword != currentPassword) {
        return 'Current password is incorrect';
      }
      userPassword = newPassword;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> addAddress(SavedAddress address) async {
    try {
      final saved = await _api.createAddress(address);
      if (saved.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
      _addresses.add(saved);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      addAddressLocal(address);
      return e.message;
    }
  }

  void addAddressLocal(SavedAddress address) {
    if (address.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(address);
    notifyListeners();
  }

  Future<String?> updateAddress(SavedAddress address) async {
    try {
      final saved = await _api.updateAddress(address);
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index == -1) return null;

      if (saved.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
      _addresses[index] = saved;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      updateAddressLocal(address);
      return e.message;
    }
  }

  void updateAddressLocal(SavedAddress address) {
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

  Future<String?> deleteAddress(String id) async {
    try {
      await _api.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      if (_addresses.isNotEmpty && !_addresses.any((a) => a.isDefault)) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      deleteAddressLocal(id);
      return e.message;
    }
  }

  void deleteAddressLocal(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_addresses.isNotEmpty && !_addresses.any((a) => a.isDefault)) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    notifyListeners();
  }

  Future<void> setDefaultAddress(String id) async {
    final address = _addresses.where((a) => a.id == id).firstOrNull;
    if (address == null) return;
    await updateAddress(address.copyWith(isDefault: true));
  }

  String nextAddressId() => 'addr_${DateTime.now().millisecondsSinceEpoch}';

  Future<String?> addSupportTicket({
    required String subject,
    required String message,
    String? attachmentName,
  }) async {
    try {
      final ticket = await _api.createSupportTicket(
        subject: subject,
        message: message,
        attachmentName: attachmentName,
      );
      _supportTickets.insert(0, ticket);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _supportTickets.insert(
        0,
        SupportTicket(
          id: 'TKT-${DateTime.now().millisecondsSinceEpoch}',
          subject: subject,
          message: message,
          createdAt: utcNow(),
          attachmentName: attachmentName,
        ),
      );
      notifyListeners();
      return e.message;
    }
  }

  Future<void> toggleWishlist(String productId) async {
    if (_wishlistProductIds.contains(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }

  Future<void> addToWishlist(String productId) async {
    if (_wishlistProductIds.contains(productId)) return;
    try {
      await _api.addToWishlist(productId);
    } catch (_) {}
    _wishlistProductIds.add(productId);
    notifyListeners();
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      await _api.removeFromWishlist(productId);
    } catch (_) {}
    _wishlistProductIds.remove(productId);
    notifyListeners();
  }

  bool isInWishlist(String productId) =>
      _wishlistProductIds.contains(productId);

  List<CustomerOrder> ordersForFilter({
    bool runningOnly = false,
    OrderStatus? status,
  }) {
    if (runningOnly) {
      return _orders.where((o) => o.status.isRunning).toList();
    }
    if (status == null) return List.from(_orders);
    return _orders.where((o) => o.status == status).toList();
  }

  Future<CustomerOrder?> placeOrder({
    required String name,
    required String phone,
    required String address,
    required String city,
    required String paymentMethod,
  }) async {
    final items = _items
        .map(
          (item) => {
            'product_id': item.product.id,
            'size': item.size,
            'quantity': item.quantity,
            'price': item.product.salePrice,
          },
        )
        .toList();

    try {
      final placed = await _api.placeOrder(
        items: items,
        name: name,
        phone: phone,
        address: address,
        city: city,
        paymentMethod: paymentMethod,
        promoCode: _appliedPromoCode,
        shippingId: _selectedShippingId,
        shippingCharge: shipping,
      );
      final order = placed.copyWith(
        paymentStatus: CustomerOrder.resolvePaymentStatus(
          paymentMethod: paymentMethod,
          paymentStatus: placed.paymentStatus,
        ),
      );
      _orders.insert(0, order);
      notifyListeners();
      return order;
    } on ApiException {
      final order = CustomerOrder(
        id: 'WK${DateTime.now().millisecondsSinceEpoch.remainder(100000).toString().padLeft(5, '0')}',
        dateLabel: formatOrderStatusDateTime(bangladeshNow()),
        total: total,
        status: OrderStatus.confirmed,
        itemCount: cartCount,
        itemsSummary: _items.map((i) => i.product.name).join(', '),
        statusHistory: [
          OrderStatusEvent(status: OrderStatus.confirmed, at: bangladeshNow()),
        ],
        address: '$address, $city',
        paymentMethod: paymentMethod,
        paymentStatus: CustomerOrder.resolvePaymentStatus(
          paymentMethod: paymentMethod,
          paymentStatus: OrderPaymentStatus.paid,
        ),
      );
      _orders.insert(0, order);
      notifyListeners();
      return order;
    }
  }

  void selectTab(int index) {
    if (selectedTab == index) return;
    selectedTab = index;
    notifyListeners();
  }

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
    goToTab(3, context);
  }

  void goToCategory([BuildContext? context]) => goToTab(2, context);

  void goToSearch([BuildContext? context]) => goToTab(1, context);

  void goToHome([BuildContext? context]) => goToTab(0, context);

  void goToShop([BuildContext? context]) => goToHome(context);

  void _popToRoot(BuildContext? context) {
    if (context != null && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  void addToCart(Product product, {required String size, int quantity = 1}) {
    if (!product.isPurchasable) return;

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

  Future<bool> applyPromo(String code) async {
    try {
      final valid = await _api.applyPromoCode(code);
      if (valid || code.trim().toUpperCase() == 'WOWKIDZ') {
        _promoApplied = true;
        _appliedPromoCode = code.trim();
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      if (code.trim().toUpperCase() == 'WOWKIDZ') {
        _promoApplied = true;
        _appliedPromoCode = code.trim();
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  void clearCart() {
    _items.clear();
    _promoApplied = false;
    _appliedPromoCode = null;
    notifyListeners();
  }

  String formatPrice(double amount) => '৳${amount.toStringAsFixed(0)}';

  Future<void> restoreSession() async {
    final token = await TokenStorage.instance.readToken();
    if (token == null || token.isEmpty) return;
    isLoggedIn = true;
    await loadCustomerData();
  }
}
