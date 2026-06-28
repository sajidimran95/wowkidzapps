import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/category_item.dart';
import 'package:my_first_app/data/models/feature_item.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/data/models/promo_banner.dart';

abstract final class MockData {
  static const appName = 'WowKidz';
  static const tagline = 'Shop Smart, Live Better';

  static const features = <FeatureItem>[
    FeatureItem(
      title: 'Easy Returns',
      subtitle: 'Simple return process',
      icon: Icons.assignment_return_outlined,
    ),
    FeatureItem(
      title: '24/7 Support',
      subtitle: 'Always here to help',
      icon: Icons.support_agent_outlined,
    ),
    FeatureItem(
      title: 'Secure Payment',
      subtitle: 'Encrypted checkout',
      icon: Icons.lock_outline,
    ),
    FeatureItem(
      title: 'Free Shipping',
      subtitle: 'On eligible orders',
      icon: Icons.local_shipping_outlined,
    ),
  ];

  static const categories = <CategoryItem>[
    CategoryItem(
      name: 'Girls Clothing',
      imageUrl:
          'https://images.unsplash.com/photo-1519238263530-99bdd11df2ca?w=300&h=300&fit=crop',
      icon: Icons.girl_outlined,
      color: AppColors.categoryPink,
    ),
    CategoryItem(
      name: 'Boys Clothing',
      imageUrl:
          'https://images.unsplash.com/photo-1503919005310-48f16f5f8f4f?w=300&h=300&fit=crop',
      icon: Icons.boy_outlined,
      color: AppColors.categoryBlue,
    ),
    CategoryItem(
      name: 'Footwear',
      imageUrl:
          'https://images.unsplash.com/photo-1515347619252-60a4bf4fff4f?w=300&h=300&fit=crop',
      icon: Icons.ice_skating_outlined,
      color: AppColors.categoryYellow,
    ),
    CategoryItem(
      name: 'Baby Care',
      imageUrl:
          'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=300&h=300&fit=crop',
      icon: Icons.child_care_outlined,
      color: AppColors.categoryGreen,
    ),
    CategoryItem(
      name: 'Gents Clothing',
      imageUrl:
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300&h=300&fit=crop',
      icon: Icons.man_outlined,
      color: AppColors.categoryPurple,
    ),
    CategoryItem(
      name: 'Toys & Play',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&h=300&fit=crop',
      icon: Icons.toys_outlined,
      color: AppColors.categoryOrange,
    ),
    CategoryItem(
      name: 'Baby Accessories',
      imageUrl:
          'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=300&h=300&fit=crop',
      icon: Icons.baby_changing_station_outlined,
      color: AppColors.categoryTeal,
    ),
  ];

  static const sliderBanners = <PromoBanner>[
    PromoBanner(
      title: 'Kids Fashion Sale',
      subtitle: 'Up to 50% off on party wear',
      gradient: [Color(0xFFE91E8C), Color(0xFFFF6B9D)],
      icon: Icons.celebration_outlined,
      imageUrl:
          'https://images.unsplash.com/photo-1519238263530-99bdd11df2ca?w=900&h=450&fit=crop',
    ),
    PromoBanner(
      title: 'New Arrivals',
      subtitle: 'Fresh styles for every season',
      gradient: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
      icon: Icons.auto_awesome_outlined,
      imageUrl:
          'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=900&h=450&fit=crop',
    ),
    PromoBanner(
      title: 'Baby Essentials',
      subtitle: 'Care, toys & accessories',
      gradient: [Color(0xFFFF6B35), Color(0xFFFFB347)],
      icon: Icons.child_care,
      imageUrl:
          'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=900&h=450&fit=crop',
    ),
  ];

  static const homeSideBanners = <PromoBanner>[
    PromoBanner(
      title: 'Boys Collection',
      subtitle: 'Trendy combos',
      gradient: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
      imageUrl:
          'https://images.unsplash.com/photo-1503919005310-48f16f5f8f4f?w=500&h=280&fit=crop',
    ),
    PromoBanner(
      title: 'Girls Collection',
      subtitle: 'Party wear',
      gradient: [Color(0xFFEC4899), Color(0xFFF472B6)],
      imageUrl:
          'https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=500&h=280&fit=crop',
    ),
  ];

