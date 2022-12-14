import 'package:flutter/material.dart';

class PointPainter extends CustomPainter {
  final double x;
  final double y;
  final Color color;
  final Color colorRound;

  PointPainter({required this.x, required this.y, required this.color, required this.colorRound});

  @override
  void paint(Canvas canvas, Size size) {
    var paintInside = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    var paintOutside = Paint()
      ..color = colorRound
      ..style = PaintingStyle.fill;

    canvas
      ..drawCircle(Offset(x, y), 20, paintOutside)
      ..drawCircle(Offset(x, y), 16, paintInside);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
