import 'package:flutter/material.dart';

class PromoBanner {
  const PromoBanner({
    required this.title,
    this.subtitle = '',
    this.gradient = const [Color(0xFFE91E8C), Color(0xFFFF6B9D)],
    this.icon = Icons.image_outlined,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final String? imageUrl;
}
