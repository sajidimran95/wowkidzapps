import 'package:flutter/material.dart';
import 'package:my_first_app/core/network/json_utils.dart';

class FeatureItem {
  const FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  factory FeatureItem.fromJson(Map<String, dynamic> json) {
    final title = readString(json['title'] ?? json['name']);
    return FeatureItem(
      title: title,
      subtitle: readString(json['subtitle'] ?? json['description']),
      icon: _iconForTitle(title),
    );
  }

  static IconData _iconForTitle(String title) => switch (title.toLowerCase()) {
        'easy returns' => Icons.assignment_return_outlined,
        '24/7 support' => Icons.support_agent_outlined,
        'secure payment' => Icons.lock_outline,
        'free shipping' => Icons.local_shipping_outlined,
        _ => Icons.star_outline,
      };
}
