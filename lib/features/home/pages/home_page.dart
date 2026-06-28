import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/features/home/widgets/category_grid.dart';
import 'package:my_first_app/features/home/widgets/feature_strip.dart';
import 'package:my_first_app/features/home/widgets/home_app_bar.dart';
import 'package:my_first_app/features/home/widgets/newsletter_banner.dart';
import 'package:my_first_app/features/home/widgets/product_section.dart';
import 'package:my_first_app/features/home/widgets/promo_banner_carousel.dart';
import 'package:my_first_app/shared/widgets/api_state_views.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _catalog = CatalogStore.instance;

  @override
  void initState() {
    super.initState();
    if (!_catalog.hasData && !_catalog.isLoading) {
      _catalog.loadHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _catalog,
      builder: (context, _) {
        if (_catalog.isLoading && !_catalog.hasData) {
          return const CustomScrollView(
            slivers: [
              HomeAppBar(),
              SliverFillRemaining(child: ApiLoadingView(message: 'Loading store...')),
            ],
          );
        }

        if (_catalog.error != null && !_catalog.hasData) {
          return CustomScrollView(
            slivers: [
              const HomeAppBar(),
              SliverFillRemaining(
                child: ApiErrorView(
                  message: _catalog.error!,
                  onRetry: () => _catalog.loadHome(refresh: true),
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () => _catalog.loadHome(refresh: true),
          child: CustomScrollView(
            slivers: [
              const HomeAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PromoBannerCarousel(
                      banners: _catalog.sliderBanners,
                      sideBanners: _catalog.homeSideBanners,
                    ),
                    FeatureStrip(features: _catalog.features),
                    CategoryGrid(categories: _catalog.categories),
                    if (_catalog.flashDeals.isNotEmpty)
                      ProductSection(
                        title: 'Flash Deal',
                        products: _catalog.flashDeals,
                        isFlashDeal: true,
                      ),
                    if (_catalog.hotCollection.isNotEmpty)
                      ProductSection(
                        title: 'Hot Collection',
                        products: _catalog.hotCollection,
                      ),
                    if (_catalog.newArrivals.isNotEmpty)
                      ProductSection(
                        title: 'New Arrival',
                        products: _catalog.newArrivals,
                        viewAllProducts: _catalog.allNewArrivals.isNotEmpty
                            ? _catalog.allNewArrivals
                            : _catalog.newArrivals,
                        showViewAll: true,
                      ),
                    if (_catalog.recommended.isNotEmpty)
                      ProductSection(
                        title: 'Recommended',
                        products: _catalog.recommended,
                        viewAllProducts: _catalog.allRecommended.isNotEmpty
                            ? _catalog.allRecommended
                            : _catalog.recommended,
                        showViewAll: true,
                      ),
                    const NewsletterBanner(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
