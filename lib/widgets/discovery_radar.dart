import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DiscoveryRadar extends StatelessWidget {
  const DiscoveryRadar({super.key, required this.onPeerTap});

  final ValueChanged<int> onPeerTap;

  static const _markers = <Offset>[
    Offset(0.21, 0.37),
    Offset(0.75, 0.27),
    Offset(0.77, 0.69),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _RadarPainter())),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: DazieColors.tangerineOrange,
              shape: BoxShape.circle,
              border: Border.all(color: DazieColors.white, width: 3),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/Discovery.png',
                width: 24,
                height: 24,
                semanticLabel: 'Your position',
              ),
            ),
          ),
          for (var index = 0; index < _markers.length; index++)
            Positioned(
              left: 280 * _markers[index].dx - 12,
              top: 280 * _markers[index].dy - 12,
              child: Semantics(
                button: true,
                label: 'Select nearby demo friend ${index + 1}',
                child: GestureDetector(
                  onTap: () => onPeerTap(index),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: DazieColors.electricViolet,
                      shape: BoxShape.circle,
                      border: Border.all(color: DazieColors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x55000000), blurRadius: 5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final ringPaint = Paint()
      ..color = DazieColors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var ring = 1; ring <= 4; ring++) {
      canvas.drawCircle(center, radius * ring / 4, ringPaint);
    }

    final axisPaint = Paint()
      ..color = DazieColors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      axisPaint,
    );
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      axisPaint,
    );

    final sweepPaint = Paint()
      ..color = DazieColors.electricViolet.withValues(alpha: 0.19)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.82,
      math.pi * 0.53,
      true,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => false;
}
