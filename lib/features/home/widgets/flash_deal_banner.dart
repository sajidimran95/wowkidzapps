import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/shared/utils/bangladesh_time.dart';

DateTime? parseSectionEndDate(String? raw) => parseApiInstant(raw);

/// Latest flash-deal end among API date and product deal dates.
DateTime? resolveFlashDealEndDate(String? apiDate, List<Product> products) {
  final candidates = <DateTime>[];
  final fromApi = parseSectionEndDate(apiDate);
  if (fromApi != null) candidates.add(fromApi);

  for (final product in products) {
    final end = parseSectionEndDate(product.dealEndDate);
    if (end != null) candidates.add(end);
  }

  if (candidates.isEmpty) return null;
  candidates.sort();
  return candidates.last;
}

class FlashDealBanner extends StatefulWidget {
  const FlashDealBanner({
    super.key,
    required this.title,
    this.endDate,
    this.onViewAll,
  });

  final String title;
  final DateTime? endDate;
  final VoidCallback? onViewAll;

  @override
  State<FlashDealBanner> createState() => _FlashDealBannerState();
}

class _FlashDealBannerState extends State<FlashDealBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _updateRemaining();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  @override
  void didUpdateWidget(covariant FlashDealBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endDate != widget.endDate) {
      _updateRemaining();
    }
  }

  void _updateRemaining() {
    final end = widget.endDate;
    if (end == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }
    final diff = end.difference(utcNow());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasCountdown = widget.endDate != null && _remaining > Duration.zero;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment(-1 + _pulseController.value * 0.4, -1),
                end: Alignment(1 - _pulseController.value * 0.4, 1),
                colors: const [
                  Color(0xFFFF4757),
                  Color(0xFFFF6B35),
                  Color(0xFFE91E8C),
                  Color(0xFF7C4DFF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.flashDeal.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            Positioned(
              right: -12,
              top: -12,
              child: Icon(
                Icons.bolt_rounded,
                size: 88,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.92, end: 1.08).animate(
                          CurvedAnimation(
                            parent: _pulseController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.flash_on_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FLASH DEAL',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.onViewAll != null)
                        TextButton(
                          onPressed: widget.onViewAll,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('View All'),
                              SizedBox(width: 2),
                              Icon(Icons.arrow_forward_ios, size: 12),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (hasCountdown)
                    _CountdownRow(remaining: _remaining)
                  else
                    Text(
                      'Limited time offers — grab them fast!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownRow extends StatelessWidget {
  const _CountdownRow({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Row(
      children: [
        _CountdownUnit(value: days, label: 'Days'),
        _separator(),
        _CountdownUnit(value: hours, label: 'Hrs'),
        _separator(),
        _CountdownUnit(value: minutes, label: 'Min'),
        _separator(),
        _CountdownUnit(value: seconds, label: 'Sec'),
      ],
    );
  }

  Widget _separator() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          ':',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      );
}

class _CountdownUnit extends StatelessWidget {
  const _CountdownUnit({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