  static const flashDeals = <Product>[
    Product(
      id: '1',
      name: 'Elegant Purple Girls Sharara Set – Stylish Party Wear',
      category: 'Girls Clothing',
      originalPrice: 2400,
      salePrice: 1990,
      discountPercent: 17,
      imageUrl:
          'https://images.unsplash.com/photo-1519238263530-99bdd11df2ca?w=400&h=500&fit=crop',
    ),
    Product(
      id: '2',
      name: 'Master Yellow Girls Sharara Set – Elegant Party Wear',
      category: 'Girls Clothing',
      originalPrice: 2400,
      salePrice: 1990,
      discountPercent: 17,
      imageUrl:
          'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=400&h=500&fit=crop',
    ),
    Product(
      id: '3',
      name: 'Baby Pink Elegant Girls Sharara Set Stylish Party',
      category: 'Girls Clothing',
      originalPrice: 2400,
      salePrice: 1990,
      discountPercent: 17,
      imageUrl:
          'https://images.unsplash.com/photo-1522771930-f63ac13e4d12?w=400&h=500&fit=crop',
      inStock: false,
    ),
    Product(
      id: '4',
      name: 'Elegant Girls Sharara Set Stylish Party Wear Outfit',
      category: 'Girls Clothing',
      originalPrice: 2400,
      salePrice: 1990,
      discountPercent: 17,
      imageUrl:
          'https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=400&h=500&fit=crop',
      inStock: false,
    ),
  ];

  static const hotCollection = <Product>[
    Product(
      id: '5',
      name: 'Elegant Princess Garara Set Pink',
      category: 'Girls Clothing',
      originalPrice: 2700,
      salePrice: 2200,
      discountPercent: 19,
      imageUrl:
          'https://images.unsplash.com/photo-1514090458221-65bb69cf63e6?w=400&h=500&fit=crop',
      inStock: false,
    ),
    Product(
      id: '6',
      name: 'Elegant Princess Sharara Set 003',
      category: 'Girls Clothing',
      originalPrice: 2700,
      salePrice: 2200,
      discountPercent: 19,
      imageUrl:
          'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400&h=500&fit=crop',
    ),
    Product(
      id: '7',
      name: 'Elegant Princess Sharara Set 001',
      category: 'Girls Clothing',
      originalPrice: 2700,
      salePrice: 2200,
      discountPercent: 19,
      imageUrl:
          'https://images.unsplash.com/photo-1565299585323-38a6ae085f26?w=400&h=500&fit=crop',
    ),
    Product(
      id: '8',
      name: 'Elegant Princess Garara Set 3',
      category: 'Girls Clothing',
      originalPrice: 2700,
      salePrice: 2200,
      discountPercent: 19,
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=500&fit=crop',
    ),
  ];

  static const newArrivals = <Product>[
    Product(
      id: '9',
      name: 'Boys Premium 4 Pcs T-Shirt & Shorts Combo Set',
      category: 'Boys Clothing',
      originalPrice: 1800,
      salePrice: 1700,
      discountPercent: 6,
      imageUrl:
          'https://images.unsplash.com/photo-1503919005310-48f16f5f8f4f?w=400&h=500&fit=crop',
    ),
    Product(
      id: '10',
      name: 'Boys Fashion 2 Pcs T-Shirt & Shorts Combo Set',
      category: 'Boys Clothing',
      originalPrice: 1000,
      salePrice: 900,
      discountPercent: 10,
      imageUrl:
          'https://images.unsplash.com/photo-1622290291468-a28f7a7dc774?w=400&h=500&fit=crop',
    ),
    Product(
      id: '11',
      name: 'Kids Fashion 3 Pcs Printed Combo Set for Boys',
      category: 'Boys Clothing',
      originalPrice: 1350,
      salePrice: 1300,
      discountPercent: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1519457431-44acd35670d2?w=400&h=500&fit=crop',
    ),
    Product(
      id: '12',
      name: 'Kids Trendy 2 Pcs T-Shirt & Shorts Combo Set',
      category: 'Boys Clothing',
      originalPrice: 1000,
      salePrice: 900,
      discountPercent: 10,
      imageUrl:
          'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&h=500&fit=crop',
    ),
  ];

  static const recommended = <Product>[
    ...flashDeals,
    Product(
      id: '13',
      name: 'Elegant Princess Garara Set 2',
      category: 'Girls Clothing',
      originalPrice: 2700,
      salePrice: 2200,
      discountPercent: 19,
      imageUrl:
          'https://images.unsplash.com/photo-1583485088034-6977f15388fa?w=400&h=500&fit=crop',
    ),
    Product(
      id: '14',
      name: 'Boys 2 Pcs Trendy Genji & Short Combo Set',
      category: 'Boys Clothing',
      originalPrice: 1000,
      salePrice: 900,
      discountPercent: 10,
      imageUrl:
          'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=400&h=500&fit=crop',
    ),
  ];

