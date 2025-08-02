import 'package:flutter/material.dart';
import 'dart:math';

/// Custom painter for the pharmacy scene, including animated elements.
class PharmacyScenePainter extends CustomPainter {
  final double animationValue;
  PharmacyScenePainter({required this.animationValue});

  /// Paints the pharmacy scene with animated elements.
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Background fill
    final fill = Paint()
      ..color = Colors.blueAccent.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw the background
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

    // Compliance tag
    _drawText(canvas, '✔ In Compliance', buildingLeft, signRect.top - 20, 12, canvas);

    // RCON tracker beacon (pulsing glow)
    final rconCenter = Offset(buildingLeft + buildingWidth - 14, buildingTop - 16);
    canvas.drawCircle(rconCenter, 6, glow);
    canvas.drawCircle(rconCenter, 2, stroke);
    _drawText(canvas, 'RCON', rconCenter.dx - 16, rconCenter.dy - 18, 10, canvas);

    // Door frames
    final doorWidth = buildingWidth * 0.25;
    final doorHeight = buildingHeight * 0.6;
    final double doorLeft = buildingLeft + (buildingWidth - doorWidth) / 2;
    final double doorTop = buildingTop + (buildingHeight - doorHeight);

    // Draw the door frames
    final leftDoor = Rect.fromLTWH(doorLeft, doorTop, doorWidth / 2, doorHeight);
    final rightDoor = Rect.fromLTWH(doorLeft + doorWidth / 2, doorTop, doorWidth / 2, doorHeight);
    canvas.drawRect(leftDoor, stroke);
    canvas.drawRect(rightDoor, stroke);
    canvas.drawLine(
      Offset(doorLeft + doorWidth / 2, doorTop),
      Offset(doorLeft + doorWidth / 2, doorTop + doorHeight),
      stroke,
    );

    // Pharmacist character (simple glowing dot at counter if present)
    final pharmacistPulse = Paint()
      ..color = Colors.greenAccent.withOpacity(0.5 + 0.5 * sin(animationValue * 2 * pi))
      ..style = PaintingStyle.fill;
    
    // Draw the pharmacist at the counter
    final pharmacistCenter = Offset(doorLeft + doorWidth / 2, doorTop - 12);
    canvas.drawCircle(pharmacistCenter, 6, pharmacistPulse);
    _drawText(canvas, 'Pharmacist', pharmacistCenter.dx - 32, pharmacistCenter.dy - 18, 10, canvas);

    // Windows
    final windowWidth = buildingWidth * 0.2;
    final windowHeight = doorHeight * 0.7;
    final double windowTop = doorTop;

    // Draw the windows on both sides of the door
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

    // Indoor/Outdoor labels
    _drawText(canvas, 'Indoor', leftWindow.left + 4, leftWindow.bottom + 4, 10, canvas);
    _drawText(canvas, 'Indoor', rightWindow.left + 4, rightWindow.bottom + 4, 10, canvas);
    _drawText(canvas, 'Outdoor', doorLeft + 4, rightDoor.bottom + 6, 10, canvas);

    // Surveillance Camera
    final cameraMount = Offset(buildingLeft - 28, windowTop + 10);
    const double armLength = 24;
    final double rotation = sin(animationValue * 2 * pi) * pi / 10;

    // Draw the camera arm
    final Offset headPivot = Offset(
      cameraMount.dx + armLength * cos(rotation),
      cameraMount.dy + armLength * sin(rotation),
    );

    // Draw the camera head
    final cameraBody = Rect.fromCenter(center: headPivot, width: 26, height: 14);
    final lensCenter = Offset(headPivot.dx + 10, headPivot.dy);

    // Draw the camera lens
    final wirePath = Path()
      ..moveTo(cameraMount.dx - 8, cameraMount.dy + 6)
      ..quadraticBezierTo(
          cameraMount.dx - 20, cameraMount.dy + 20, buildingLeft, buildingTop + buildingHeight);
    canvas.drawPath(wirePath, stroke);

    // Draw the camera components
    canvas.drawCircle(cameraMount, 4, glow);
    canvas.drawLine(cameraMount, headPivot, stroke);
    canvas.drawRect(cameraBody, stroke);
    canvas.drawCircle(lensCenter, 3, stroke);
  }

  /// Draws text on the canvas at a specified position.
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

  /// Returns true if the painter should repaint.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
