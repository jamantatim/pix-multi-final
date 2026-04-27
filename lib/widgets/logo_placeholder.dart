import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class LogoPlaceholder {
  static Future<Uint8List> generate({
    required String text,
    int size = 200,
    Color backgroundColor = const Color(0xFF00C853),
    Color textColor = Colors.white,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = backgroundColor;
    
    canvas.drawCircle(Offset(size/2, size/2), size/2, paint);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: size * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );
    
    final image = await recorder.endRecording().toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
