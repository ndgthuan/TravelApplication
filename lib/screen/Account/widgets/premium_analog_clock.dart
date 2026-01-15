import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// A premium analog clock widget with modern, elegant design.
/// Customizable colors and timezone offset support.
class PremiumAnalogClock extends StatefulWidget {
  /// The primary color for hands and markers
  final Color accentColor;

  /// Background color of the clock dial
  final Color dialColor;

  /// Timezone offset in hours (e.g., +7 for Vietnam, -5 for EST)
  final int timezoneOffset;

  /// Whether to show the second hand
  final bool showSecondHand;

  const PremiumAnalogClock({
    super.key,
    this.accentColor = const Color(0xFFFF6B35),
    this.dialColor = const Color(0xFF2A2A2D),
    this.timezoneOffset = 0,
    this.showSecondHand = true,
  });

  @override
  State<PremiumAnalogClock> createState() => _PremiumAnalogClockState();
}

class _PremiumAnalogClockState extends State<PremiumAnalogClock> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now().toUtc().add(
        Duration(hours: widget.timezoneOffset),
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClockPainter(
        dateTime: _currentTime,
        accentColor: widget.accentColor,
        dialColor: widget.dialColor,
        showSecondHand: widget.showSecondHand,
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime dateTime;
  final Color accentColor;
  final Color dialColor;
  final bool showSecondHand;

  _ClockPainter({
    required this.dateTime,
    required this.accentColor,
    required this.dialColor,
    required this.showSecondHand,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Draw dial background
    _drawDial(canvas, center, radius);

    // Draw minute markers (60 small ticks)
    _drawMinuteMarkers(canvas, center, radius);

    // Draw hour markers (12 larger ticks)
    _drawHourMarkers(canvas, center, radius);

    // Draw hands
    _drawHourHand(canvas, center, radius);
    _drawMinuteHand(canvas, center, radius);
    if (showSecondHand) {
      _drawSecondHand(canvas, center, radius);
    }

    // Draw center dot
    _drawCenterDot(canvas, center, radius);
  }

  void _drawDial(Canvas canvas, Offset center, double radius) {
    // Draw background circle
    final paint = Paint()
      ..color = dialColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 2, paint);

    // Draw orange border ring
    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 2, borderPaint);
  }

  void _drawMinuteMarkers(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      // Skip hour positions
      if (i % 5 == 0) continue;

      final angle = (i * 6 - 90) * pi / 180;
      final outerPoint = Offset(
        center.dx + (radius - 6) * cos(angle),
        center.dy + (radius - 6) * sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 10) * cos(angle),
        center.dy + (radius - 10) * sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, paint);
    }
  }

  void _drawHourMarkers(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final outerPoint = Offset(
        center.dx + (radius - 6) * cos(angle),
        center.dy + (radius - 6) * sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 22) * cos(angle),
        center.dy + (radius - 22) * sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, paint);
    }
  }

  void _drawHourHand(Canvas canvas, Offset center, double radius) {
    final hour = dateTime.hour % 12;
    final minute = dateTime.minute;
    final angle = ((hour * 30 + minute * 0.5) - 90) * pi / 180;

    final handLength = radius * 0.45;
    final handWidth = 3.5;

    _drawHand(canvas, center, angle, handLength, handWidth, accentColor);
  }

  void _drawMinuteHand(Canvas canvas, Offset center, double radius) {
    final minute = dateTime.minute;
    final second = dateTime.second;
    final angle = ((minute * 6 + second * 0.1) - 90) * pi / 180;

    final handLength = radius * 0.62;
    final handWidth = 2.5;

    _drawHand(canvas, center, angle, handLength, handWidth, accentColor);
  }

  void _drawSecondHand(Canvas canvas, Offset center, double radius) {
    final second = dateTime.second;
    final angle = (second * 6 - 90) * pi / 180;

    final handLength = radius * 0.6;

    // Draw thin second hand
    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final endPoint = Offset(
      center.dx + handLength * cos(angle),
      center.dy + handLength * sin(angle),
    );

    // Draw a small tail on the opposite side
    final tailPoint = Offset(
      center.dx - (radius * 0.15) * cos(angle),
      center.dy - (radius * 0.15) * sin(angle),
    );

    canvas.drawLine(tailPoint, endPoint, paint);
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double width,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final endPoint = Offset(
      center.dx + length * cos(angle),
      center.dy + length * sin(angle),
    );

    canvas.drawLine(center, endPoint, paint);
  }

  void _drawCenterDot(Canvas canvas, Offset center, double radius) {
    // Outer ring
    final outerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.06, outerPaint);

    // Inner dot
    final innerPaint = Paint()
      ..color = dialColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.025, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return dateTime.second != oldDelegate.dateTime.second ||
        accentColor != oldDelegate.accentColor ||
        dialColor != oldDelegate.dialColor;
  }
}
