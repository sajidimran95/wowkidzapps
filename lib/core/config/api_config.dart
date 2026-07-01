/// WowKidz mobile API configuration.
///
/// WhatsApp number comes from the same place as the website:
/// Admin → Setting → System → **WhatsApp number**
/// (`/admin/setting/system` on your store).
abstract final class ApiConfig {
  static const baseUrl = 'https://wowkidzbd.com/api';

  // Status (always available — app checks before loading data)
  static const mobileStatus = '/mobile/status';
  static const home = '/home';
  static const settings = '/settings';
  static const categories = '/categories';
  static const products = '/products';
  static const sliders = '/sliders';
  static const banners = '/banners';
  static const features = '/features';

  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const profile = '/auth/profile';
  static const changePassword = '/auth/change-password';

  // Customer
  static const orders = '/orders';
  static const addresses = '/addresses';
  static const wishlist = '/wishlist';
  static const supportTickets = '/support/tickets';

  // Cart & checkout
  static const applyPromo = '/cart/apply-promo';
  static const shipping = '/shipping';
  static const shippingCalculate = '/shipping/calculate';
  static const newsletterSubscribe = '/newsletter/subscribe';

  // Payments
  static const paymentSession = '/payments/session';
  static const paymentVerify = '/payments/verify';

  // Search
  static const imageSearch = '/products/image-search';
  static const searchSuggest = '/search/suggest';

  static const connectTimeout = Duration(seconds: 25);
  static const receiveTimeout = Duration(seconds: 25);
}
