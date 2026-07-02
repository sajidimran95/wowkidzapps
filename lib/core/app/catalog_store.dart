import 'package:flutter/material.dart';
import 'package:my_first_app/core/network/api_exception.dart';
import 'package:my_first_app/core/network/json_utils.dart';
import 'package:my_first_app/data/api/wowkidz_api.dart';
import 'package:my_first_app/data/models/announcement_bar_data.dart';
import 'package:my_first_app/data/models/announcement_offer.dart';
import 'package:my_first_app/data/models/app_popup.dart';
import 'package:my_first_app/data/models/category_item.dart';
import 'package:my_first_app/data/models/feature_item.dart';
import 'package:my_first_app/data/models/newsletter_block.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/data/models/promo_banner.dart';
import 'package:my_first_app/data/models/shipping_settings.dart';
import 'package:my_first_app/data/models/whatsapp_chat_config.dart';
import 'package:my_first_app/features/home/widgets/flash_deal_banner.dart';
import 'package:my_first_app/shared/utils/product_sort.dart';

class CatalogStore extends ChangeNotifier {
  CatalogStore._();
  static final CatalogStore instance = CatalogStore._();

  static const int recommendedHomeMax = 20;

  final _api = WowKidzApi.instance;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isBootstrapping = false;
  bool bootstrapComplete = false;
  bool apiEnabled = false;
  String? error;

  String appName = 'WowKidz';
  String tagline = 'Shop Smart, Live Better';
  String? logoUrl;
  String? faviconUrl;
  String? preloaderUrl;
  bool guestCheckoutEnabled = true;

  List<FeatureItem> features = [];
  List<CategoryItem> categories = [];
  List<PromoBanner> sliderBanners = [];
  List<PromoBanner> homeSideBanners = [];
  List<PromoBanner> recommendedTopBanners = [];
  List<Product> flashDeals = [];
  List<Product> hotCollection = [];
  List<Product> newArrivals = [];
  List<Product> recommended = [];
  List<Product> allNewArrivals = [];
  List<Product> allRecommended = [];
  List<Product> campaignProducts = [];
  List<AppPopup> popups = [];
  AnnouncementBarData? announcementBar;
  AnnouncementOffer? announcementOffer;
  NewsletterBlock newsletter = const NewsletterBlock(
    title: 'Get 50% Discount',
    details:
        'Subscribe to our newsletter for early discount offers, latest news & promos.',
  );
  WhatsAppChatConfig whatsapp = const WhatsAppChatConfig();
  ShippingSettings shippingSettings = const ShippingSettings();

  String flashDealTitle = 'Flash Deal';
  String hotCollectionTitle = 'Hot Collection';
  String newArrivalTitle = 'New Arrival';
  String recommendedTitle = 'Recommended';
  String campaignTitle = 'Campaign Offer';
  String? campaignEndDate;
  String? flashDealEndDate;

  DateTime? get effectiveFlashDealEndDate =>
      resolveFlashDealEndDate(flashDealEndDate, flashDeals);

  /// Up to [recommendedHomeMax] recommended products for the home grid.
  List<Product> get recommendedForHome {
    final byId = <String, Product>{};
    for (final product in [...allRecommended, ...recommended]) {
      byId[product.id] = product;
    }
    return sortProductsStockFirst(byId.values.toList())
        .take(recommendedHomeMax)
        .toList();
  }
  bool showCampaign = true;
  bool showHotCollection = true;
  bool showRecommendedTopBanners = true;

  final Map<String, Product> _productById = {};
  final Map<String, List<Product>> _productsByCategory = {};

  bool get hasData =>
      categories.isNotEmpty ||
      sliderBanners.isNotEmpty ||
      flashDeals.isNotEmpty;

  List<Product> get allProducts => _productById.values.toList();

  Product? productById(String id) => _productById[id];

