import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// Animated smiling girl for login welcome.
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
                child: _AnimatedGirl(
                  bounce: _bounceController.value,
                  wave: _waveController.value,
                  blink: blink,
                  size: widget.size * 0.82,
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

class _AnimatedGirl extends StatelessWidget {
  const _AnimatedGirl({
    required this.bounce,
    required this.wave,
    required this.blink,
    required this.size,
  });

  final double bounce;
  final double wave;
  final bool blink;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bounceOffset = math.sin(bounce * math.pi) * 16;
    final waveAngle = wave * 0.5;

    return Transform.translate(
      offset: Offset(0, -bounceOffset),
      child: SizedBox(
        width: size,
        height: size * 1.2,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.62,
                height: size * 0.42,
                decoration: BoxDecoration(
                  color: AppColors.categoryPink,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size * 0.22),
                    topRight: Radius.circular(size * 0.22),
                    bottomLeft: Radius.circular(size * 0.1),
                    bottomRight: Radius.circular(size * 0.1),
                  ),
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
              ),
            ),
            Positioned(
              bottom: size * 0.2,
              left: -size * 0.08,
              child: Transform.rotate(
                angle: -waveAngle,
                alignment: Alignment.topRight,
                child: _Arm(size: size),
              ),
            ),
            Positioned(
              bottom: size * 0.2,
              right: -size * 0.08,
              child: Transform.rotate(
                angle: waveAngle,
                alignment: Alignment.topLeft,
                child: _Arm(size: size),
              ),
            ),
            Positioned(
              bottom: size * 0.26,
              child: _GirlFace(
                size: size * 0.88,
                blink: blink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Arm extends StatelessWidget {
  const _Arm({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.2,
      height: size * 0.32,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD8B8),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
    );
  }
}

class _GirlFace extends StatelessWidget {
  const _GirlFace({required this.size, required this.blink});

  final double size;
  final bool blink;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GirlFacePainter(blink: blink),
    );
  }
}

class _GirlFacePainter extends CustomPainter {
  _GirlFacePainter({required this.blink});

  final bool blink;

  static const _skin = Color(0xFFFFD8B8);
  static const _hair = Color(0xFF4E342E);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    final facePaint = Paint()..color = _skin;
    canvas.drawCircle(center, radius, facePaint);

    final hairPaint = Paint()..color = _hair;

    final hairPath = Path()
      ..moveTo(center.dx - radius * 1.05, center.dy + radius * 0.3)
      ..quadraticBezierTo(
        center.dx - radius * 1.1,
        center.dy - radius * 0.2,
        center.dx - radius * 0.7,
        center.dy - radius * 1.1,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy - radius * 1.35,
        center.dx + radius * 0.7,
        center.dy - radius * 1.1,
      )
      ..quadraticBezierTo(
        center.dx + radius * 1.1,
        center.dy - radius * 0.2,
        center.dx + radius * 1.05,
        center.dy + radius * 0.3,
      )
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    canvas.drawCircle(
      Offset(center.dx - radius * 1.08, center.dy + radius * 0.05),
      radius * 0.28,
      hairPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 1.08, center.dy + radius * 0.05),
      radius * 0.28,
      hairPaint,
    );

    canvas.drawCircle(center, radius, facePaint);

    final bowPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 1.05),
      radius * 0.14,
      bowPaint,
    );
    canvas.drawCircle(
      Offset(center.dx - radius * 0.2, center.dy - radius * 1.02),
      radius * 0.1,
      bowPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.2, center.dy - radius * 1.02),
      radius * 0.1,
      bowPaint,
    );

    final cheekPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.22);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.52, center.dy + radius * 0.12),
      radius * 0.17,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.52, center.dy + radius * 0.12),
      radius * 0.17,
      cheekPaint,
    );

    final eyeY = center.dy - radius * 0.06;
    final eyeOffset = radius * 0.26;
    final eyePaint = Paint()..color = const Color(0xFF2D2D2D);

    if (blink) {
      final linePaint = Paint()
        ..color = const Color(0xFF2D2D2D)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center.dx - eyeOffset - 7, eyeY),
        Offset(center.dx - eyeOffset + 7, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(center.dx + eyeOffset - 7, eyeY),
        Offset(center.dx + eyeOffset + 7, eyeY),
        linePaint,
      );
    } else {
      canvas.drawCircle(
        Offset(center.dx - eyeOffset, eyeY),
        radius * 0.095,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + eyeOffset, eyeY),
        radius * 0.095,
        eyePaint,
      );
      final shine = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(center.dx - eyeOffset + 2, eyeY - 2),
        radius * 0.032,
        shine,
      );
      canvas.drawCircle(
        Offset(center.dx + eyeOffset + 2, eyeY - 2),
        radius * 0.032,
        shine,
      );
    }

    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.24),
        width: radius * 1.0,
        height: radius * 0.7,
      ),
      math.pi * 0.1,
      math.pi * 0.8,
    );
    final smilePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _GirlFacePainter oldDelegate) {
    return oldDelegate.blink != blink;
  }
}
