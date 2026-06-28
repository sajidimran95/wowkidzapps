import 'package:my_first_app/core/config/api_config.dart';
import 'package:my_first_app/core/network/api_client.dart';
import 'package:my_first_app/core/network/json_utils.dart';
import 'package:my_first_app/data/models/customer_order.dart';
import 'package:my_first_app/data/models/payment_session.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/data/models/saved_address.dart';
import 'package:my_first_app/data/models/support_ticket.dart';

class WowKidzApi {
  WowKidzApi._();
  static final WowKidzApi instance = WowKidzApi._();

  final _client = ApiClient.instance;

  Future<Map<String, dynamic>> getMobileStatus() async {
    final json = await _client.get(ApiConfig.mobileStatus);
    return _client.asMap(json);
  }

  Future<bool> isMobileApiEnabled() async {
    try {
      final status = await getMobileStatus();
      return readBool(status['mobile_api_enabled'], false);
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getHome() async {
    final json = await _client.get(ApiConfig.home);
    return _client.asMap(json);
  }

  Future<Map<String, dynamic>> getSettings() async {
    final json = await _client.get(ApiConfig.settings);
    return _client.asMap(json);
  }

  Future<List<dynamic>> getCategories() async {
    final json = await _client.get(ApiConfig.categories);
    return _client.asList(json);
  }

  Future<List<dynamic>> getSliders() async {
    final json = await _client.get(ApiConfig.sliders);
    return _client.asList(json);
  }

  Future<List<dynamic>> getBanners({String? type}) async {
    final json = await _client.get(
      ApiConfig.banners,
      queryParameters: type == null ? null : {'type': type},
    );
    return _client.asList(json);
  }

  Future<List<dynamic>> getFeatures() async {
    final json = await _client.get(ApiConfig.features);
    return _client.asList(json);
  }

  Future<List<dynamic>> getProducts({
    String? categoryId,
    String? category,
    String? section,
    String? search,
    int? page,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      if (categoryId != null) 'category_id': categoryId,
      if (category != null) 'category': category,
      if (section != null) 'section': section,
      if (search != null && search.isNotEmpty) 'search': search,
      if (page != null) 'page': page,
      if (perPage != null) 'per_page': perPage,
    };
    final json = await _client.get(ApiConfig.products, queryParameters: query);
    return _client.asList(json);
  }

  Future<Product> getProduct(String id) async {
    final json = await _client.get('${ApiConfig.products}/$id');
    return Product.fromJson(_client.asMap(json));
  }

  Future<Map<String, dynamic>> login({
    required String contact,
    required String password,
  }) async {
    final json = await _client.post(
      ApiConfig.login,
      data: {
        'email_or_phone': contact,
        'password': password,
      },
    );
    return _client.asMap(json);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    String? phone,
    String? email,
    required String password,
    required String role,
  }) async {
    final json = await _client.post(
      ApiConfig.register,
      data: {
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role.toLowerCase(),
      },
    );
    return _client.asMap(json);
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConfig.logout);
    } catch (_) {
      // Ignore logout failures — token is cleared locally.
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final json = await _client.get(ApiConfig.profile);
    return _client.asMap(json);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? email,
    String? profileImageUrl,
  }) async {
    final json = await _client.put(
      ApiConfig.profile,
      data: {
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (profileImageUrl != null) 'profile_image': profileImageUrl,
      },
    );
    return _client.asMap(json);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.post(
      ApiConfig.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
    );
  }

  Future<List<CustomerOrder>> getOrders() async {
    final json = await _client.get(ApiConfig.orders);
    return _client
        .asList(json)
        .map((e) => CustomerOrder.fromJson(asJsonMap(e)))
        .toList();
  }

  Future<CustomerOrder> getOrder(String id) async {
    final json = await _client.get('${ApiConfig.orders}/$id');
    return CustomerOrder.fromJson(_client.asMap(json));
  }

  Future<CustomerOrder> placeOrder({
    required List<Map<String, dynamic>> items,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String paymentMethod,
    String? promoCode,
  }) async {
    final json = await _client.post(
      ApiConfig.orders,
      data: {
        'items': items,
        'shipping': {
          'name': name,
          'phone': phone,
          'address': address,
          'city': city,
        },
        'payment_method': paymentMethod,
        if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
      },
    );
    return CustomerOrder.fromJson(_client.asMap(json));
  }

  Future<void> markOrderPaid(String orderId) async {
    await _client.post('${ApiConfig.orders}/$orderId/pay');
  }

  Future<List<SavedAddress>> getAddresses() async {
    final json = await _client.get(ApiConfig.addresses);
    return _client
        .asList(json)
        .map((e) => SavedAddress.fromJson(asJsonMap(e)))
        .toList();
  }

  Future<SavedAddress> createAddress(SavedAddress address) async {
    final json = await _client.post(
      ApiConfig.addresses,
      data: address.toJson(),
    );
    return SavedAddress.fromJson(_client.asMap(json));
  }

  Future<SavedAddress> updateAddress(SavedAddress address) async {
    final json = await _client.put(
      '${ApiConfig.addresses}/${address.id}',
      data: address.toJson(),
    );
    return SavedAddress.fromJson(_client.asMap(json));
  }

  Future<void> deleteAddress(String id) async {
    await _client.delete('${ApiConfig.addresses}/$id');
  }

  Future<List<String>> getWishlistProductIds() async {
    final json = await _client.get(ApiConfig.wishlist);
    final list = _client.asList(json);
    return list.map((e) {
      if (e is Map) {
        return readString(e['product_id'] ?? e['id']);
      }
      return readString(e);
    }).where((id) => id.isNotEmpty).toList();
  }

  Future<void> addToWishlist(String productId) async {
    await _client.post(
      ApiConfig.wishlist,
      data: {'product_id': productId},
    );
  }

  Future<void> removeFromWishlist(String productId) async {
    await _client.delete('${ApiConfig.wishlist}/$productId');
  }

  Future<List<SupportTicket>> getSupportTickets() async {
    final json = await _client.get(ApiConfig.supportTickets);
    return _client
        .asList(json)
        .map((e) => SupportTicket.fromJson(asJsonMap(e)))
        .toList();
  }

  Future<SupportTicket> createSupportTicket({
    required String subject,
    required String message,
    String? attachmentName,
  }) async {
    final json = await _client.post(
      ApiConfig.supportTickets,
      data: {
        'subject': subject,
        'message': message,
        if (attachmentName != null) 'attachment_name': attachmentName,
      },
    );
    return SupportTicket.fromJson(_client.asMap(json));
  }

  Future<bool> applyPromoCode(String code) async {
    final json = await _client.post(
      ApiConfig.applyPromo,
      data: {'code': code},
    );
    final map = _client.asMap(json);
    return readBool(map['valid'] ?? map['success'], false);
  }

  Future<void> subscribeNewsletter(String email) async {
    await _client.post(
      ApiConfig.newsletterSubscribe,
      data: {'email': email},
    );
  }

  Future<PaymentSession> createPaymentSession(String orderId) async {
    final json = await _client.post(
      ApiConfig.paymentSession,
      data: {'order_id': orderId},
    );
    return PaymentSession.fromJson(_client.asMap(json));
  }

  Future<PaymentResult> verifyPayment({
    required String sessionId,
    required String pin,
  }) async {
    final json = await _client.post(
      ApiConfig.paymentVerify,
      data: {
        'session_id': sessionId,
        'pin': pin,
      },
    );
    final map = _client.asMap(json);
    return PaymentResult(
      success: readBool(map['success'], true),
      transactionId: readString(
        map['transaction_id'] ?? map['transactionId'],
        'TXN-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }
}
