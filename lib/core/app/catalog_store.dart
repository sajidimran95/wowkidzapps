import 'package:flutter/material.dart';
import 'package:my_first_app/core/network/api_exception.dart';
import 'package:my_first_app/core/network/json_utils.dart';
import 'package:my_first_app/data/api/wowkidz_api.dart';
import 'package:my_first_app/data/models/category_item.dart';
import 'package:my_first_app/data/models/feature_item.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/data/models/promo_banner.dart';

class CatalogStore extends ChangeNotifier {
  CatalogStore._();
  static final CatalogStore instance = CatalogStore._();

  final _api = WowKidzApi.instance;

  bool isLoading = false;
  bool isRefreshing = false;
  String? error;

  String appName = 'WowKidz';
  String tagline = 'Shop Smart, Live Better';

  List<FeatureItem> features = [];
  List<CategoryItem> categories = [];
  List<PromoBanner> sliderBanners = [];
  List<PromoBanner> homeSideBanners = [];
  List<Product> flashDeals = [];
  List<Product> hotCollection = [];
  List<Product> newArrivals = [];
  List<Product> recommended = [];
  List<Product> allNewArrivals = [];
  List<Product> allRecommended = [];

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
      await _loadFromHomeEndpoint();
    } on ApiException catch (e) {
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
    _applyCategories(map['categories']);
    _applySections(map['sections'] ?? map);
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

    final categoryList = await _api.getCategories();
    _applyCategories(categoryList);

    flashDeals = await _loadProductSection('flash_deal');
    hotCollection = await _loadProductSection('hot_collection');
    newArrivals = await _loadProductSection('new_arrival');
    recommended = await _loadProductSection('recommended');
    allNewArrivals = await _loadProductSection('new_arrival', viewAll: true);
    allRecommended = await _loadProductSection('recommended', viewAll: true);
  }

  Future<List<Product>> _loadProductSection(
    String section, {
    bool viewAll = false,
  }) async {
    final list = await _api.getProducts(
      section: section,
      perPage: viewAll ? 50 : 12,
    );
    return _parseProducts(list);
  }

  void _applySettings(Map<String, dynamic> map) {
    appName = readString(map['app_name'] ?? map['name'], appName);
    tagline = readString(map['tagline'] ?? map['slogan'], tagline);
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
    final banners =
        list.map((e) => PromoBanner.fromJson(asJsonMap(e))).toList();
    homeSideBanners = banners.length > 2 ? banners.take(2).toList() : banners;
  }

  void _applyCategories(dynamic raw) {
    final list = asJsonList(raw);
    if (list.isEmpty) return;
    categories =
        list.map((e) => CategoryItem.fromJson(asJsonMap(e))).toList();
  }

  void _applySections(Map<String, dynamic> map) {
    flashDeals = _parseProducts(
      map['flash_deal'] ?? map['flash_deals'] ?? map['flashDeals'],
    );
    hotCollection = _parseProducts(
      map['hot_collection'] ?? map['hotCollection'],
    );
    newArrivals = _parseProducts(
      map['new_arrival'] ?? map['new_arrivals'] ?? map['newArrivals'],
    );
    recommended = _parseProducts(map['recommended']);
    allNewArrivals = _parseProducts(
      map['all_new_arrivals'] ?? map['new_arrival_all'] ?? newArrivals,
    );
    allRecommended = _parseProducts(
      map['all_recommended'] ?? map['recommended_all'] ?? recommended,
    );
  }

  List<Product> _parseProducts(dynamic raw) {
    final list = asJsonList(raw);
    final products =
        list.map((e) => Product.fromJson(asJsonMap(e))).toList();
    _cacheProducts(products);
    return products;
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

  Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];
    final list = await _api.getProducts(search: query.trim(), perPage: 40);
    return _parseProducts(list);
  }
}
