import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Decorative corner-bracket frame for QR code / barcode previews.
///
/// Draws thick L-shaped corners in alternating brand colors
/// (orange top-left/bottom-right, darkTeal top-right/bottom-left)
/// to recreate the branded QR styling from the LeosGroup identity.
class QrCornerFrame extends StatelessWidget {
  const QrCornerFrame({
    super.key,
    required this.child,
    this.size,
    this.width,
    this.height,
    this.cornerLength = 36,
    this.strokeWidth = 5,
    this.cornerRadius = 6,
    this.padding = 12,
  });

  final Widget child;
  final double? size;
  final double? width;
  final double? height;
  final double cornerLength;
  final double strokeWidth;
  final double cornerRadius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? size ?? 260,
      height: height ?? size ?? 260,
      child: CustomPaint(
        painter: _CornerFramePainter(
          cornerLength: cornerLength,
          strokeWidth: strokeWidth,
          cornerRadius: cornerRadius,
          colorA: AppColors.orange,
          colorB: AppColors.darkTeal,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding + strokeWidth),
          child: child,
        ),
      ),
    );
  }
}

class _CornerFramePainter extends CustomPainter {
  _CornerFramePainter({
    required this.cornerLength,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.colorA,
    required this.colorB,
  });

  final double cornerLength;
  final double strokeWidth;
  final double cornerRadius;
  final Color colorA; // orange  — top-left, bottom-right
  final Color colorB; // darkTeal — top-right, bottom-left

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final half = strokeWidth / 2;

    // ─── Top-Left (orange) ─────────────────────────
    _drawCorner(
      canvas,
      Offset(half, half),
      cornerLength,
      strokeWidth,
      cornerRadius,
      colorA,
      topLeft: true,
    );

    // ─── Top-Right (darkTeal) ──────────────────────
    _drawCorner(
      canvas,
      Offset(w - half, half),
      cornerLength,
      strokeWidth,
      cornerRadius,
      colorB,
      topRight: true,
    );

    // ─── Bottom-Left (darkTeal) ────────────────────
    _drawCorner(
      canvas,
      Offset(half, h - half),
      cornerLength,
      strokeWidth,
      cornerRadius,
      colorB,
      bottomLeft: true,
    );

    // ─── Bottom-Right (orange) ─────────────────────
    _drawCorner(
      canvas,
      Offset(w - half, h - half),
      cornerLength,
      strokeWidth,
      cornerRadius,
      colorA,
      bottomRight: true,
    );
  }

  void _drawCorner(
    Canvas canvas,
    Offset anchor,
    double len,
    double sw,
    double radius,
    Color color, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    if (topLeft) {
      path.moveTo(anchor.dx, anchor.dy + len);
      path.lineTo(anchor.dx, anchor.dy + radius);
      path.quadraticBezierTo(
        anchor.dx,
        anchor.dy,
        anchor.dx + radius,
        anchor.dy,
      );
      path.lineTo(anchor.dx + len, anchor.dy);
    } else if (topRight) {
      path.moveTo(anchor.dx - len, anchor.dy);
      path.lineTo(anchor.dx - radius, anchor.dy);
      path.quadraticBezierTo(
        anchor.dx,
        anchor.dy,
        anchor.dx,
        anchor.dy + radius,
      );
      path.lineTo(anchor.dx, anchor.dy + len);
    } else if (bottomLeft) {
      path.moveTo(anchor.dx, anchor.dy - len);
      path.lineTo(anchor.dx, anchor.dy - radius);
      path.quadraticBezierTo(
        anchor.dx,
        anchor.dy,
        anchor.dx + radius,
        anchor.dy,
      );
      path.lineTo(anchor.dx + len, anchor.dy);
    } else if (bottomRight) {
      path.moveTo(anchor.dx - len, anchor.dy);
      path.lineTo(anchor.dx - radius, anchor.dy);
      path.quadraticBezierTo(
        anchor.dx,
        anchor.dy,
        anchor.dx,
        anchor.dy - radius,
      );
      path.lineTo(anchor.dx, anchor.dy - len);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerFramePainter oldDelegate) =>
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.colorA != colorA ||
      oldDelegate.colorB != colorB;
}
