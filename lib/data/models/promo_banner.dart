import 'package:flutter/material.dart';
import 'package:my_first_app/core/network/json_utils.dart';

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

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    final colors = asJsonList(json['gradient'] ?? json['colors'])
        .map((c) {
          final s = c.toString().replaceFirst('#', '');
          if (s.length == 6) return Color(int.parse('FF$s', radix: 16));
          return null;
        })
        .whereType<Color>()
        .toList();

    return PromoBanner(
      title: readString(json['title'] ?? json['name']),
      subtitle: readString(json['subtitle'] ?? json['description']),
      gradient: colors.length >= 2
          ? colors
          : const [Color(0xFFE91E8C), Color(0xFFFF6B9D)],
      imageUrl: readNullableString(
        json['image'] ?? json['image_url'] ?? json['banner'],
      ),
    );
  }
}
