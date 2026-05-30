import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Hand-drawn vector illustrations for empty states. We avoid external
/// SVG / image dependencies because the current app ships zero asset
/// files — keeping that streak preserves install size, and a `CustomPainter`
/// style adapts to theme colors automatically.
///
/// Each illustration is a square 120×120 widget with a soft tinted
/// background plate and a foreground sketch in the brand primary.
enum EmptyIllustration {
  /// Notebook + pen — for "no transactions yet".
  noRecords,

  /// Coin stack — for "no budgets" / "no bills".
  noFunds,

  /// Magnifier on dotted background — for "no search results".
  noResults,
}

class EmptyArtwork extends StatelessWidget {
  final EmptyIllustration kind;
  final double size;
  const EmptyArtwork({super.key, required this.kind, this.size = 120});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IllustrationPainter(
          kind: kind,
          accent: cs.primary,
          plate: cs.primaryContainer
              .withValues(alpha: AppColors.opacityIllustrationBg),
          stroke: cs.primary
              .withValues(alpha: AppColors.opacitySecondary + 0.10),
        ),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  final EmptyIllustration kind;
  final Color accent;
  final Color plate;
  final Color stroke;

  _IllustrationPainter({
    required this.kind,
    required this.accent,
    required this.plate,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background plate — soft tinted disc behind every illustration.
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(centre, radius, Paint()..color = plate);

    switch (kind) {
      case EmptyIllustration.noRecords:
        _paintNotebook(canvas, size);
        break;
      case EmptyIllustration.noFunds:
        _paintCoinStack(canvas, size);
        break;
      case EmptyIllustration.noResults:
        _paintMagnifier(canvas, size);
        break;
    }
  }

  void _paintNotebook(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;

    // Notebook body — 60×72 rounded rect, slightly rotated.
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-0.05);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 60, height: 72),
      const Radius.circular(8),
    );
    canvas.drawRRect(body, Paint()..color = accent);

    // Inner page.
    final page = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(2, 0), width: 48, height: 60),
      const Radius.circular(6),
    );
    canvas.drawRRect(page, Paint()..color = Colors.white);

    // Three text lines.
    final linePaint = Paint()
      ..color = stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-16, -12), const Offset(16, -12), linePaint);
    canvas.drawLine(const Offset(-16, -2), const Offset(8, -2), linePaint);
    canvas.drawLine(const Offset(-16, 8), const Offset(12, 8), linePaint);
    canvas.restore();

    // Pen — diagonal capsule top-right.
    canvas.save();
    canvas.translate(cx + 24, cy - 22);
    canvas.rotate(0.6);
    final pen = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 38, height: 8),
      const Radius.circular(4),
    );
    canvas.drawRRect(pen, Paint()..color = accent);
    // Pen tip.
    final tip = Path()
      ..moveTo(19, -4)
      ..lineTo(26, 0)
      ..lineTo(19, 4)
      ..close();
    canvas.drawPath(tip, Paint()..color = accent);
    canvas.restore();
  }

  void _paintCoinStack(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2 + 8;
    final stroke3 = Paint()
      ..color = accent
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    // Three stacked coins viewed in 3/4. Drawn from bottom up so the
    // top coin overlaps cleanly.
    void coin(double yOffset, {bool top = false}) {
      final rect = Rect.fromCenter(
          center: Offset(cx, cy + yOffset), width: 64, height: 22);
      canvas.drawOval(rect, Paint()..color = accent);
      if (top) {
        // Top face highlight.
        final top = Rect.fromCenter(
            center: Offset(cx, cy + yOffset - 2),
            width: 64,
            height: 22);
        canvas.drawOval(top, stroke3..color = Colors.white);
        // ¥ symbol.
        final tp = TextPainter(
          text: TextSpan(
            text: '¥',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy + yOffset - tp.height / 2 - 2));
      }
    }

    coin(20);
    coin(8);
    coin(-4, top: true);
  }

  void _paintMagnifier(Canvas canvas, Size s) {
    final cx = s.width / 2 - 6;
    final cy = s.height / 2 - 6;
    final lensPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Lens.
    canvas.drawCircle(Offset(cx, cy), 22, lensPaint);
    // Glass tint.
    canvas.drawCircle(Offset(cx, cy), 18, Paint()..color = Colors.white);

    // Handle.
    canvas.drawLine(
      Offset(cx + 16, cy + 16),
      Offset(cx + 30, cy + 30),
      lensPaint,
    );

    // Question-mark hint inside the lens.
    final tp = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) =>
      old.kind != kind ||
      old.accent != accent ||
      old.plate != plate ||
      old.stroke != stroke;
}
