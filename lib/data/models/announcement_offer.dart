import 'package:my_first_app/core/network/json_utils.dart';

class AnnouncementOffer {
  const AnnouncementOffer({
    required this.title,
    required this.details,
    required this.imageUrl,
    this.type = 'image',
    this.link = '',
    this.delaySeconds = 0,
    this.isNewsletter = false,
  });

  final String type;
  final String title;
  final String details;
  final String imageUrl;
  final String link;
  final int delaySeconds;
  final bool isNewsletter;

  factory AnnouncementOffer.fromJson(Map<String, dynamic> json) {
    return AnnouncementOffer(
      type: readString(json['type'], 'image'),
      title: readString(json['title'], ''),
      details: readString(json['details'], ''),
      imageUrl: readString(json['image_url'] ?? json['image'], ''),
      link: readString(json['link'], ''),
      delaySeconds: readInt(json['delay_seconds'], 0),
      isNewsletter: readBool(json['is_newsletter'], false),
    );
  }
}
