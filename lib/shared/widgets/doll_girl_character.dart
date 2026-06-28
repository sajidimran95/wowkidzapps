import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// Default display height used in cart + login for the same girl size.
const double kDollGirlDisplayHeight = 155;

/// 3D doll-style girl matching reference face: curly hair, big eyes, ethnic outfit.
class DollGirlCharacter extends StatefulWidget {
  const DollGirlCharacter({super.key, this.height = kDollGirlDisplayHeight});

  final double height;

  @override
  State<DollGirlCharacter> createState() => _DollGirlCharacterState();
}

class _DollGirlCharacterState extends State<DollGirlCharacter>
    with TickerProviderStateMixin {
  late final AnimationController _bobController;
  late final AnimationController _swayController;
  late final AnimationController _blinkController;
  late final AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
  }

  @override
  void dispose() {
    _bobController.dispose();
    _swayController.dispose();
    _blinkController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bobController,
        _swayController,
        _blinkController,
        _entryController,
      ]),
      builder: (context, _) {
        final bob = math.sin(_bobController.value * math.pi) * 7;
        final sway = (_swayController.value - 0.5) * 0.05;
        final blink = _blinkController.value < 0.075;
        final entry = Curves.elasticOut.transform(_entryController.value);
        final smile = 0.85 + math.sin(_bobController.value * math.pi) * 0.15;

        return Transform.scale(
          scale: entry,
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0022)
              ..rotateY(sway),
            child: Transform.translate(
              offset: Offset(0, -bob),
              child: SizedBox(
                width: widget.height * 0.72,
                height: widget.height,
                child: CustomPaint(
                  painter: _DollGirlCharacterPainter(
                    blink: blink,
                    smileAmount: smile,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DollGirlCharacterPainter extends CustomPainter {
  _DollGirlCharacterPainter({
    required this.blink,
    required this.smileAmount,
  });

  final bool blink;
  final double smileAmount;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    _shadow(canvas, Offset(cx, h * 0.97), w * 0.26);
    _drawDupatta(canvas, size);
    _drawSalwar(canvas, size);
    _drawKameez(canvas, size);
    _drawArms(canvas, size);
    _drawShoes(canvas, size);
    _drawNeck(canvas, size);
    final faceCenter = Offset(cx, h * 0.34);
    final faceRadius = w * 0.34;
    _drawFaceSkin(canvas, faceCenter, faceRadius);
    _drawCurlyHair(canvas, faceCenter, faceRadius);
    _drawFaceFeatures(canvas, faceCenter, faceRadius);
  }

  void _shadow(Canvas canvas, Offset c, double r) {
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 2.4, height: r * 0.5),
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          r,
          [Colors.black.withValues(alpha: 0.2), Colors.transparent],
        ),
    );
  }

  void _drawDupatta(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.2, size.height * 0.42),
        Offset(size.width * 0.8, size.height * 0.75),
        [
          const Color(0xFFFFB6D5),
          AppColors.primary.withValues(alpha: 0.85),
          const Color(0xFFE91E8C),
        ],
        const [0.0, 0.5, 1.0],
      );

    final left = Path()
      ..moveTo(size.width * 0.32, size.height * 0.44)
      ..quadraticBezierTo(
        size.width * 0.08,
        size.height * 0.55,
        size.width * 0.12,
        size.height * 0.78,
      )
      ..lineTo(size.width * 0.22, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.58,
        size.width * 0.34,
        size.height * 0.5,
      )
      ..close();

    final right = Path()
      ..moveTo(size.width * 0.68, size.height * 0.44)
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.55,
        size.width * 0.88,
        size.height * 0.78,
      )
      ..lineTo(size.width * 0.78, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.58,
        size.width * 0.66,
        size.height * 0.5,
      )
      ..close();

    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
  }

  void _drawSalwar(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.68, size.width * 0.44, size.height * 0.22),
      Radius.circular(size.width * 0.08),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width * 0.3, size.height * 0.68),
          Offset(size.width * 0.7, size.height * 0.9),
          [const Color(0xFFFFCCE5), const Color(0xFFFF8EC7), AppColors.primary],
          const [0.0, 0.45, 1.0],
        ),
    );
    _ankleBorder(canvas, Offset(size.width * 0.36, size.height * 0.88), size.width * 0.1);
    _ankleBorder(canvas, Offset(size.width * 0.64, size.height * 0.88), size.width * 0.1);
  }

  void _ankleBorder(Canvas canvas, Offset c, double w) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: w, height: w * 0.35),
        Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  void _drawKameez(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.48)
      ..lineTo(size.width * 0.76, size.height * 0.48)
      ..lineTo(size.width * 0.72, size.height * 0.72)
      ..lineTo(size.width * 0.28, size.height * 0.72)
      ..close();

    canvas.drawShadow(path, Colors.black38, 6, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width * 0.5, size.height * 0.48),
          Offset(size.width * 0.5, size.height * 0.72),
          [const Color(0xFFFFF8F0), const Color(0xFFFFF0E6), const Color(0xFFF5E6D8)],
          const [0.0, 0.5, 1.0],
        ),
    );

    _embroidery(canvas, size);
  }

  void _embroidery(Canvas canvas, Size size) {
    final pink = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final neckCenter = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawArc(
      Rect.fromCenter(center: neckCenter, width: size.width * 0.22, height: size.height * 0.06),
      math.pi,
      math.pi,
      false,
      pink,
    );

    for (var i = -2; i <= 2; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.5 + i * 8.0, size.height * 0.52),
        2.2,
        Paint()..color = AppColors.primary.withValues(alpha: 0.6),
      );
    }

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.53),
      Offset(size.width * 0.5, size.height * 0.64),
      pink,
    );

    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.7),
      Offset(size.width * 0.72, size.height * 0.7),
      pink..strokeWidth = 2,
    );
  }

  void _drawArms(Canvas canvas, Size size) {
    void arm(double x, bool left, bool onHip) {
      final skin = Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, size.height * 0.5),
          Offset(x, size.height * 0.66),
          [const Color(0xFFFFF0E6), const Color(0xFFE8C4A8)],
        )
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(x, size.height * 0.5);
      if (onHip) {
        path.cubicTo(
          x + (left ? -14 : 14),
          size.height * 0.58,
          x + (left ? 6 : -6),
          size.height * 0.64,
          x + (left ? 10 : -10),
          size.height * 0.62,
        );
      } else {
        path.quadraticBezierTo(
          x + (left ? -8 : 8),
          size.height * 0.6,
          x + (left ? -4 : 4),
          size.height * 0.66,
        );
      }
      canvas.drawPath(path, skin);
    }

    arm(size.width * 0.24, true, true);
    arm(size.width * 0.76, false, false);
  }

  void _drawShoes(Canvas canvas, Size size) {
    void shoe(double x) {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, size.height * 0.94),
          width: size.width * 0.14,
          height: size.height * 0.045,
        ),
        const Radius.circular(10),
      );
      canvas.drawRRect(
        r,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(x - 10, size.height * 0.93),
            Offset(x + 10, size.height * 0.96),
            [const Color(0xFFFFB6D5), AppColors.primary],
          ),
      );
      canvas.drawCircle(
        Offset(x - 4, size.height * 0.935),
        2,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }

    shoe(size.width * 0.38);
    shoe(size.width * 0.62);
  }

  void _drawNeck(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.44),
          width: size.width * 0.1,
          height: size.height * 0.05,
        ),
        Radius.circular(6),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width * 0.46, size.height * 0.42),
          Offset(size.width * 0.54, size.height * 0.46),
          [const Color(0xFFFFF0E6), const Color(0xFFE8C4A8)],
        ),
    );
  }

  void _drawFaceSkin(Canvas canvas, Offset center, double radius) {
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      Colors.black38,
      8,
      true,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(center.dx - radius * 0.3, center.dy - radius * 0.35),
          radius * 1.3,
          [
            const Color(0xFFFFF5EE),
            const Color(0xFFFFE8D6),
            const Color(0xFFF0D0B0),
            const Color(0xFFE0B898),
          ],
          const [0.0, 0.4, 0.75, 1.0],
        ),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.18, center.dy - radius * 0.28),
        width: radius * 0.55,
        height: radius * 0.3,
      ),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(center.dx - radius * 0.25, center.dy - radius * 0.32),
          radius * 0.35,
          [Colors.white.withValues(alpha: 0.5), Colors.transparent],
        ),
    );
  }

  void _drawFaceFeatures(Canvas canvas, Offset center, double radius) {
    final blush = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        radius * 0.22,
        [const Color(0xFFFFB6C8).withValues(alpha: 0.55), Colors.transparent],
      );
    canvas.drawCircle(
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.08),
      radius * 0.18,
      blush,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.08),
      radius * 0.18,
      blush,
    );

    _drawBrows(canvas, center, radius);
    _drawEyes(canvas, center, radius);
    _drawNose(canvas, center, radius);
    _drawSmile(canvas, center, radius);
  }

  void _drawBrows(Canvas canvas, Offset center, double radius) {
    final brow = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final y = center.dy - radius * 0.2;
    final browW = radius * 0.52;
    final browH = radius * 0.14;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx - radius * 0.28, y), width: browW, height: browH),
      math.pi * 1.1,
      math.pi * 0.65,
      false,
      brow,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx + radius * 0.28, y), width: browW, height: browH),
      math.pi * 1.25,
      math.pi * 0.65,
      false,
      brow,
    );
  }

  void _drawEyes(Canvas canvas, Offset center, double radius) {
    final eyeY = center.dy - radius * 0.02;
    final eyeX = radius * 0.3;

    if (blink) {
      final lidW = radius * 0.34;
      final lid = Paint()
        ..color = const Color(0xFF4E342E)
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center.dx - eyeX - lidW, eyeY),
        Offset(center.dx - eyeX + lidW, eyeY),
        lid,
      );
      canvas.drawLine(
        Offset(center.dx + eyeX - lidW, eyeY),
        Offset(center.dx + eyeX + lidW, eyeY),
        lid,
      );
      return;
    }

    void eye(Offset c) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: radius * 0.36, height: radius * 0.44),
        Paint()..color = Colors.white,
      );
      canvas.drawOval(
        Rect.fromCenter(center: c.translate(0, 2), width: radius * 0.28, height: radius * 0.36),
        Paint()
          ..shader = ui.Gradient.radial(
            c.translate(-2, -3),
            radius * 0.22,
            [const Color(0xFF6D4C41), const Color(0xFF3E2723)],
          ),
      );
      canvas.drawCircle(c.translate(-4, -5), radius * 0.06, Paint()..color = Colors.white);
      canvas.drawCircle(c.translate(5, 4), radius * 0.028, Paint()..color = Colors.white70);

      final lash = Paint()
        ..color = const Color(0xFF2D1B14)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCenter(center: c.translate(0, -6), width: radius * 0.38, height: radius * 0.22),
        math.pi * 1.05,
        math.pi * 0.75,
        false,
        lash,
      );
      for (var i = -2; i <= 2; i++) {
        canvas.drawLine(
          c.translate(i * 4.0, -radius * 0.2),
          c.translate(i * 5.0 - 1, -radius * 0.28),
          lash..strokeWidth = 1.5,
        );
      }
    }

    eye(Offset(center.dx - eyeX, eyeY));
    eye(Offset(center.dx + eyeX, eyeY));
  }

  void _drawNose(Canvas canvas, Offset center, double radius) {
    final noseTip = Offset(center.dx, center.dy + radius * 0.08);
    canvas.drawCircle(
      noseTip,
      radius * 0.055,
      Paint()..color = const Color(0xFFC9956E),
    );
    final noseLine = Paint()
      ..color = const Color(0xFFB8845A)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.02),
      noseTip,
      noseLine,
    );
  }

  void _drawSmile(Canvas canvas, Offset center, double radius) {
    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.26),
        width: radius * 0.42 * smileAmount,
        height: radius * 0.22 * smileAmount,
      ),
      math.pi * 0.2,
      math.pi * 0.6,
    );
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFFD81B60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.3),
        width: radius * 0.1,
        height: radius * 0.05,
      ),
      Paint()..color = AppColors.primary.withValues(alpha: 0.25),
    );
  }

  void _drawCurlyHair(Canvas canvas, Offset center, double radius) {
    final hair = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx, center.dy - radius * 1.5),
        Offset(center.dx, center.dy + radius * 0.3),
        [const Color(0xFF6D4C41), const Color(0xFF4E342E), const Color(0xFF3E2723)],
        const [0.0, 0.45, 1.0],
      );

    final top = Path()
      ..moveTo(center.dx - radius * 1.02, center.dy - radius * 0.05)
      ..quadraticBezierTo(
        center.dx - radius * 1.1,
        center.dy - radius * 0.65,
        center.dx - radius * 0.42,
        center.dy - radius * 1.1,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy - radius * 1.32,
        center.dx + radius * 0.42,
        center.dy - radius * 1.1,
      )
      ..quadraticBezierTo(
        center.dx + radius * 1.1,
        center.dy - radius * 0.65,
        center.dx + radius * 1.02,
        center.dy - radius * 0.05,
      )
      ..close();
    canvas.drawPath(top, hair);

    final curlOffsets = [
      Offset(center.dx - radius * 1.05, center.dy - radius * 0.1),
      Offset(center.dx - radius * 1.12, center.dy + radius * 0.25),
      Offset(center.dx - radius * 0.95, center.dy + radius * 0.45),
      Offset(center.dx + radius * 1.05, center.dy - radius * 0.1),
      Offset(center.dx + radius * 1.12, center.dy + radius * 0.25),
      Offset(center.dx + radius * 0.95, center.dy + radius * 0.45),
      Offset(center.dx - radius * 0.5, center.dy - radius * 1.15),
      Offset(center.dx, center.dy - radius * 1.28),
      Offset(center.dx + radius * 0.5, center.dy - radius * 1.15),
    ];
    for (final o in curlOffsets) {
      canvas.drawCircle(o, radius * 0.2, hair);
      canvas.drawCircle(
        o.translate(-3, -3),
        radius * 0.08,
        Paint()..color = Colors.white.withValues(alpha: 0.1),
      );
    }

    void clip(Offset c) {
      canvas.drawCircle(c, radius * 0.09, Paint()..color = AppColors.primary);
      canvas.drawCircle(c, radius * 0.05, Paint()..color = const Color(0xFFFFB6D5));
    }

    clip(Offset(center.dx - radius * 0.75, center.dy - radius * 0.05));
    clip(Offset(center.dx + radius * 0.75, center.dy - radius * 0.05));
  }

  @override
  bool shouldRepaint(covariant _DollGirlCharacterPainter old) =>
      old.blink != blink || old.smileAmount != smileAmount;
}
