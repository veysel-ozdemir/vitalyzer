import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vitalyzer/const/color_palette.dart';

class BMIGaugePainter extends CustomPainter {
  final double bmiValue;

  BMIGaugePainter({required this.bmiValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.45;

    // Draw the gauge background
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25.0;

    // Draw the gauge ranges with specific rounded edges
    _drawGaugeArc(canvas, center, radius, 10, 18.5, Colors.blue, paint,
        isFirst: true);
    _drawGaugeArc(canvas, center, radius, 18.5, 24.99, Colors.green, paint);
    _drawGaugeArc(canvas, center, radius, 25, 29.99, Colors.yellow, paint);
    _drawGaugeArc(canvas, center, radius, 30, 39.99, Colors.orange, paint);
    _drawGaugeArc(canvas, center, radius, 40, 50, Colors.red, paint,
        isLast: true);

    // Draw the needle
    _drawNeedle(canvas, center, radius, bmiValue);
  }

  void _drawGaugeArc(Canvas canvas, Offset center, double radius,
      double startValue, double endValue, Color color, Paint paint,
      {bool isFirst = false, bool isLast = false}) {
    final startAngle = _valueToAngle(startValue);
    final sweepAngle = _valueToAngle(endValue) - startAngle;

    paint.color = color;

    if (isFirst) {
      // First arc: rounded start, butt end
      paint.strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    } else if (isLast) {
      // Last arc: butt start, rounded end
      // Draw first half with butt cap
      paint.strokeCap = StrokeCap.butt;
      final midAngle = startAngle + sweepAngle * 0.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * 0.5,
        false,
        paint,
      );

      // Draw second half with round cap
      paint.strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        midAngle,
        sweepAngle * 0.5,
        false,
        paint,
      );
    } else {
      // Middle arcs: butt cap for both ends
      paint.strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius, double value) {
    final paint = Paint()
      ..color = ColorPalette.darkGreen
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final angle = _valueToAngle(value);
    final needleLength = radius - 40;
    final needleEnd = Offset(
      center.dx + cos(angle) * needleLength,
      center.dy + sin(angle) * needleLength,
    );

    // Draw needle with thicker stroke
    canvas.drawLine(center, needleEnd, paint..strokeWidth = 5);

    // Draw center circle with gradient
    final circlePaint = Paint()
      ..shader = const RadialGradient(
        colors: [ColorPalette.green, ColorPalette.darkGreen],
      ).createShader(Rect.fromCircle(center: center, radius: 12));

    canvas.drawCircle(center, 12, circlePaint);
  }

  double _valueToAngle(double value) {
    // Map BMI value (10-50) to angle (-210 to 30 degrees for 90-degree left rotation)
    const minValue = 10.0;
    const maxValue = 50.0;
    const startAngle = -210 * pi / 180; // Adjusted for 90-degree left rotation
    const totalAngle = 240 * pi / 180;

    return startAngle + (value - minValue) / (maxValue - minValue) * totalAngle;
  }

  @override
  bool shouldRepaint(BMIGaugePainter oldDelegate) {
    return oldDelegate.bmiValue != bmiValue;
  }
}
