import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// Store logo from API (`logo_url`) with icon fallback.
class StoreLogo extends StatelessWidget {
  const StoreLogo({
    super.key,
    required this.size,
    this.borderRadius = 10,
    this.fallbackIcon = Icons.child_care,
    this.fallbackIconColor = Colors.white,
    this.fallbackBackground,
    this.fit = BoxFit.contain,
    this.padding = EdgeInsets.zero,
  });

  final double size;
  final double borderRadius;
  final IconData fallbackIcon;
  final Color fallbackIconColor;
  final Color? fallbackBackground;
  final BoxFit fit;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CatalogStore.instance,
      builder: (context, _) {
        final logoUrl = CatalogStore.instance.logoUrl;
        final hasNetworkLogo = logoUrl != null &&
            logoUrl.isNotEmpty &&
            !logoUrl.startsWith('data:image');

        return Container(
          width: size,
          height: size,
          padding: padding,
          decoration: BoxDecoration(
            gradient: hasNetworkLogo
                ? null
                : const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
            color: hasNetworkLogo ? Colors.white : fallbackBackground,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasNetworkLogo
              ? CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: fit,
                  placeholder: (_, _) => _fallbackIcon(size * 0.55),
                  errorWidget: (_, _, _) => _fallbackIcon(size * 0.55),
                )
              : _fallbackIcon(size * 0.55),
        );
      },
    );
  }

  Widget _fallbackIcon(double iconSize) {
    return Center(
      child: Icon(
        fallbackIcon,
        color: fallbackIconColor,
        size: iconSize,
      ),
    );
  }
}
