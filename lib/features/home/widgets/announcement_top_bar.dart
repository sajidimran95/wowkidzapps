import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/data/models/announcement_bar_data.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementTopBar extends StatelessWidget {
  const AnnouncementTopBar({super.key, required this.bar});

  final AnnouncementBarData bar;

  Color? _parseColor(String value) {
    final hex = value.trim();
    if (hex.isEmpty) return null;
    final normalized = hex.startsWith('#') ? hex.substring(1) : hex;
    if (normalized.length == 6) {
      final parsed = int.tryParse('FF$normalized', radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return null;
  }

  Future<void> _openLink() async {
    if (bar.link.isEmpty) return;
    final uri = Uri.tryParse(bar.link);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (!bar.showOnMobile || !bar.visibleOnHome) {
      return const SizedBox.shrink();
    }

    final bg = _parseColor(bar.bgColor) ?? Theme.of(context).colorScheme.primary;
    final fg = _parseColor(bar.textColor) ?? Colors.white;

    final child = bar.isMedia
        ? CachedNetworkImage(
            imageUrl: bar.mediaUrl,
            height: 40,
            width: double.infinity,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          )
        : Text(
            bar.text.isNotEmpty ? bar.text : 'Welcome to our store',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
          );

    return Material(
      color: bg,
      child: InkWell(
        onTap: bar.link.isNotEmpty ? _openLink : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Center(child: child),
        ),
      ),
    );
  }
}
