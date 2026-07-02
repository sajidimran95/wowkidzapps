import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/data/models/promo_banner.dart';
import 'package:url_launcher/url_launcher.dart';

/// First banner full width on top; 2nd and 3rd banners in a row below.
class ThreeColumnBannerRow extends StatelessWidget {
  const ThreeColumnBannerRow({
    super.key,
    required this.banners,
  });

  final List<PromoBanner> banners;

  Future<void> _openLink(String? link) async {
    final raw = link?.trim();
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    final first = banners.first;
    final bottom = banners.length > 1 ? banners.sublist(1).take(2).toList() : <PromoBanner>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          _BannerTile(
            banner: first,
            height: 148,
            onTap: () => _openLink(first.link),
          ),
          if (bottom.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < bottom.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _BannerTile(
                      banner: bottom[i],
                      height: 96,
                      onTap: () => _openLink(bottom[i].link),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({
    required this.banner,
    required this.height,
    required this.onTap,
  });

  final PromoBanner banner;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = banner.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: banner.gradient.first.withValues(alpha: 0.16),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: banner.gradient),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: banner.gradient),
                  ),
                ),
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: banner.gradient),
                ),
              ),
            if (banner.title.trim().isNotEmpty)
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  banner.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
