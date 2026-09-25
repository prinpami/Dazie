import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CompassDial extends StatelessWidget {
  const CompassDial({super.key, required this.bearingDegrees});

  final double bearingDegrees;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 284,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _CompassPainter())),
          const Positioned(top: 13, child: _DirectionLabel('N')),
          const Positioned(right: 14, child: _DirectionLabel('E')),
          const Positioned(bottom: 13, child: _DirectionLabel('S')),
          const Positioned(left: 14, child: _DirectionLabel('W')),
          Transform.rotate(
            angle: bearingDegrees * math.pi / 180,
            child: const Icon(
              Icons.navigation_rounded,
              size: 104,
              color: DazieColors.tangerineOrange,
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DazieColors.white,
              border: Border.all(color: DazieColors.darkIndigo, width: 4),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionLabel extends StatelessWidget {
  const _DirectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: DazieColors.mutedText,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 2;
    canvas.drawCircle(center, radius, Paint()..color = DazieColors.surface);

    final ringPaint = Paint()
      ..color = DazieColors.white.withValues(alpha: 0.23)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 23, ringPaint);
    canvas.drawCircle(center, radius - 63, ringPaint);

    final tickPaint = Paint()
      ..color = DazieColors.white.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var tick = 0; tick < 32; tick++) {
      final angle = tick * math.pi / 16 - math.pi / 2;
      final major = tick % 4 == 0;
      final inner = radius - (major ? 17 : 11);
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) => false;
}
