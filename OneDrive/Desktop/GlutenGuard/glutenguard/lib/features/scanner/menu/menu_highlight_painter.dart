import 'package:flutter/material.dart';

/// Paints a solid filled circle in [color].
///
/// Used as the inline verdict dot next to each dish line in
/// [MenuResultPage]. Swap [color] to change RED / AMBER / GREEN state.
class MenuHighlightPainter extends CustomPainter {
  final Color color;

  const MenuHighlightPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(MenuHighlightPainter old) => old.color != color;
}
