import 'package:flutter/material.dart';
import 'dart:math';

class PharmacyScenePainter extends CustomPainter {
  final double animationValue;
  PharmacyScenePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fill = Paint()
      ..color = Colors.blueAccent.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final glow = Paint()
      ..color = Colors.blueAccent.withOpacity(0.4 + 0.4 * sin(animationValue * 2 * pi))
      ..style = PaintingStyle.fill;

    // Building structure
    final double buildingLeft = size.width * 0.2;
    final double buildingTop = size.height * 0.45;
    final double buildingWidth = size.width * 0.6;
    final double buildingHeight = size.height * 0.35;

    // Draw the building
    final Rect building = Rect.fromLTWH(buildingLeft, buildingTop, buildingWidth, buildingHeight);
    canvas.drawRect(building, stroke);
    canvas.drawRect(building, fill);

    // Roof line
    canvas.drawLine(
      Offset(buildingLeft, buildingTop),
      Offset(buildingLeft + buildingWidth, buildingTop),
      stroke,
    );

    // Pharmacy sign
    const signHeight = 32.0;
    final signRect = Rect.fromLTWH(
      buildingLeft + buildingWidth * 0.2,
      buildingTop - signHeight - 8,
      buildingWidth * 0.6,
      signHeight,
    );
    final sign = RRect.fromRectAndRadius(signRect, const Radius.circular(6));
    canvas.drawRRect(sign, stroke);
    _drawText(canvas, 'PHARMACY', signRect.left + 14, signRect.top + 6, 14, canvas);

    // Door frames
    final doorWidth = buildingWidth * 0.25;
    final doorHeight = buildingHeight * 0.6;
    final double doorLeft = buildingLeft + (buildingWidth - doorWidth) / 2;
    final double doorTop = buildingTop + (buildingHeight - doorHeight);

    // Draw doors
    final leftDoor = Rect.fromLTWH(doorLeft, doorTop, doorWidth / 2, doorHeight);
    final rightDoor = Rect.fromLTWH(doorLeft + doorWidth / 2, doorTop, doorWidth / 2, doorHeight);
    canvas.drawRect(leftDoor, stroke);
    canvas.drawRect(rightDoor, stroke);
    canvas.drawLine(
      Offset(doorLeft + doorWidth / 2, doorTop),
      Offset(doorLeft + doorWidth / 2, doorTop + doorHeight),
      stroke,
    );

    // Windows frames
    final windowWidth = buildingWidth * 0.2;
    final windowHeight = doorHeight * 0.7;
    final double windowTop = doorTop;

    final leftWindow = Rect.fromLTWH(buildingLeft + 12, windowTop, windowWidth, windowHeight);
    final rightWindow = Rect.fromLTWH(
        buildingLeft + buildingWidth - windowWidth - 12, windowTop, windowWidth, windowHeight);
    canvas.drawRect(leftWindow, stroke);
    canvas.drawRect(rightWindow, stroke);

    // Shelf lines
    for (int i = 1; i <= 2; i++) {
      final dy = windowTop + i * windowHeight / 3;
      canvas.drawLine(Offset(leftWindow.left + 6, dy), Offset(leftWindow.right - 6, dy), stroke);
      canvas.drawLine(Offset(rightWindow.left + 6, dy), Offset(rightWindow.right - 6, dy), stroke);
    }

    // Surveillance Camera
    final cameraMount = Offset(buildingLeft - 28, windowTop + 10);
    const double armLength = 24;
    final double rotation = sin(animationValue * 2 * pi) * pi / 10;

    // Draw camera arm
    final Offset headPivot = Offset(
      cameraMount.dx + armLength * cos(rotation),
      cameraMount.dy + armLength * sin(rotation),
    );

    // Draw camera head
    final cameraBody = Rect.fromCenter(center: headPivot, width: 26, height: 14);
    final lensCenter = Offset(headPivot.dx + 10, headPivot.dy);

    // Wire
    final wirePath = Path()
      ..moveTo(cameraMount.dx - 8, cameraMount.dy + 6)
      ..quadraticBezierTo(
          cameraMount.dx - 20, cameraMount.dy + 20, buildingLeft, buildingTop + buildingHeight);
    canvas.drawPath(wirePath, stroke);

    // Draw camera
    canvas.drawCircle(cameraMount, 4, glow);
    canvas.drawLine(cameraMount, headPivot, stroke);
    canvas.drawRect(cameraBody, stroke);
    canvas.drawCircle(lensCenter, 3, stroke);
  }

  // Helper function
  void _drawText(Canvas canvas, String text, double x, double y, double size, Canvas ctx) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
        fontSize: size,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(ctx, Offset(x, y));
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