  int productCountForCategory(String categoryName) {
    final cached = _productsByCategory[categoryName];
    if (cached != null) return cached.length;
    final category = categories.where((c) => c.name == categoryName).firstOrNull;
    if (category != null && category.productCount > 0) {
      return category.productCount;
    }
    return allProducts.where((p) => p.category == categoryName).length;
  }

  List<Product> productsByCategory(String categoryName) {
    if (_productsByCategory.containsKey(categoryName)) {
      return List.unmodifiable(_productsByCategory[categoryName]!);
    }
    return allProducts.where((p) => p.category == categoryName).toList();
  }

  Future<void> bootstrap() async {
    if (bootstrapComplete || isBootstrapping) return;

    isBootstrapping = true;
    isLoading = true;
    error = null;
    notifyListeners();

    final minEnd = DateTime.now().add(const Duration(milliseconds: 2500));

    try {
      final status = await _api.getMobileStatus();
      apiEnabled = readBool(status['mobile_api_enabled'], false);
      _applyBranding(status);
      _applyWhatsapp(status['whatsapp']);
      notifyListeners();

      if (!apiEnabled) {
        error =
            'Mobile App API is disabled. Enable it from Admin → Manage Site → Mobile App API.';
      } else {
        try {
          await _loadFromHomeEndpoint();
        } on ApiException catch (e) {
          if (e.statusCode == 403 &&
              e.message.toLowerCase().contains('disabled')) {
            apiEnabled = false;
            error = e.message;
          } else {
            await _loadFromSeparateEndpoints();
          }
        }
      }
    } catch (e) {
      error = e.toString();
      try {
        await _loadFromSeparateEndpoints();
      } catch (_) {}
    } finally {
      isLoading = false;
      isRefreshing = false;
    }

    final wait = minEnd.difference(DateTime.now());
    if (wait > Duration.zero) {
      await Future<void>.delayed(wait);
    }

    bootstrapComplete = true;
    isBootstrapping = false;
    notifyListeners();
  }

