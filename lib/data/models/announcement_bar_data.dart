import 'package:my_first_app/core/network/json_utils.dart';

class AnnouncementBarData {
  const AnnouncementBarData({
    required this.text,
    this.mode = 'text',
    this.showOnMobile = true,
    this.displayScope = 'all',
    this.bgColor = '',
    this.textColor = '',
    this.mediaUrl = '',
    this.link = '',
  });

  final String mode;
  final bool showOnMobile;
  final String displayScope;
  final String bgColor;
  final String textColor;
  final String text;
  final String mediaUrl;
  final String link;

  bool get isMedia => mode == 'media' && mediaUrl.isNotEmpty;

  bool get visibleOnHome =>
      displayScope == 'all' || displayScope == 'home';

  factory AnnouncementBarData.fromJson(Map<String, dynamic> json) {
    return AnnouncementBarData(
      mode: readString(json['mode'], 'text'),
      showOnMobile: readBool(json['show_on_mobile'], true),
      displayScope: readString(json['display_scope'], 'all'),
      bgColor: readString(json['bg_color'], ''),
      textColor: readString(json['text_color'], ''),
      text: readString(json['text'], ''),
      mediaUrl: readString(json['media_url'] ?? json['media'], ''),
      link: readString(json['link'], ''),
    );
  }
}
