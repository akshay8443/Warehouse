

import 'package:flutter/material.dart';

class GlitterBorderPainter extends CustomPainter {
  final double progress;
  GlitterBorderPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      borderPaint,
    );

    final Paint lightPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final double totalPerimeter = 2 * (size.width + size.height);
    final double glitterPosition = progress * totalPerimeter;
    Offset glitterOffset;
    if (glitterPosition <= size.width) {
      glitterOffset = Offset(glitterPosition, 0);
    } else if (glitterPosition <= size.width + size.height) {
      glitterOffset = Offset(size.width, glitterPosition - size.width);
    } else if (glitterPosition <= 2 * size.width + size.height) {
      glitterOffset = Offset(2 * size.width + size.height - glitterPosition, size.height);
    } else {
      glitterOffset = Offset(0, totalPerimeter - glitterPosition);
    }
    canvas.drawCircle(glitterOffset, 5, lightPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}