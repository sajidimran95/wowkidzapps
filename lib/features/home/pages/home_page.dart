import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/features/home/widgets/announcement_top_bar.dart';
import 'package:my_first_app/features/home/widgets/flash_deal_banner.dart';
import 'package:my_first_app/features/home/widgets/category_grid.dart';
import 'package:my_first_app/features/home/widgets/feature_strip.dart';
import 'package:my_first_app/features/home/widgets/home_app_bar.dart';
import 'package:my_first_app/features/home/widgets/newsletter_banner.dart';
import 'package:my_first_app/features/home/widgets/product_section.dart';
import 'package:my_first_app/features/home/widgets/promo_banner_carousel.dart';
import 'package:my_first_app/features/home/widgets/recommended_product_grid.dart';
import 'package:my_first_app/features/home/widgets/three_column_banner_row.dart';
import 'package:my_first_app/features/home/widgets/website_popup_overlay.dart';
import 'package:my_first_app/features/search/pages/search_results_page.dart';
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

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchResultsPage(query: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _catalog,
      builder: (context, _) {
        if (_catalog.isLoading && !_catalog.hasData) {
          return CustomScrollView(
            slivers: [
              HomeAppBar(onSearchTap: _openSearch),
              const SliverFillRemaining(
                child: ApiLoadingView(message: 'Loading store...'),
              ),
            ],
          );
        }

        if (_catalog.error != null && !_catalog.hasData) {
          return CustomScrollView(
            slivers: [
              HomeAppBar(onSearchTap: _openSearch),
              SliverFillRemaining(
                child: ApiErrorView(
                  message: _catalog.error!,
                  onRetry: () => _catalog.loadHome(refresh: true),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => _catalog.loadHome(refresh: true),
              child: CustomScrollView(
                slivers: [
                  HomeAppBar(onSearchTap: _openSearch),
                  if (_catalog.announcementBar != null)
                    SliverToBoxAdapter(
                      child: AnnouncementTopBar(bar: _catalog.announcementBar!),
                    ),
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
                        if (_catalog.showCampaign &&
                            _catalog.campaignProducts.isNotEmpty)
                          ProductSection(
                            title: _catalog.campaignTitle,
                            products: _catalog.campaignProducts,
                            isFlashDeal: true,
                            sectionKey: 'campaign',
                            endDate: parseSectionEndDate(_catalog.campaignEndDate),
                          ),
                        if (_catalog.flashDeals.isNotEmpty)
                          ProductSection(
                            title: _catalog.flashDealTitle,
                            products: _catalog.flashDeals,
                            isFlashDeal: true,
                            sectionKey: 'flash_deal',
                            endDate: _catalog.effectiveFlashDealEndDate,
                          ),
                        if (_catalog.showHotCollection &&
                            _catalog.hotCollection.isNotEmpty)
                          ProductSection(
                            title: _catalog.hotCollectionTitle,
                            products: _catalog.hotCollection,
                            sectionKey: 'hot_collection',
                          ),
                        if (_catalog.newArrivals.isNotEmpty)
                          ProductSection(
                            title: _catalog.newArrivalTitle,
                            products: _catalog.newArrivals,
                            sectionKey: 'new_arrival',
                          ),
                        if (_catalog.showRecommendedTopBanners &&
                            _catalog.recommendedTopBanners.isNotEmpty)
                          ThreeColumnBannerRow(
                            banners: _catalog.recommendedTopBanners,
                          ),
                        if (_catalog.recommendedForHome.isNotEmpty)
                          RecommendedProductGrid(
                            title: _catalog.recommendedTitle,
                            products: _catalog.recommendedForHome,
                            sectionKey: 'recommended',
                          ),
                        NewsletterBanner(block: _catalog.newsletter),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            WebsitePopupOverlay(
              popups: _catalog.popups,
              announcementOffer: _catalog.announcementOffer,
            ),
          ],
        );
      },
    );
  }
}
