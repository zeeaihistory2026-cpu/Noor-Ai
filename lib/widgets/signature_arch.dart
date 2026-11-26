import 'package:flutter/material.dart';
import '../theme/noor_theme.dart';

class SignatureArchPainter extends CustomPainter {
  const SignatureArchPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NoorColors.gold.withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    for (final scale in [1.0, 1.14, 1.28]) {
      final cx = size.width / 2,
          top = -42 * scale,
          half = 94 * scale,
          bottom = size.height + 80;
      final path = Path()
        ..moveTo(cx - half, bottom)
        ..lineTo(cx - half, top + 130 * scale)
        ..cubicTo(cx - half, top + 65 * scale, cx - 24 * scale,
            top + 38 * scale, cx, top)
        ..cubicTo(cx + 24 * scale, top + 38 * scale, cx + half,
            top + 65 * scale, cx + half, top + 130 * scale)
        ..lineTo(cx + half, bottom);
      canvas.drawPath(path, paint);
    }
    final dot = Paint()..color = NoorColors.gold.withValues(alpha: .5);
    for (final x in [22.0, size.width - 22]) {
      canvas.drawCircle(Offset(x, 25), 2, dot);
      canvas.drawCircle(Offset(x, 31), .8, dot);
    }
  }

  @override
  bool shouldRepaint(covariant SignatureArchPainter oldDelegate) => false;
}
