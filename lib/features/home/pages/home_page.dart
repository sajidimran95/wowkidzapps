import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/mock/mock_data.dart';
import 'package:my_first_app/features/home/widgets/category_grid.dart';
import 'package:my_first_app/features/home/widgets/feature_strip.dart';
import 'package:my_first_app/features/home/widgets/home_app_bar.dart';
import 'package:my_first_app/features/home/widgets/newsletter_banner.dart';
import 'package:my_first_app/features/home/widgets/product_section.dart';
import 'package:my_first_app/features/home/widgets/promo_banner_carousel.dart';
import 'package:my_first_app/features/home/widgets/search_bar_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const HomeAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchBarWidget(),
              const PromoBannerCarousel(),
              const FeatureStrip(),
              const CategoryGrid(),
              ProductSection(
                title: 'Flash Deal',
                products: MockData.flashDeals,
                isFlashDeal: true,
              ),
              ProductSection(
                title: 'Hot Collection',
                products: MockData.hotCollection,
                accentColor: AppColors.accent,
              ),
              ProductSection(
                title: 'New Arrival',
                products: MockData.newArrivals,
                accentColor: AppColors.secondary,
                showViewAll: true,
              ),
              ProductSection(
                title: 'Recommended',
                products: MockData.recommended,
                showViewAll: true,
              ),
              const NewsletterBanner(),
            ],
          ),
        ),
      ],
    );
  }
}
