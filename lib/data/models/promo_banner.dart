import 'package:flutter/material.dart';

class PromoBanner {
  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
}
