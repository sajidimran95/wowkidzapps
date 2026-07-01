import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// Store logo from API (`logo_url`) with icon fallback.
class StoreLogo extends StatelessWidget {
  const StoreLogo({
    super.key,
    this.size,
    this.width,
    this.height,
    this.borderRadius = 10,
    this.fallbackIcon = Icons.child_care,
    this.fallbackIconColor = Colors.white,
    this.fallbackBackground,
    this.fit = BoxFit.contain,
    this.padding = EdgeInsets.zero,
    this.decorative = true,
    this.showWhiteBackground = false,
  }) : assert(size != null || (width != null && height != null));

  /// Square logo — used on auth screens and small badges.
  const StoreLogo.square({
    super.key,
    required double size,
    double borderRadius = 10,
    IconData fallbackIcon = Icons.child_care,
    Color fallbackIconColor = Colors.white,
    Color? fallbackBackground,
    BoxFit fit = BoxFit.contain,
    EdgeInsets padding = EdgeInsets.zero,
  })  : size = size,
        width = null,
        height = null,
        borderRadius = borderRadius,
        fallbackIcon = fallbackIcon,
        fallbackIconColor = fallbackIconColor,
        fallbackBackground = fallbackBackground,
        fit = fit,
        padding = padding,
        decorative = true,
        showWhiteBackground = false;

  /// Wide navbar logo — full horizontal brand mark, no text beside it.
  const StoreLogo.navbar({
    super.key,
    this.width = 156,
    this.height = 40,
    this.fit = BoxFit.contain,
  })  : size = null,
        borderRadius = 0,
        fallbackIcon = Icons.child_care,
        fallbackIconColor = AppColors.primary,
        fallbackBackground = null,
        padding = EdgeInsets.zero,
        decorative = false,
        showWhiteBackground = false;

  /// Wide logo for login / registration headers.
  const StoreLogo.auth({
    super.key,
    this.width = 220,
    this.height = 56,
    this.fit = BoxFit.contain,
  })  : size = null,
        borderRadius = 0,
        fallbackIcon = Icons.child_care,
        fallbackIconColor = AppColors.primary,
        fallbackBackground = null,
        padding = EdgeInsets.zero,
        decorative = false,
        showWhiteBackground = false;

  final double? size;
  final double? width;
  final double? height;
  final double borderRadius;
  final IconData fallbackIcon;
  final Color fallbackIconColor;
  final Color? fallbackBackground;
  final BoxFit fit;
  final EdgeInsets padding;
  final bool decorative;
  final bool showWhiteBackground;

  double get _width => width ?? size!;
  double get _height => height ?? size!;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CatalogStore.instance,
      builder: (context, _) {
        final logoUrl = CatalogStore.instance.logoUrl;
        final hasNetworkLogo = logoUrl != null &&
            logoUrl.isNotEmpty &&
            !logoUrl.startsWith('data:image');

        final image = hasNetworkLogo
            ? CachedNetworkImage(
                imageUrl: logoUrl,
                fit: fit,
                placeholder: (_, _) => _fallbackIcon(_height * 0.55),
                errorWidget: (_, _, _) => _fallbackIcon(_height * 0.55),
              )
            : _fallbackIcon(_height * 0.55);

        if (showWhiteBackground) {
          return Container(
            width: _width,
            height: _height,
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: image,
          );
        }

        if (!decorative && hasNetworkLogo) {
          return SizedBox(
            width: _width,
            height: _height,
            child: image,
          );
        }

        if (!decorative && !hasNetworkLogo) {
          return Container(
            width: _width,
            height: _height,
            padding: padding,
            decoration: BoxDecoration(
              color: fallbackBackground ?? Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: _fallbackIcon(_height * 0.5),
          );
        }

        return Container(
          width: _width,
          height: _height,
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
          child: image,
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
