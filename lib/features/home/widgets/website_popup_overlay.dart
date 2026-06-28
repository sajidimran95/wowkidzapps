import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/data/models/announcement_offer.dart';
import 'package:my_first_app/data/models/app_popup.dart';
import 'package:my_first_app/features/home/widgets/announcement_offer_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsitePopupOverlay extends StatefulWidget {
  const WebsitePopupOverlay({
    super.key,
    required this.popups,
    this.announcementOffer,
  });

  final List<AppPopup> popups;
  final AnnouncementOffer? announcementOffer;

  @override
  State<WebsitePopupOverlay> createState() => _WebsitePopupOverlayState();
}

class _WebsitePopupOverlayState extends State<WebsitePopupOverlay> {
  bool _visible = false;
  int _index = 0;
  bool _announcementShown = false;

  @override
  void initState() {
    super.initState();
    _schedulePopups();
  }

  void _schedulePopups() {
    if (widget.popups.isEmpty) {
      _scheduleAnnouncementOffer();
      return;
    }

    final delay = widget.popups
        .map((p) => p.delaySeconds)
        .where((s) => s > 0)
        .fold<int?>(null, (min, s) => min == null ? s : (s < min ? s : min));

    Future.delayed(Duration(seconds: delay ?? 1), () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  void _scheduleAnnouncementOffer() {
    final offer = widget.announcementOffer;
    if (offer == null) return;

    Future.delayed(Duration(seconds: offer.delaySeconds), () {
      if (!mounted || _announcementShown) return;
      _announcementShown = true;
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => AnnouncementOfferDialog(offer: offer),
      );
    });
  }

  void _close() {
    setState(() => _visible = false);
    _scheduleAnnouncementOffer();
  }

  Future<void> _openLink(AppPopup popup) async {
    if (popup.link.isEmpty) return;
    final uri = Uri.tryParse(popup.link);
    if (uri == null) return;
    await launchUrl(
      uri,
      mode: popup.openInNewTab
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible || widget.popups.isEmpty) {
      return const SizedBox.shrink();
    }

    final popup = widget.popups[_index.clamp(0, widget.popups.length - 1)];

    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTap: () => _openLink(popup),
                    child: CachedNetworkImage(
                      imageUrl: popup.imageUrl,
                      fit: BoxFit.contain,
                      width: MediaQuery.sizeOf(context).width * 0.85,
                      errorWidget: (_, __, ___) => const SizedBox(
                        width: 280,
                        height: 180,
                        child: Center(child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -12,
                  right: -12,
                  child: IconButton.filled(
                    onPressed: _close,
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ),
                if (widget.popups.length > 1)
                  Positioned(
                    bottom: -44,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _index > 0
                              ? () => setState(() => _index--)
                              : null,
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                        ),
                        ...List.generate(widget.popups.length, (i) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _index
                                  ? Colors.white
                                  : Colors.white38,
                            ),
                          );
                        }),
                        IconButton(
                          onPressed: _index < widget.popups.length - 1
                              ? () => setState(() => _index++)
                              : null,
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
