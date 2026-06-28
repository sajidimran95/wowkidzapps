import 'package:my_first_app/core/network/json_utils.dart';

class NewsletterBlock {
  const NewsletterBlock({
    required this.title,
    required this.details,
    this.imageUrl = '',
  });

  final String title;
  final String details;
  final String imageUrl;

  factory NewsletterBlock.fromJson(Map<String, dynamic> json) {
    return NewsletterBlock(
      title: readString(json['title'], 'Get 50% Discount'),
      details: readString(
        json['details'],
        'Subscribe to our newsletter for early discount offers, latest news & promos.',
      ),
      imageUrl: readString(json['image_url'] ?? json['image'], ''),
    );
  }
}