  static const moreProducts = <Product>[
    Product(
      id: '15',
      name: 'Kids Colorful Sneakers – Comfortable Daily Wear',
      category: 'Footwear',
      originalPrice: 1500,
      salePrice: 1290,
      discountPercent: 14,
      imageUrl:
          'https://images.unsplash.com/photo-1515347619252-60a4bf4fff4f?w=400&h=500&fit=crop',
      sizes: const ['24', '26', '28', '30', '32'],
      description:
          'Lightweight kids sneakers with soft sole and breathable mesh upper.',
    ),
    Product(
      id: '16',
      name: 'Boys Sports Running Shoes',
      category: 'Footwear',
      originalPrice: 1800,
      salePrice: 1550,
      discountPercent: 14,
      imageUrl:
          'https://images.unsplash.com/photo-1560769629-975ec94ea6c6?w=400&h=500&fit=crop',
      sizes: const ['26', '28', '30', '32', '34'],
    ),
    Product(
      id: '17',
      name: 'Organic Baby Lotion & Wash Combo',
      category: 'Baby Care',
      originalPrice: 850,
      salePrice: 750,
      discountPercent: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400&h=500&fit=crop',
      sizes: const ['250ml', '500ml'],
      description: 'Gentle, tear-free formula safe for newborn skin.',
    ),
    Product(
      id: '18',
      name: 'Premium Baby Diaper Pack – 48 Pcs',
      category: 'Baby Care',
      originalPrice: 1200,
      salePrice: 1050,
      discountPercent: 13,
      imageUrl:
          'https://images.unsplash.com/photo-1584515933487-779824d29309?w=400&h=500&fit=crop',
      sizes: const ['S', 'M', 'L', 'XL'],
    ),
    Product(
      id: '19',
      name: 'Men Casual Cotton Panjabi',
      category: 'Gents Clothing',
      originalPrice: 2200,
      salePrice: 1890,
      discountPercent: 14,
      imageUrl:
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400&h=500&fit=crop',
      sizes: const ['M', 'L', 'XL', 'XXL'],
    ),
    Product(
      id: '20',
      name: 'Gents Formal Shirt – Slim Fit',
      category: 'Gents Clothing',
      originalPrice: 1600,
      salePrice: 1390,
      discountPercent: 13,
      imageUrl:
          'https://images.unsplash.com/photo-1602810318383-77dc0a574d38?w=400&h=500&fit=crop',
      sizes: const ['M', 'L', 'XL'],
    ),
    Product(
      id: '21',
      name: 'Educational Building Blocks Set',
      category: 'Toys & Play',
      originalPrice: 950,
      salePrice: 790,
      discountPercent: 17,
      imageUrl:
          'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400&h=500&fit=crop',
      sizes: const ['50 pcs', '100 pcs'],
      description: 'Colorful blocks that boost creativity and motor skills.',
    ),
    Product(
      id: '22',
      name: 'Remote Control Racing Car',
      category: 'Toys & Play',
      originalPrice: 1400,
      salePrice: 1190,
      discountPercent: 15,
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=500&fit=crop',
      sizes: const ['One Size'],
    ),
    Product(
      id: '23',
      name: 'Soft Baby Blanket – Premium Fleece',
      category: 'Baby Accessories',
      originalPrice: 1100,
      salePrice: 890,
      discountPercent: 19,
      imageUrl:
          'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=400&h=500&fit=crop',
      sizes: const ['70x100', '100x120'],
    ),
    Product(
      id: '24',
      name: 'Baby Feeding Bottle Set – BPA Free',
      category: 'Baby Accessories',
      originalPrice: 750,
      salePrice: 650,
      discountPercent: 13,
      imageUrl:
          'https://images.unsplash.com/photo-1583947215251-38ed74016b9b?w=400&h=500&fit=crop',
      sizes: const ['150ml', '250ml'],
    ),
  ];

  static List<Product> get allProducts {
    final products = <String, Product>{};
    for (final product in [
      ...flashDeals,
      ...hotCollection,
      ...newArrivals,
      ...recommended,
      ...moreProducts,
    ]) {
      products[product.id] = product;
    }
    return products.values.toList();
  }

  static Product? productById(String id) {
    for (final product in allProducts) {
      if (product.id == id) return product;
    }
    return null;
  }

  static List<Product> productsByCategory(String category) {
    return allProducts.where((p) => p.category == category).toList();
  }

  static int productCountForCategory(String category) {
    return productsByCategory(category).length;
  }
}
