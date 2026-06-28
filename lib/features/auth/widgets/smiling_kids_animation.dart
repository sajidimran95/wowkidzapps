import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// Animated smiling kids scene for login welcome.
class SmilingKidsAnimation extends StatefulWidget {
  const SmilingKidsAnimation({super.key, this.size = 220});

  final double size;

  @override
  State<SmilingKidsAnimation> createState() => _SmilingKidsAnimationState();
}

class _SmilingKidsAnimationState extends State<SmilingKidsAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _entryController;
  late final AnimationController _waveController;
  late final AnimationController _sparkleController;
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _entryController.dispose();
    _waveController.dispose();
    _sparkleController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bounceController,
        _entryController,
        _waveController,
        _sparkleController,
        _blinkController,
      ]),
      builder: (context, _) {
        final entry = Curves.elasticOut.transform(_entryController.value);
        final blink = _blinkController.value < 0.08;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 6; i++)
                _Sparkle(
                  angle: i * math.pi / 3 + _sparkleController.value * math.pi * 2,
                  radius: widget.size * 0.46,
                  opacity: 0.35 +
                      0.45 * math.sin(_sparkleController.value * math.pi * 2 + i),
                ),
              Transform.scale(
                scale: entry,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _AnimatedKid(
                      bounce: _bounceController.value,
                      wave: _waveController.value,
                      blink: blink,
                      skin: const Color(0xFFFFD8B8),
                      hair: const Color(0xFF5D4037),
                      shirt: AppColors.categoryPink,
                      delay: 0,
                      size: widget.size * 0.34,
                      waveLeft: true,
                    ),
                    const SizedBox(width: 6),
                    _AnimatedKid(
                      bounce: _bounceController.value,
                      wave: _waveController.value,
                      blink: blink,
                      skin: const Color(0xFFFFE0BD),
                      hair: const Color(0xFF212121),
                      shirt: AppColors.categoryBlue,
                      delay: 0.15,
                      size: widget.size * 0.42,
                      waveLeft: false,
                      center: true,
                    ),
                    const SizedBox(width: 6),
                    _AnimatedKid(
                      bounce: _bounceController.value,
                      wave: _waveController.value,
                      blink: blink,
                      skin: const Color(0xFFFFCCAA),
                      hair: const Color(0xFFE65100),
                      shirt: AppColors.categoryYellow,
                      delay: 0.3,
                      size: widget.size * 0.34,
                      waveLeft: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({
    required this.angle,
    required this.radius,
    required this.opacity,
  });

  final double angle;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Icon(
          Icons.star_rounded,
          size: 16,
          color: AppColors.primary.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _AnimatedKid extends StatelessWidget {
  const _AnimatedKid({
    required this.bounce,
    required this.wave,
    required this.blink,
    required this.skin,
    required this.hair,
    required this.shirt,
    required this.delay,
    required this.size,
    required this.waveLeft,
    this.center = false,
  });

  final double bounce;
  final double wave;
  final bool blink;
  final Color skin;
  final Color hair;
  final Color shirt;
  final double delay;
  final double size;
  final bool waveLeft;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final bounceOffset = math.sin((bounce + delay) * math.pi) * (center ? 14 : 10);
    final waveAngle = (wave + delay) * 0.45;

    return Transform.translate(
      offset: Offset(0, -bounceOffset),
      child: SizedBox(
        width: size,
        height: size * 1.15,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.72,
                height: size * 0.38,
                decoration: BoxDecoration(
                  color: shirt,
                  borderRadius: BorderRadius.circular(size * 0.18),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: size * 0.22,
              left: waveLeft ? -size * 0.02 : null,
              right: waveLeft ? null : -size * 0.02,
              child: Transform.rotate(
                angle: waveLeft ? -waveAngle : waveAngle,
                alignment: waveLeft ? Alignment.topRight : Alignment.topLeft,
                child: Container(
                  width: size * 0.22,
                  height: size * 0.34,
                  decoration: BoxDecoration(
                    color: skin,
                    borderRadius: BorderRadius.circular(size * 0.11),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size * 0.28,
              child: _KidFace(
                size: size * 0.78,
                skin: skin,
                hair: hair,
                blink: blink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KidFace extends StatelessWidget {
  const _KidFace({
    required this.size,
    required this.skin,
    required this.hair,
    required this.blink,
  });

  final double size;
  final Color skin;
  final Color hair;
  final bool blink;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _KidFacePainter(skin: skin, hair: hair, blink: blink),
    );
  }
}

class _KidFacePainter extends CustomPainter {
  _KidFacePainter({
    required this.skin,
    required this.hair,
    required this.blink,
  });

  final Color skin;
  final Color hair;
  final bool blink;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    final facePaint = Paint()..color = skin;
    canvas.drawCircle(center, radius, facePaint);

    final hairPath = Path()
      ..moveTo(center.dx - radius, center.dy)
      ..quadraticBezierTo(
        center.dx - radius * 0.9,
        center.dy - radius * 1.35,
        center.dx,
        center.dy - radius * 1.05,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.9,
        center.dy - radius * 1.35,
        center.dx + radius,
        center.dy,
      )
      ..close();
    canvas.drawPath(hairPath, Paint()..color = hair);

    canvas.drawCircle(center, radius, facePaint);

    final cheekPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.55, center.dy + radius * 0.15),
      radius * 0.18,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.55, center.dy + radius * 0.15),
      radius * 0.18,
      cheekPaint,
    );

    final eyeY = center.dy - radius * 0.08;
    final eyeOffset = radius * 0.28;
    final eyePaint = Paint()..color = const Color(0xFF2D2D2D);

    if (blink) {
      final linePaint = Paint()
        ..color = const Color(0xFF2D2D2D)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center.dx - eyeOffset - 6, eyeY),
        Offset(center.dx - eyeOffset + 6, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(center.dx + eyeOffset - 6, eyeY),
        Offset(center.dx + eyeOffset + 6, eyeY),
        linePaint,
      );
    } else {
      canvas.drawCircle(Offset(center.dx - eyeOffset, eyeY), radius * 0.09, eyePaint);
      canvas.drawCircle(Offset(center.dx + eyeOffset, eyeY), radius * 0.09, eyePaint);
      final shine = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(center.dx - eyeOffset + 2, eyeY - 2),
        radius * 0.03,
        shine,
      );
      canvas.drawCircle(
        Offset(center.dx + eyeOffset + 2, eyeY - 2),
        radius * 0.03,
        shine,
      );
    }

    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.22),
        width: radius * 0.95,
        height: radius * 0.65,
      ),
      math.pi * 0.12,
      math.pi * 0.76,
    );
    final smilePaint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _KidFacePainter oldDelegate) {
    return oldDelegate.blink != blink;
  }
}
