import 'package:Lisofy/resources/app_theme.dart';
import 'package:flutter/material.dart';

class DownArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  DownArrowPainter({required this.color, this.strokeWidth = 5.0});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      ..moveTo(size.width / 2, 0) // Start at the top center
      ..lineTo(size.width / 2, size.height - 10) // Draw the vertical line
      ..moveTo(size.width / 4, size.height - 20) // Start left arrowhead
      ..lineTo(size.width / 2, size.height) // Downward tip
      ..lineTo(3 * size.width / 4, size.height - 20); // Right arrowhead

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DownArrow extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const DownArrow({
    super.key,
    this.width = 50,
    this.height = 100,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: DownArrowPainter(color: color),
    );
  }
}
