// Painter and shape models
import 'package:flutter/material.dart';


enum Tool { pen, circle }

abstract class Shape {
  void draw(Canvas canvas, Size size);
}

class FreehandShape extends Shape {
  List<Offset> points;
  Color color;
  double strokeWidth;

  FreehandShape({required this.points, required this.color, required this.strokeWidth});

  @override
  void draw(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }
}

class CircleShape extends Shape {
  Offset center;
  double radius;
  Color color;
  double strokeWidth;

  CircleShape({required this.center, required this.radius, required this.color, required this.strokeWidth});

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }
}

class Sketcher extends CustomPainter {
  final List<Shape> shapes;

  Sketcher({required this.shapes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in shapes) {
      s.draw(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant Sketcher oldDelegate) => true;
}
