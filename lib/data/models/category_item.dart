import 'package:flutter/material.dart';
import 'package:my_first_app/core/network/json_utils.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

class CategoryItem {
  const CategoryItem({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
    this.icon = Icons.category_outlined,
    this.showImage = true,
    this.productCount = 0,
  });

  final String? id;
  final String name;
  final String imageUrl;
  final Color color;
  final IconData icon;
  final bool showImage;
  final int productCount;

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    final name = readString(json['name'] ?? json['title']);
    return CategoryItem(
      id: readNullableString(json['id'] ?? json['slug']),
      name: name,
      imageUrl: readString(
        json['image'] ??
            json['image_url'] ??
            json['thumbnail'] ??
            json['icon_url'],
      ),
      color: _colorForCategory(name, json['color']),
      icon: _iconForCategory(name),
      showImage: readBool(json['show_image'], true),
      productCount: readInt(json['product_count'] ?? json['products_count']),
    );
  }

  static Color _colorForCategory(String name, dynamic hex) {
    if (hex != null) {
      final s = hex.toString().replaceFirst('#', '');
      if (s.length == 6) {
        return Color(int.parse('FF$s', radix: 16));
      }
    }
    return switch (name.toLowerCase()) {
      'girls clothing' => AppColors.categoryPink,
      'boys clothing' => AppColors.categoryBlue,
      'footwear' => AppColors.categoryYellow,
      'baby care' => AppColors.categoryGreen,
      'gents clothing' => AppColors.categoryPurple,
      'toys & play' => AppColors.categoryOrange,
      'baby accessories' => AppColors.categoryTeal,
      _ => AppColors.primary,
    };
  }

  static IconData _iconForCategory(String name) => switch (name.toLowerCase()) {
        'girls clothing' => Icons.girl_outlined,
        'boys clothing' => Icons.boy_outlined,
        'footwear' => Icons.ice_skating_outlined,
        'baby care' => Icons.child_care_outlined,
        'gents clothing' => Icons.man_outlined,
        'toys & play' => Icons.toys_outlined,
        'baby accessories' => Icons.baby_changing_station_outlined,
        _ => Icons.category_outlined,
      };
}
