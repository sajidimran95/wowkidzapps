import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.name,
    required this.imageUrl,
    required this.color,
    this.icon = Icons.category_outlined,
  });

  final String name;
  final String imageUrl;
  final Color color;
  final IconData icon;
}
