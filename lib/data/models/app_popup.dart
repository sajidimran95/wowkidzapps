import 'package:my_first_app/core/network/json_utils.dart';

class AppPopup {
  const AppPopup({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.link = '',
    this.openInNewTab = false,
    this.delaySeconds = 0,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String link;
  final bool openInNewTab;
  final int delaySeconds;

  factory AppPopup.fromJson(Map<String, dynamic> json) {
    return AppPopup(
      id: readString(json['id'], ''),
      title: readString(json['title'], ''),
      imageUrl: readString(json['image_url'] ?? json['image'], ''),
      link: readString(json['link'], ''),
      openInNewTab: readBool(json['open_in_new_tab'], false),
      delaySeconds: readInt(json['delay_seconds'], 0),
    );
  }
}
