import 'dart:math';

import 'package:flutter/material.dart';

class OrderSuccessFireworks extends StatefulWidget {
  const OrderSuccessFireworks({super.key});

  @override
  State<OrderSuccessFireworks> createState() => _OrderSuccessFireworksState();
}

class _OrderSuccessFireworksState extends State<OrderSuccessFireworks>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _random = Random();
  final _bursts = <_FireworkBurst>[];

  static const _colors = [
    Color(0xFFFFD54F),
    Color(0xFFFF7043),
    Color(0xFF81C784),
    Color(0xFF64B5F6),
    Color(0xFFBA68C8),
    Color(0xFFFF4081),
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();

    _spawnBurst(0.12);
    _spawnBurst(0.35);
    _spawnBurst(0.58);
    _spawnBurst(0.78);
  }

  void _spawnBurst(double phase) {
    _bursts.add(
      _FireworkBurst(
        origin: Offset(
          0.15 + _random.nextDouble() * 0.7,
          0.08 + _random.nextDouble() * 0.28,
        ),
        start: phase,
        color: _colors[_random.nextInt(_colors.length)],
        particleCount: 18 + _random.nextInt(10),
        seed: _random.nextInt(99999),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _FireworksPainter(
              progress: _controller.value,
              bursts: _bursts,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _FireworkBurst {
  const _FireworkBurst({
    required this.origin,
    required this.start,
    required this.color,
    required this.particleCount,
    required this.seed,
  });

  final Offset origin;
  final double start;
  final Color color;
  final int particleCount;
  final int seed;
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter({
    required this.progress,
    required this.bursts,
  });

  final double progress;
  final List<_FireworkBurst> bursts;

  @override
  void paint(Canvas canvas, Size size) {
    for (final burst in bursts) {
      final local = ((progress - burst.start) % 1).clamp(0.0, 1.0);
      if (local <= 0 || local > 0.85) continue;

      final origin = Offset(
        burst.origin.dx * size.width,
        burst.origin.dy * size.height,
      );
      final random = Random(burst.seed);

      for (var i = 0; i < burst.particleCount; i++) {
        final angle = (i / burst.particleCount) * pi * 2 + random.nextDouble();
        final speed = 40 + random.nextDouble() * 70;
        final gravity = 90.0;
        final t = local * 1.4;
        final dx = cos(angle) * speed * t;
        final dy = sin(angle) * speed * t + gravity * t * t;
        final opacity = (1 - local).clamp(0.0, 1.0);
        final radius = 2.2 + random.nextDouble() * 2.2;

        final paint = Paint()
          ..color = burst.color.withValues(alpha: opacity * 0.95)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(origin + Offset(dx, dy), radius, paint);

        if (i.isEven) {
          final sparkPaint = Paint()
            ..color = Colors.white.withValues(alpha: opacity * 0.55)
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(
            origin + Offset(dx, dy),
            origin + Offset(dx - cos(angle) * 6, dy - sin(angle) * 6),
            sparkPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