  Future<void> loadHome({bool refresh = false}) async {
    if (isLoading && !refresh) return;

    if (refresh) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    error = null;
    notifyListeners();

    try {
      final status = await _api.getMobileStatus();
      apiEnabled = readBool(status['mobile_api_enabled'], false);
      _applyBranding(status);
      _applyWhatsapp(status['whatsapp']);

      if (!apiEnabled) {
        error =
            'Mobile App API is disabled. Enable it from Admin → Manage Site → Mobile App API.';
        isLoading = false;
        isRefreshing = false;
        notifyListeners();
        return;
      }

      await _loadFromHomeEndpoint();
    } on ApiException catch (e) {
      if (e.statusCode == 403 &&
          e.message.toLowerCase().contains('disabled')) {
        apiEnabled = false;
        error = e.message;
        isLoading = false;
        isRefreshing = false;
        notifyListeners();
        return;
      }
      try {
        await _loadFromSeparateEndpoints();
      } on ApiException catch (e2) {
        error = e2.message;
      } catch (e2) {
        error = e2.toString();
      }
      if (!hasData) {
        error ??= e.message;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromHomeEndpoint() async {
    final map = await _api.getHome();
    _applySettings(map);
    _applyFeatures(map['features']);
    _applySliders(map['sliders'] ?? map['slider_banners']);
    _applySideBanners(map['side_banners'] ?? map['banners']);
    _applyRecommendedTopBanners(
      map['three_column_banners'] ?? map['banner_first'],
    );
    _applyCategories(map['categories']);
    _applySections(asJsonMap(map['sections'] ?? map));
    if (recommended.isEmpty) {
      recommended = _parseProducts(map['recommended']);
    }
    if (allRecommended.isEmpty) {
      allRecommended = _parseProducts(
        map['all_recommended'] ?? map['recommended_all'] ?? recommended,
      );
    }
    if (allRecommended.isEmpty && recommended.isNotEmpty) {
      allRecommended = recommended;
    }
    await _ensureRecommendedLoaded();
    _applyPromotions(map);
    _applyWhatsapp(map['whatsapp']);
    notifyListeners();
  }

  Future<void> _loadFromSeparateEndpoints() async {
    try {
      final settings = await _api.getSettings();
      _applySettings(settings);
    } catch (_) {}

    try {
      final featureList = await _api.getFeatures();
      _applyFeatures(featureList);
    } catch (_) {}

    try {
      final sliders = await _api.getSliders();
      _applySliders(sliders);
    } catch (_) {}

    try {
      final sideBanners = await _api.getBanners(type: 'side');
      _applySideBanners(sideBanners);
    } catch (_) {
      try {
        final banners = await _api.getBanners();
        _applySideBanners(banners);
      } catch (_) {}
    }

    try {
      final topBanners = await _api.getBanners(type: 'three_column');
      _applyRecommendedTopBanners(topBanners);
    } catch (_) {}

    final categoryList = await _api.getCategories();
    _applyCategories(categoryList);

    flashDeals = await _loadProductSection('flash_deal');
    hotCollection = await _loadProductSection('hot_collection');
    newArrivals = await _loadProductSection('new_arrival');
    recommended = await _loadProductSection('recommended');
    campaignProducts = await _loadProductSection('campaign');
    allNewArrivals = await _loadProductSection('new_arrival', viewAll: true);
    allRecommended = await _loadProductSection('recommended', viewAll: true);
  }

  Future<List<Product>> _loadProductSection(
    String section, {
    bool viewAll = false,
  }) async {
    final list = await _api.getProducts(
      section: sectionApiKey(section),
      perPage: viewAll ? 100 : 20,
    );
    return _parseProducts(list);
  }

  static const _sectionApiKeys = {
    'flash_deal': 'flash_deal',
    'hot_collection': 'hot_collection',
    'new_arrival': 'new_arrivals',
    'recommended': 'recommended_products',
    'campaign': 'campaign',
  };

  static String sectionApiKey(String section) =>
      _sectionApiKeys[section] ?? section;

  Future<List<Product>> fetchSectionProducts(String section) async {
    final list = await _api.getProducts(
      section: sectionApiKey(section),
      perPage: 100,
    );
    return _parseProducts(list);
  }

  void _applySettings(Map<String, dynamic> map) {
    _applyBranding(map);
    _applyWhatsapp(map['whatsapp']);
    _applyShipping(map);
  }

  void _applyShipping(Map<String, dynamic> map) {
    shippingSettings = ShippingSettings.fromJson(map);
  }

  void _applyWhatsapp(dynamic raw) {
    if (raw is Map) {
      whatsapp = WhatsAppChatConfig.fromJson(asJsonMap(raw));
    }
  }

  void _applyBranding(Map<String, dynamic> map) {
    appName = readString(map['app_name'] ?? map['name'], appName);
    tagline = readString(map['tagline'] ?? map['slogan'], tagline);
    logoUrl = readNullableString(map['logo_url'] ?? map['logo']) ?? logoUrl;
    faviconUrl =
        readNullableString(map['favicon_url'] ?? map['favicon']) ?? faviconUrl;
    preloaderUrl = readNullableString(
      map['preloader_url'] ??
          map['preloader'] ??
          map['preloader_image'] ??
          map['loader'],
    ) ??
        (readBool(map['is_preloader_enabled'], true)
            ? readNullableString(map['logo_url'] ?? map['logo'])
            : null) ??
        preloaderUrl;
    guestCheckoutEnabled = readBool(
      map['is_guest_checkout'] ?? map['guest_checkout_enabled'],
      guestCheckoutEnabled,
    );
  }

  void _applyFeatures(dynamic raw) {
    final list = asJsonList(raw);
    if (list.isEmpty) return;
    features = list
        .map((e) => FeatureItem.fromJson(asJsonMap(e)))
        .toList();
  }

  void _applySliders(dynamic raw) {
    final list = asJsonList(raw);
    if (list.isEmpty) return;
    sliderBanners =
        list.map((e) => PromoBanner.fromJson(asJsonMap(e))).toList();
  }

  void _applySideBanners(dynamic raw) {
    final list = asJsonList(raw);
    if (list.isEmpty) return;
    homeSideBanners =
        list.map((e) => PromoBanner.fromJson(asJsonMap(e))).toList();
  }

  void _applyRecommendedTopBanners(dynamic raw) {
    final list = asJsonList(raw);
    if (list.isEmpty) return;
    recommendedTopBanners = list
        .map((e) => PromoBanner.fromJson(asJsonMap(e)))
        .where((b) => b.imageUrl != null && b.imageUrl!.trim().isNotEmpty)
        .take(3)
        .toList();
  }

  void _applyCategories(dynamic raw) {
    final list = asJsonList(raw);
    if (list.isEmpty) return;
    categories =
        list.map((e) => CategoryItem.fromJson(asJsonMap(e))).toList();
  }

  void _applySections(Map<String, dynamic> map) {
    _applyFlashDealSection(
      map['flash_deal'] ?? map['flash_deals'] ?? map['flashDeals'],
    );
    hotCollection = _parseProducts(
      map['hot_collection'] ?? map['hotCollection'],
    );
    newArrivals = _parseProducts(
      map['new_arrival'] ?? map['new_arrivals'] ?? map['newArrivals'],
    );
    _applyRecommendedSection(map['recommended']);
    allNewArrivals = _parseProducts(
      map['all_new_arrivals'] ?? map['new_arrival_all'] ?? newArrivals,
    );
    allRecommended = _parseProducts(
      map['all_recommended'] ?? map['recommended_all'] ?? recommended,
    );
    if (allRecommended.isEmpty && recommended.isNotEmpty) {
      allRecommended = recommended;
    }
    campaignProducts = _parseProducts(map['campaign']);
  }

  void _applyRecommendedSection(dynamic raw) {
    if (raw is Map) {
      final map = asJsonMap(raw);
      recommended = _parseProducts(map['products'] ?? map['items']);
      return;
    }
    recommended = _parseProducts(raw);
  }

  Future<void> _ensureRecommendedLoaded() async {
    if (recommendedForHome.isNotEmpty) return;
    try {
      final fromApi = await _loadProductSection('recommended', viewAll: true);
      if (fromApi.isEmpty) return;
      allRecommended = fromApi;
      recommended = fromApi.take(recommendedHomeMax).toList();
    } catch (_) {}
  }

  void _applyFlashDealSection(dynamic raw) {
    if (raw is Map) {
      final map = asJsonMap(raw);
      flashDealTitle = readString(map['title'], flashDealTitle);
      flashDealEndDate = readNullableString(
        map['end_date'] ?? map['ends_at'] ?? map['endDate'],
      );
      flashDeals = _parseProducts(map['products'] ?? map['items']);
      return;
    }

    flashDeals = _parseProducts(raw);
  }

  void _applyPromotions(Map<String, dynamic> map) {
    final popupList = asJsonList(map['popups']);
    if (popupList.isNotEmpty) {
      popups = popupList
          .map((e) => AppPopup.fromJson(asJsonMap(e)))
          .where((p) => p.imageUrl.isNotEmpty)
          .toList();
    }

    final barRaw = map['announcement_bar'];
    if (barRaw is Map) {
      announcementBar = AnnouncementBarData.fromJson(asJsonMap(barRaw));
    } else {
      announcementBar = null;
    }

    final offerRaw = map['announcement_offer'];
    if (offerRaw is Map) {
      announcementOffer = AnnouncementOffer.fromJson(asJsonMap(offerRaw));
    } else {
      announcementOffer = null;
    }

    final newsletterRaw = map['newsletter'];
    if (newsletterRaw is Map) {
      newsletter = NewsletterBlock.fromJson(asJsonMap(newsletterRaw));
    }

    final campaignRaw = map['campaign'];
    if (campaignRaw is Map) {
      final campaignMap = asJsonMap(campaignRaw);
      showCampaign = readBool(campaignMap['is_active'], showCampaign);
      campaignTitle = readString(campaignMap['title'], campaignTitle);
      campaignEndDate = readNullableString(campaignMap['end_date']);
      final products = _parseProducts(campaignMap['products']);
      if (products.isNotEmpty) {
        campaignProducts = products;
      }
    }

    final labels = asJsonMap(map['section_labels']);
    flashDealTitle = readString(labels['flash_deal'], flashDealTitle);
    hotCollectionTitle = readString(labels['hot_collection'], hotCollectionTitle);
    newArrivalTitle = readString(labels['new_arrival'], newArrivalTitle);
    recommendedTitle = readString(labels['recommended'], recommendedTitle);
    campaignTitle = readString(labels['campaign'], campaignTitle);

    final sectionDates = asJsonMap(map['section_end_dates']);
    flashDealEndDate ??= readNullableString(
      sectionDates['flash_deal'] ?? sectionDates['flash_deals'],
    );

    final visibility = asJsonMap(map['section_visibility']);
    showCampaign = readBool(visibility['campaign'], showCampaign);
    showHotCollection = readBool(visibility['hot_collection'], showHotCollection);
    showRecommendedTopBanners = readBool(
      visibility['three_column_banners'],
      showRecommendedTopBanners,
    );
  }

  List<Product> _parseProducts(dynamic raw) {
    final list = asJsonList(raw);
    final products = <Product>[];
    for (final entry in list) {
      try {
        products.add(Product.fromJson(asJsonMap(entry)));
      } catch (_) {}
    }
    _cacheProducts(products);
    return sortProductsStockFirst(products);
  }

  void _cacheProducts(List<Product> products) {
    for (final product in products) {
      _productById[product.id] = product;
      _productsByCategory.putIfAbsent(product.category, () => []);
      if (!_productsByCategory[product.category]!
          .any((p) => p.id == product.id)) {
        _productsByCategory[product.category]!.add(product);
      }
    }
  }

  Future<List<Product>> fetchCategoryProducts(String categoryName) async {
    final category =
        categories.where((c) => c.name == categoryName).firstOrNull;
    try {
      final list = await _api.getProducts(
        categoryId: category?.id,
        category: categoryName,
        perPage: 100,
      );
      final products = _parseProducts(list);
      _productsByCategory[categoryName] = products;
      notifyListeners();
      return products;
    } on ApiException {
      return productsByCategory(categoryName);
    }
  }

  Future<Product?> fetchProductDetail(String id) async {
    final cached = productById(id);
    try {
      final product = await _api.getProduct(id);
      _productById[id] = product;
      notifyListeners();
      return product;
    } on ApiException {
      return cached;
    }
  }

  Future<List<Product>> enrichProductsWithVariants(List<Product> products) async {
    if (products.isEmpty) return products;

    final enriched = await Future.wait(
      products.map((product) async {
        if (!product.needsVariantSelection ||
            (product.sizes.isNotEmpty || product.colors.isNotEmpty)) {
          return product;
        }
        final detail = await fetchProductDetail(product.id);
        return detail ?? product;
      }),
    );

    return enriched;
  }

  Future<List<Product>> searchProducts(String query, {int perPage = 40}) async {
    if (query.trim().isEmpty) return [];
    final list = await _api.getProducts(
      search: query.trim(),
      perPage: perPage,
    );
    return _parseProducts(list);
  }

  Future<List<Product>> searchSuggestions(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return [];
    try {
      final list = await _api.getSearchSuggestions(
        query: query.trim(),
        limit: limit,
      );
      return _parseProducts(list);
    } on ApiException {
      return searchProducts(query, perPage: limit);
    }
  }

  Future<List<Product>> searchProductsByImage(String filePath) async {
    final list = await _api.searchProductsByImage(filePath);
    if (list.isEmpty) return [];
    return _parseProducts(list);
  }
}
