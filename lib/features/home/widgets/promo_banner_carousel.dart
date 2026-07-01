import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/data/models/promo_banner.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({
    super.key,
    required this.banners,
    this.sideBanners = const [],
  });

  final List<PromoBanner> banners;
  final List<PromoBanner> sideBanners;

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant PromoBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _timer?.cancel();
      _startTimer();
    }
  }

  void _startTimer() {
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients || widget.banners.isEmpty) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty && widget.sideBanners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          if (widget.banners.isNotEmpty) ...[
            SizedBox(
              height: 168,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: widget.banners.length,
                itemBuilder: (_, index) => _SliderCard(
                  banner: widget.banners[index],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? widget.banners[index].gradient.first
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (widget.sideBanners.isNotEmpty)
            Row(
              children: [
                for (var i = 0; i < widget.sideBanners.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _SideBannerCard(
                      banner: widget.sideBanners[i],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        banner.imageUrl != null && banner.imageUrl!.trim().isNotEmpty;
    final showText = banner.title.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: banner.gradient.first.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _BannerImage(banner: banner),
          if (!hasImage) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            if (showText)
              Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (banner.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      banner.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SideBannerCard extends StatelessWidget {
  const _SideBannerCard({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        banner.imageUrl != null && banner.imageUrl!.trim().isNotEmpty;
    final showText = banner.title.trim().isNotEmpty;

    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: banner.gradient.first.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _BannerImage(banner: banner),
            if (!hasImage) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              if (showText)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      banner.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: banner.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, _) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: banner.gradient),
          ),
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, _, _) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: banner.gradient),
          ),
          child: Icon(
            banner.icon,
            size: 40,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: banner.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            banner.icon,
            size: 48,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}
